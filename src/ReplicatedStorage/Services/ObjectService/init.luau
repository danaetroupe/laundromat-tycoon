-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunSerivce = game:GetService("RunService")

-- Modules
local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)

-- Constants

-- Events
local ObjectService = {}

-- Returns new data table of object name
function ObjectService.CreateNew(name : string, player : Player)
    local data = ObjectData.Get(name)
    data = table.clone(data)
    local model = ReplicatedStorage.Assets.Objects:FindFirstChild(data["model"], true)
    data["model"] = ModelService.CreateOnServer(model, PlayerService.GetTempFolder(player))
    return data
end

-- Updates state and creates interaction to reflect state
function ObjectService.UpdateStatus(data : table, status : string)
    data["status"] = status
end

function ObjectService.GetModel(data : table) : Model
    return data["model"]
end

-- Get names of all the objects
function ObjectService.GetNames() : table
    return ObjectData:GetObjectNames()
end

-- Given a data table, get the visual object name
function ObjectService.GetName(data : table) : string
    return data["name"]
end

-- Changes state
function ObjectService.ChangeState(data : table) : nil
    
end

return ObjectService