local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolService = require(ReplicatedStorage.Services.ToolService)
local NPCService = require(ReplicatedStorage.Services.NPCService)

local ToolEvents = ReplicatedStorage.Events.ToolEvents

ToolEvents.ToolReady.OnServerEvent:Connect(function(player, id)
	NPCService.SpawnById(player, id)
end)