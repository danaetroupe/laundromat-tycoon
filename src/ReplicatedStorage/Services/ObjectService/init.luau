-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)
local ToolService = require(ReplicatedStorage.Services.ToolService)
local InteractableService = require(script.InteractableService)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local ToolData = require(ReplicatedStorage.Data.ToolData)
local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)

-- Events

-- Constants
type Object = ObjectData.Object
type Interactable = ObjectData.InteractableObject
type ToolInfo = ToolData.ToolInfo
type MachineState = ObjectData.MachineState
type LaundryState = ToolData.LaundryState

local LocalPlayer = Players.LocalPlayer

-- Events
local ObjectService = {}

-- GET PROPERTIES --------------------------------------------------------------------
-- Get object state
function ObjectService.GetState(object : Object) : MachineState
    return object["state"]
end

-- Gets object model
function ObjectService.GetModel(data : table) : Model
    return data["model"]
end

-- Get names of all the objects
function ObjectService.GetNames() : table
    return Objects.GetObjectNames()
end

-- Given a data table, get the visual object name
function ObjectService.GetName(data : table) : string
    return data["name"]
end


-- GAME FUNCTIONALITY ----------------------------------------------------------------
-- Returns new data table of object name
function ObjectService.CreateNew(name : string, player : Player) 
    -- runs on client
    local data : Object = Objects.GetObject(name)
    data = table.clone(data)
    local model = ReplicatedStorage.Assets.Objects:FindFirstChild(data["assetName"], true)
    data.model = ModelService.CreateOnServer(model, PlayerService.GetTempFolder(player))
    return data
end

return ObjectService