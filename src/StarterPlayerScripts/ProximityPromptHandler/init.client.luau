local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCEvents = ReplicatedStorage.Events.NPCEvents
local NPCService = require(ReplicatedStorage.Services.NPCService)

-- Executes proximity prompt creations via client
NPCEvents.ExecuteOnClient.OnClientEvent:Connect(function(func : string, ...)
    NPCService[func](...)
end)