local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local NPCData = require(ReplicatedStorage.Data.NPCData)
local NPCService = require(ReplicatedStorage.Services.NPCService)
local ObjectService = require(ReplicatedStorage.Services.ObjectService)

-- Events
local PlacementEvents = ServerStorage.BindableEvents.PlacementEvents

local NPCharacters = {}

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

--[[
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