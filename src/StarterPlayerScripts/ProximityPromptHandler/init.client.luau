local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ObjectService = require(ReplicatedStorage.Services.ObjectService)
local ObjectEvents = ReplicatedStorage.Events.ObjectEvents

ObjectEvents.CreatePrompt.OnClientEvent:Connect(function(object : Object)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Parent = ObjectService.GetModel(object)

    prompt.Triggered:Connect(function(trigger)
        local success = ObjectService.RunCycle(object)
        print('run cycle success: '.. success)
    end)
end)