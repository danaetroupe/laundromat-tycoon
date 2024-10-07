-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

-- Events
local ClientEvents = ReplicatedStorage.Events.PlacementEvents
local ServerEvents = ServerStorage.BindableEvents.PlacementEvents

local Placements = {}

ClientEvents.InitPlacement.OnServerEvent:Connect(function(player : Player, baseObject : Part) : nil
    -- Run this when player steps on canvas to associate player with base object
    Placements[player]["base"] = baseObject
    Placements[player]["baseObjects"] = {}
end)

-- Returns first avaliable washer in list
ServerEvents.GetAvaliableWasher.OnInvoke = function(player : Player) : table | nil
    for _, val in Placements[player] do
        if val["name"] == "Washing Machine" and val["status"] == "Empty" then
            return val
        end
    end
    return nil
end

-- !! FOR TESTING PURPOSES ONLY
local CollectionService = game:GetService("CollectionService")
local Washers = CollectionService:GetTagged("Washer")
local WasherData = require(ReplicatedStorage.Data.ObjectData.washer)

Players.PlayerAdded:Connect(function(plr)
    Placements[plr] = {}

    for _, washer in Washers do
        local data = table.clone(WasherData)
        data["model"] = washer
        table.insert(Placements[plr], data)
    end
end)