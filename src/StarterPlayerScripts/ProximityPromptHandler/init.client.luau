local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ObjectService = require(ReplicatedStorage.Services.ObjectService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)

local ObjectEvents = ReplicatedStorage.Events.ObjectEvents

local LocalPlayer = Players.LocalPlayer

ObjectEvents.CreatePrompt.OnServerEvent:Connect(function(object : table)
    local prompt = Instance.new("ProximityPrompt")
    local key = PlayerService.RequestKey(LocalPlayer)
    
    
    prompt.ActionText = "Unload"
    prompt.ObjectText = ObjectService.GetName(object)
end)