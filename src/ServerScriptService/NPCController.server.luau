-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local NPCService = require(ReplicatedStorage.Services.NPCService)

-- Events
local PlayerEvents = ReplicatedStorage.Events.PlayerEvents


-- Receive information that player's active state has changed
PlayerEvents.ActiveToggled.Event:Connect(function(player : Player, active : boolean)
    NPCService.Init(player, active)
end)