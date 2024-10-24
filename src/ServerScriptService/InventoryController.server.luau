-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local InventoryService = require(ReplicatedStorage.Services.InventoryService)

-- Events
local InventoryEvents = ReplicatedStorage.Events.InventoryEvents

local PlayerInventories = {}

InventoryEvents.AddToInventory.OnServerInvoke = function(player : Player, itemName : string) : boolean
    local object = InventoryService.BuyItem(itemName, player)

    if not object then return false end -- Return false if purchase cannot be made

    -- Create inventory if it doesn't exist
    if not PlayerInventories[player] then
        PlayerInventories[player] = {}
    end
    -- Initalize object table if it doesn't exist    
    if not PlayerInventories[player][object.name] then
        PlayerInventories[player][object.name] = {}
    end
    -- Insert object into inventory
    table.insert(PlayerInventories[player][object.name], object)

    return true
end



