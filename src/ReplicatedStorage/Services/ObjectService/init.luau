-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)

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
function ObjectService.CreateNew(name : string) : Object
    -- runs on client
    local data : Object = table.clone(Objects.GetObject(name))
    local model = ReplicatedStorage.Assets.Objects:FindFirstChild(data["assetName"], true)
    data.model = ModelService.CreateOnServer(model)
    return data
end

function ObjectService.CreateHighlight(model : Model, color : Color3) : Highlight
    -- Delete existing highlight if exists
    local highlight = model:FindFirstChildOfClass("Highlight")
    if not highlight then 
         -- Create new highlight
        highlight = Instance.new('Highlight')
        highlight.Parent = model
        highlight.Adornee = model
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1,1,1)
        highlight.OutlineTransparency = 0
    end
    -- Set color
    highlight.FillColor = color
    return highlight
end

return ObjectService