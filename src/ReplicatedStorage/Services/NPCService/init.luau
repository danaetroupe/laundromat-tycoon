-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local NPCData = require(ReplicatedStorage.Data.NPCData)
local OutfitData = require(ReplicatedStorage.Data.OutfitData)
local MovementService = require(ReplicatedStorage.Util.MovementService)
local ToolService = require(ReplicatedStorage.Services.ToolService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)

-- Events
local MovementEvents = ReplicatedStorage.Events.MovementEvents
local NPCEvents = ReplicatedStorage.Events.NPCEvents

-- Constants
local Model = ServerStorage.NPC.model

-- Events
local NPCService = {}

-- Spawns character in world and creates if necessary
function NPCService.SpawnNewCharacter(player : Player, type : string, point : CFrameValue) : table
    local data = table.clone(NPCData.Get(type))
    local character : Model = data["character"]
    if character then
        PlayerService.SpawnNPC(player, character)
    else
        character = Model:Clone() -- Create new character
        PlayerService.SpawnNPC(player, character)

        local humanoid = character.Humanoid or character:WaitForChild("Humanoid")
        local humDesc = humanoid:GetAppliedDescription()

        humDesc.Face = OutfitData.GetRandomFromCategory("face")
        humDesc.Shirt = OutfitData.GetRandomFromCategory("shirt")
        humDesc.Pants = OutfitData.GetRandomFromCategory("pants")
        humDesc.HairAccessory = OutfitData.GetRandomFromCategory("hair")
        humanoid:ApplyDescription(humDesc)
    end

    character.HumanoidRootPart.CFrame = point -- Set to point
    data["character"] = character
    data["player"] = player 
    return data
end

-- Walks character to point
function NPCService.WalkCharacter(data : table, point : Vector3, rotation : Vector3)
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

function NPCService.GetStatus(data : table) : string
    return data["status"]
end

function NPCService.DestroyAll(npcs : table) : nil
    for _, npc in npcs do
        npc["character"]:Destroy()
    end
end

function NPCService.GetSpawnFrequency() : number
    return NPCData.GetProperty("settings", "spawnFrequency")
end

function NPCService.GetHumanoid(data) : Humanoid
    return data["model"].Humanoid
end

function NPCService.FaceForwards(npc : table, part : Part)
    local character : Model = npc["character"]
    character:PivotTo(CFrame.lookAt(character.PrimaryPart.CFrame.Position, part.CFrame.LookVector))
end

-- Give NPC a proximity prompt
function NPCService.GivePrompt(npc)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Parent = npc.character
    prompt.Triggered:Connect(function(player)
        if player == npc["player"] then
            local tool = ToolService.GiveTool(player, "laundrybasket")
            local success = PlayerService.AssignKey(player, tool)
            if success then 
                PlayerService.MoveToTemp(player, npc.character)
                NPCEvents.UpdateLine:Fire(player)
            else
                ToolService.Destroy(tool)
            end
        end
    end)
end

return NPCService