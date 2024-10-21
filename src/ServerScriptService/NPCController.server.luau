local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local NPCData = require(ReplicatedStorage.Data.NPCData)
local NPCService = require(ReplicatedStorage.Services.NPCService)
local ObjectService = require(ReplicatedStorage.Services.ObjectService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local Types = require(ReplicatedStorage.Data.Types)

-- Events
local PlayerEvents = ReplicatedStorage.Events.PlayerEvents
local NPCEvents = ReplicatedStorage.Events.NPCEvents

local NPCCharacters = {} -- player: {npc data}
local PlayerData = {}
local Settings = {}

type NPC = Types.NPC

-- Init settings
local function Init() : nil
    Settings.spawnFrequency = 60
end

Init() -- Call init immediately

-- local function to spawn npc and add to queue
local function spawn(player : Player, npc : NPC)
    npc = NPCService.SpawnNewCharacter(player, PlayerData[player]["start"].CFrame, npc)
    table.insert(PlayerData[player]["queue"], npc)
    table.insert(NPCCharacters[player], npc)

    local pos = PlayerData[player]["end"].Position + Vector3.new(1, 0, 0) * 2 * (#PlayerData[player]["queue"]-1)
    NPCService.WalkCharacter(npc, pos, PlayerData[player]["end"].Rotation)
    if #PlayerData[player]["queue"] == 1 then
        NPCService.GivePrompt(npc)
    end
end

-- Connect SpawnNPC event to spawn
NPCEvents.SpawnNPC:Connect(spawn)

NPCEvents.UpdateLine.OnServerEvent:Connect(function(player) -- moves up line if event happens
    table.remove(PlayerData[player]["queue"], 1)
	if #PlayerData[player]["queue"] >= 1 then -- check if queue is not empty
		NPCService.GivePrompt(PlayerData[player]["queue"][1])
	end
    for i, attendant in PlayerData[player]["queue"] do -- Move all humanoids up in the queue
        local pos = PlayerData[player]["end"].Position + Vector3.new(1, 0, 0) * 2 * (i-1)
        NPCService.WalkCharacter(attendant, pos, PlayerData[player]["end"].Rotation)
    end
end)

-- Receive information that player's active state has changed
PlayerEvents.ActiveToggled.Event:Connect(function(player : Player, active : boolean)
    if not PlayerData[player] then
        PlayerData[player] = {}
    end

    if not NPCCharacters[player] then
        NPCCharacters[player]  = {}
    end

    PlayerData[player]["active"] = active
	if not active and NPCCharacters[player] then -- if any npcs even currently exist destroy all of them
        NPCService.DestroyAll(NPCCharacters[player])
        NPCCharacters[player] = {}  
    elseif active then
        PlayerData[player]["step"] = 0 -- if active reset all values 
        PlayerData[player]["queue"] = {} -- set queue to empty
        PlayerData[player]["start"] = PlayerService.GetStartPoint(player)
        PlayerData[player]["end"] = PlayerService.GetEndPoint(player)
    end

    while PlayerData[player]["active"] do -- increase step by 1 while player is active
        if PlayerData[player]["step"] % 45 == 0 then
            spawn(player)
        end
        PlayerData[player]["step"] += 1
        task.wait(1)
    end
end)