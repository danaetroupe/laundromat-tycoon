local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local NPCData = require(ReplicatedStorage.Data.NPCData)
local NPCService = require(ReplicatedStorage.Services.NPCService)
local InteractionData = require(ReplicatedStorage.Services.InteractionService)

-- Events
local PlacementEvents = ServerStorage.BindableEvents.PlacementEvents

local NPCharacters = {}

local function routeTo(plr : Player, data : table) -- Should I move this to the service
    local activeWasher = PlacementEvents.GetAvaliableWasher:Invoke(plr)
    local complete

    if activeWasher then 
        local washer = activeWasher["model"]
        if washer then
            local complete = NPCService.WalkCharacter(data, washer:WaitForChild("Route").Position, {AgentCanJump = false, AgentRadius = 4})
        end
    end

    if activeWasher["status"] == "Empty" then
        InteractionData:UpdateStatus(activeWasher, "Running")
        print('washer is empty!')
    else
        print('washer is full... need to reroute')
        routeTo(data)
    end
    
end

Players.PlayerAdded:Connect(function(player)
    local character = player.Character or player.CharacterAdded:Wait()
    
    local data = NPCData.Get("regular") -- this should be handled through the service FIX !!!!
    data = NPCService.SpawnCharacter(data, character.HumanoidRootPart.CFrame)
    NPCharacters[player] = data
    task.wait(5)
    routeTo(player, data)
end)

-- Controllers keep track of events
-- Services keep track of behaviors