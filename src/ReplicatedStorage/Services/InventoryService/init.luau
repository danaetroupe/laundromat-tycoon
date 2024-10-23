local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ObjectData = require(ReplicatedStorage.Data.ObjectData)

local InventoryEvents = ReplicatedStorage.Events.InventoryEvents

local isServer = RunService.IsServer()

type Object = ObjectData.Object

local InventoryService = {}

-- Gets all objects in inventory 
function InventoryService.GetInventory() : {Object}
    if not isServer then
        return InventoryEvents.GetInventory:FireServer()
    else
        print("Cannot retreive inventory from client")
    end
end