-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local InventoryService = require(ReplicatedStorage.Services.InventoryService)

-- Data
local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)

-- Types
type Object = ObjectData.Object

return function(icon : Frame, frame : Frame)
    -- Render inventory icons
    -- Link to place object
end