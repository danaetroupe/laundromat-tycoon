-- Service4s
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules
local ObjectService = require(ReplicatedStorage.Services.ObjectService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)

-- Data
local ObjectData = require(ReplicatedStorage.Data.ObjectData)

-- Events
local InventoryEvents = ReplicatedStorage.Events.InventoryEvents

-- Types
type Object = ObjectData.Object

-- Constants
local isServer = RunService:IsServer()

local InventoryService = {}

-- Gets all objects in inventory 
function InventoryService.GetInventory() : {Object}?
    if not isServer then
        return InventoryEvents.GetInventory:FireServer()
    else
        print("Trying to retreive inventory from client")
        return nil
    end
end

-- Returns false if cannot buy object, object if it can
function InventoryService.BuyItem(itemName : string, player : Player) : Object | boolean
    if isServer then
        local object = ObjectService.CreateNew(itemName, player)
        return if PlayerService.MakePurchase(object.cost) then object else false
    else
        return InventoryEvents.AddToInventory:InvokeServer(itemName)
    end
end

return InventoryService