local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local NPCData = require(ReplicatedStorage.Data.NPCData)
local NPCService = require(ReplicatedStorage.Services.NPCService)
local ObjectService = require(ReplicatedStorage.Services.ObjectService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)

-- Events
local PlayerEvents = ReplicatedStorage.Events.PlayerEvents

local NPCCharacters = {} -- player: {npc data}
local PlayerData = {}
local Settings = {}

-- Init settings
local function Init() : nil
    Settings.spawnFrequency = NPCService.GetSpawnFrequency()
end

Init() -- Call init immediately

-- Receive information that player's active state has changed
PlayerEvents.ActiveToggled.Event:Connect(function(player : Player, active : boolean)
    if not PlayerData[player] then
        PlayerData[player] = {}
    end

    if not NPCCharacters[player] then
        NPCCharacters[player]  = {}
    end

    PlayerData[player]["active"] = active
    if not active and NPCCharacters[player] then
        NPCService.DestroyAll(NPCCharacters[player])
        NPCCharacters[player] = {} 
    elseif active then
        PlayerData[player]["step"] = 0
        PlayerData[player]["route"] = PlayerService.GetRoutePoint(player)
    end

    while PlayerData[player]["active"] do -- increase step by 1 while player is active
        if PlayerData[player]["step"] % 30 == 0 then
            table.insert(NPCCharacters[player], NPCService.SpawnNewCharacter("regular", PlayerData[player]["route"].CFrame))
        end
        PlayerData[player]["step"] += 1
        task.wait(1)
    end
end)

--[[ !! TODO: basically... what i need to do here is NOT run every heartbeat
but instead do something with task.wait() or coroutines or SOMETHING so that it checks every second.
]]


--[[
local function routeTo(plr : Player, data : table)
    local activeWasher = PlacementEvents.GetAvaliableWasher:Invoke(plr)

    if activeWasher then 
        local washer = activeWasher["model"]
        if washer then
            local complete = NPCService.WalkCharacter(data, washer:WaitForChild("Route").Position, {AgentCanJump = false, AgentRadius = 4})
        end
    end

    if NPCService.GetStatus(data) == "Empty" then
        ObjectService.UpdateStatus(activeWasher, "Running")
        print('washer is empty!')
    else
        print('washer is full... need to reroute')
        routeTo(data)
    end
end


Players.PlayerAdded:Connect(function(player) -- test function for npc controller 
    local character = player.Character or player.CharacterAdded:Wait()
    local data = NPCService.SpawnCharacter("regular", character.HumanoidRootPart.CFrame)
    NPCharacters[player] = data
    task.wait(5)
    routeTo(player, data)
end)
]]
-- Controllers keep track of events
-- Services keep track of behaviors