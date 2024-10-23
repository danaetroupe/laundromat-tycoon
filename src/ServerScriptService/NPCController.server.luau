-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local NPCService = require(ReplicatedStorage.Services.NPCService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)

-- Data
local NPCData = require(ReplicatedStorage.Data.NPCData)

-- Events
local PlayerEvents = ReplicatedStorage.Events.PlayerEvents
local NPCEvents = ReplicatedStorage.Events.NPCEvents

-- Types
type NPC = NPCData.NPC

local PlayerData = {}


-- local function to spawn npc and add to queue
local function spawn(player : Player, line : string, npc : NPC)
    local endPart : Part = PlayerData[player]["tycoon"][line]
    npc = NPCService.SpawnNewCharacter(player, PlayerData[player]["tycoon"].Entry.CFrame, npc)
    table.insert(PlayerData[player][line], npc)

    local pos = endPart.Position + Vector3.new(1, 0, 0) * 2 * (#PlayerData[player][line]-1)
    NPCService.WalkCharacter(npc, pos, endPart.Rotation)
    if #PlayerData[player][line] == 1 then
        NPCService.GivePrompt(npc)
    end
end

-- Connect SpawnNPC event to spawn
NPCEvents.SpawnNPC.OnServerEvent:Connect(spawn)

NPCEvents.UpdateLine.OnServerEvent:Connect(function(player : Player, line : string) -- moves up line if event happens
    table.remove(PlayerData[player][line], 1)
	if #PlayerData[player][line] >= 1 then -- check if queue is not empty
		NPCService.GivePrompt(PlayerData[player][line][1])
	end
    for i, attendant in PlayerData[player][line] do -- Move all humanoids up in the queue
        local pos = PlayerData[player]["tycoon"][line].Position + Vector3.new(1, 0, 0) * 2 * (i-1)
        NPCService.WalkCharacter(attendant, pos, PlayerData[player]["tycoon"][line].Rotation)
    end
end)

-- Receive information that player's active state has changed
PlayerEvents.ActiveToggled.Event:Connect(function(player : Player, active : boolean)
    if not PlayerData[player] then
        PlayerData[player] = {}
    end

    PlayerData[player]["active"] = active
	if active then -- if any npcs even currently exist destroy all of them    
        PlayerData[player]["step"] = 0 -- if active reset all values 
        PlayerData[player]["dropoff"] = {} -- set queue to empty
        PlayerData[player]["pickup"] = {} -- set queue to empty
        PlayerData[player]["tycoon"] = PlayerService.GetTycoon(player)
    else
        NPCService.DestroyAll(PlayerData["pickup"])
        NPCService.DestroyAll(PlayerData["dropoff"])
    end

    while PlayerData[player]["active"] do -- increase step by 1 while player is active
        if PlayerData[player]["step"] % PlayerService.GetSpawnRate(player) == 0 then
            spawn(player, "dropoff")
        end
        PlayerData[player]["step"] += 1
        task.wait(1)
    end
end)