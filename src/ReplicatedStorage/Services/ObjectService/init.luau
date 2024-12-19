-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules
local ModelService = require(ReplicatedStorage.Util.ModelService)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local ToolData = require(ReplicatedStorage.Data.ToolData)
local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)

-- Events
local ObjectEvents = ReplicatedStorage.Events.ObjectEvents

-- Types
type Object = ObjectData.Object
type Interactable = ObjectData.InteractableObject
type ToolInfo = ToolData.ToolInfo
type MachineState = ObjectData.MachineState
type LaundryState = ToolData.LaundryState

-- Variables
local isServer = RunService:IsServer()
local LocalPlayer = Players.LocalPlayer

-- Events
local ObjectService = {}
local _Data = {}

-- GET PROPERTIES --------------------------------------------------------------------
-- Get object state
function ObjectService.GetState(object : Object) : MachineState
    return object["state"]
end

-- Gets object model
function ObjectService.GetModel(data : Object) : Model?
    return data.model
end

-- Get names of all the objects
function ObjectService.GetNames() : {string}
    return Objects.GetObjectNames()
end

-- Given a data table, get the visual object name
function ObjectService.GetName(data : Object) : string
    return data.name
end


-- GAME FUNCTIONALITY ----------------------------------------------------------------
function ObjectService.CreateNew(name : string, player : Player?) : Object
    if isServer then
        local data : Object = table.clone(Objects.GetObject(name))
        local model = ReplicatedStorage.Assets.Objects:FindFirstChild(data["assetName"], true)
        data.model = ModelService.CreateOnServer(model)
        if not _Data[player] then 
            _Data[player] = {}
        end
        _Data[player][data.name] = data
        return data
    else
        return ObjectEvents.ExecuteOnServer:InvokeServer("CreateNew", name, LocalPlayer)
    end 
end

function ObjectService.AttatchToModel(name : string, player : Player?, model : Model) : Object
    if isServer then
        local data : Object = table.clone(Objects.GetObject(name))
        data.model = model
        if not _Data[player] then 
            _Data[player] = {}
        end
        _Data[player][data.name] = data
        return data
    else
        return ObjectEvents.ExecuteOnServer:InvokeServer("CreateNew", name, LocalPlayer)
    end 
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

-- Execute server function
if isServer then
    ObjectEvents.ExecuteOnServer.OnServerInvoke = function(_player, func, ...)
        return ObjectService[func](...)
    end
end


return ObjectService