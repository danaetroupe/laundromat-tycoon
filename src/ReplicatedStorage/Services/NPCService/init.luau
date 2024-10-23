-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules
local MovementService = require(ReplicatedStorage.Util.MovementService)
local ToolService = require(ReplicatedStorage.Services.ToolService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)

-- Data
local NPCData = require(ReplicatedStorage.Data.NPCData)
local OutfitData = require(ReplicatedStorage.Data.OutfitData)

-- Events
local MovementEvents = ReplicatedStorage.Events.MovementEvents
local NPCEvents = ReplicatedStorage.Events.NPCEvents

-- Types
type NPC = NPCData.NPC
type NPCState = NPCData.NPC

-- Events
local isServer = RunService:IsServer()
local NPCService = {}

-- Spawns character in world and creates if necessary
function NPCService.SpawnNewCharacter(player : Player, point : CFrameValue, data : NPC) : NPC
    data = data or table.clone(NPCData)
    local character : Model = data["character"]
    if not character then
        character = ModelService.GetModelFromStorage("NPC", "NPC")
        local humanoid = character.Humanoid or character:WaitForChild("Humanoid")
        local humDesc = humanoid:GetAppliedDescription()

        humDesc.Face = OutfitData.GetRandomFromCategory("face")
        humDesc.Shirt = OutfitData.GetRandomFromCategory("shirt")
        humDesc.Pants = OutfitData.GetRandomFromCategory("pants")
        humDesc.HairAccessory = OutfitData.GetRandomFromCategory("hair")
        humanoid:ApplyDescription(humDesc)
    end

    PlayerService.MoveToNPCFolder(player, character)
    character.HumanoidRootPart.CFrame = point -- Set to point
    data["character"] = character
    data["player"] = player 
    return data
end

-- Walks character to point
function NPCService.WalkCharacter(data : NPC, point : Vector3, rotation : Vector3)
    local character : Model = data["character"]
    if not character then
        error("Character not given.")
        return
    end

    MovementService.Move(character, point) -- run movement code

    local connect -- connection signal
    connect = MovementEvents.MovementComplete.Event:Connect(function(char)
        if char == character then
            character.PrimaryPart.Rotation = rotation
            connect:Disconnect()
        end
    end)
end

function NPCService.GetStatus(data : NPC) : string
    return data["status"]
end

function NPCService.DestroyAll(npcs : {NPC}) : nil
    for _, npc in npcs do
        npc["character"]:Destroy()
    end
end

function NPCService.GetHumanoid(data) : Humanoid
    return data["model"].Humanoid
end

function NPCService.FaceForwards(npc : NPC, part : Part)
    local character : Model = npc["character"]
    character:PivotTo(CFrame.lookAt(character.PrimaryPart.CFrame.Position, part.CFrame.LookVector))
end

-- Give NPC a proximity prompt
function NPCService.GivePrompt(npc : NPC)
    if isServer then
        NPCEvents.ExecuteOnClient:FireClient(npc.player, "GivePrompt", npc)
    else 
        -- Execute on client
        local prompt = Instance.new("ProximityPrompt")
        prompt.Parent = npc.character
        prompt.Triggered:Connect(function(player)
            local state = npc.state
            local key = PlayerService.RequestKey(player)
            local keyNPC = if key then ToolService.GetNPC(key) else nil
            if state == "DropOff" and not PlayerService.RequestKey(player) then
                local tool = ToolService.GiveTool(player, "laundrybasket", npc)
                local success = PlayerService.AssignKey(tool)
                if success then 
                    PlayerService.MoveToTemp(npc.character)
                    NPCEvents.UpdateLine:FireServer("dropoff")
                    prompt:Destroy()
                else
                    ToolService.Destroy(tool)
                end
            elseif state == "PickUp" and key and keyNPC.character == npc.character then
                ToolService.Destroy(key)
                npc.character:Destroy()
                NPCEvents.UpdateLine:FireServer("pickup")
                -- TODO: record satsifaction and whatnot... what events happen when they die
            end 
        end)
    end
end

-- Add existing NPC to queue to be spawned // client only
function NPCService.AddToQueue(npc : NPC)
    NPCEvents.MoveToNPCFolder:FireServer(npc)
end

-- Change NPC state 
function NPCService.ChangeState(npc : NPC, state : NPCState)
    npc.state = state
end

return NPCService