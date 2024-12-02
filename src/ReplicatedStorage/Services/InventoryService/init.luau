-- Service4s
local Players = game:GetService("Players")
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
local LocalPlayer = Players.LocalPlayer

local InventoryService = {}
local _Data = {}

-- Gets all objects in inventory 
function InventoryService.GetInventory(player : Player?) : {Object}?
    if isServer then
        return _Data[player]
    else
        return InventoryEvents.ExecuteOnServer:InvokeServer(LocalPlayer)
    end
end

-- Returns false if cannot buy object, object if it can
function InventoryService.BuyItem(itemName : string, player : Player) : Object | boolean
    if isServer then
        local object = ObjectService.CreateNew(itemName, player)
        return if PlayerService.MakePurchase(player, object.cost) then object else false
    else
        return InventoryEvents.AddToInventory:InvokeServer(itemName)
    end
end

if isServer then
    InventoryEvents.ExecuteOnServer.OnServerInvoke = function(_, func: string, ...: any): ...any
        return InventoryService[func](...)
    end
end

return InventoryService