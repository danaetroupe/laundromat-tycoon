local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCData = require(ReplicatedStorage.Data.NPCData)
local NPCService = require(ReplicatedStorage.Services.NPCService)

local NPCharacters = {}

Players.PlayerAdded:Connect(function(player)
    print('here')
    local character = player.Character or player.CharacterAdded:Wait()
    
    local data = NPCData.Get("regular")
    data = NPCService.SpawnCharacter(data, character.HumanoidRootPart.CFrame)
    NPCharacters[player] = data
    task.wait(5)
    local TEST_DESTINATION = Vector3.new(-9, 0, 74.5)
    NPCService.WalkCharacter(data, TEST_DESTINATION, {AgentCanJump = false, AgentRadius = 4})
end)

-- Controllers keep track of events
-- Services keep track of behaviors