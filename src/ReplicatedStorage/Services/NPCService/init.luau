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
local _Data = {}

-- Takes tycoon active state and spawns NPCs
function NPCService.Init(player : Player, active : boolean)
    if not _Data[player] then
        _Data[player] = {}
    end

    _Data[player]["active"] = active
	if active then -- if any npcs even currently exist destroy all of them    
        _Data[player]["step"] = 0 -- if active reset all values 
        _Data[player]["dropoff"] = {} -- set queue to empty
        _Data[player]["pickup"] = {} -- set queue to empty
        _Data[player]["tycoon"] = PlayerService.GetTycoon(player)
    else
        NPCService.DestroyAll(_Data["pickup"])
        NPCService.DestroyAll(_Data["dropoff"])
    end

    while _Data[player]["active"] do -- increase step by 1 while player is active
        if _Data[player]["step"] % PlayerService.GetSpawnRate(player) == 0 then
            NPCService.SpawnNPC(player, "dropoff")
        end
        _Data[player]["step"] += 1
        task.wait(1)
    end
end

-- Spawn NPC and add to queue
function NPCService.SpawnNPC(player : Player, line : string, npc : NPC)
    local endPart : Part = _Data[player]["tycoon"][line]
    npc = NPCService.SpawnNewCharacter(player, _Data[player]["tycoon"].Entry.CFrame, npc)
    if line == "pickup" then -- If npc picking up, change to pickup status
        NPCService.ChangeState(npc, "PickUp")
    else
        local leave = coroutine.create(function()
            task.wait(60)
            -- NPC got tired of waiting and walked out
            if npc.state == "DropOff" then
                NPCService.WalkOut(npc, true)
            end
        end)
        coroutine.resume(leave)
    end
    -- Add to appropriate queue
    table.insert(_Data[player][line], npc)

    -- Walk to line position
    local pos = endPart.Position + Vector3.new(1, 0, 0) * 2 * (#_Data[player][line]-1)
    NPCService.WalkCharacter(npc, pos, endPart.Rotation)
    if #_Data[player][line] == 1 then
        NPCService.GivePrompt(npc)
    end
end

if isServer then
    NPCEvents.SpawnNPC.OnServerEvent:Connect(NPCService.SpawnNPC)
end


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
            local key = PlayerService.GetKey(player)
            local keyState = if key then ToolService.GetState(key) else nil
            if state == "DropOff" and not PlayerService.GetKey(player) then
                local tool = ToolService.GiveTool(player, "laundrybasket", npc)
                local success = PlayerService.AssignKey(tool)
                if success then 
                    NPCService.ChangeState(npc, "Waiting")
                    NPCService.WalkOut(npc, false)
                    NPCService.UpdateLine(player, "dropoff")
                    prompt:Destroy()
                else
                    ToolService.Destroy(tool)
                end
            elseif state == "PickUp" and key and keyState == "Ready" then
                PlayerService.AddMoney(player)
                PlayerService.ClearKey()
                ToolService.Destroy(key)
                NPCService.WalkOut(npc, true)
                NPCService.UpdateLine(player, "pickup")
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

-- Walk NPC out
function NPCService.WalkOut(npc : NPC, destroy : boolean)
    local part : Part = PlayerService.GetStartPoint(npc.player)
    NPCService.WalkCharacter(npc, part.Position, part.Rotation)
    task.wait(5)
    if destroy then
        npc.character:Destroy()
    else
        PlayerService.MoveToTemp(npc.character)
    end
end

-- Update queue
function NPCService.UpdateLine(player : Player, line : string) -- moves up line if event happens
    table.remove(_Data[player][line], 1)
	if #_Data[player][line] >= 1 then -- check if queue is not empty
		NPCService.GivePrompt(_Data[player][line][1])
	end
    for i, attendant in _Data[player][line] do -- Move all humanoids up in the queue
        local pos = _Data[player]["tycoon"][line].Position + Vector3.new(1, 0, 0) * 2 * (i-1)
        NPCService.WalkCharacter(attendant, pos, _Data[player]["tycoon"][line].Rotation)
    end
end

return NPCService