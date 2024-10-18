-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunSerivce = game:GetService("RunService")

-- Modules
local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)
local ObjectState = require(ReplicatedStorage.Data.StatesData.object)

-- Constants


-- Events
local ObjectService = {}

-- Returns new data table of object name
function ObjectService.CreateNew(name : string, player : Player)
    local data = ObjectData.Get(name)
    data = table.clone(data)
    local model = ReplicatedStorage.Assets.Objects:FindFirstChild(data["model"], true)
    data["model"] = ModelService.CreateOnServer(model, PlayerService.GetTempFolder(player))

    -- Create a proximity prompt for interactions
    local prompt = Instance.new("ProximityPrompt")
    prompt.Parent = data["model"]
    prompt.Enabled = false
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

-- Run object cycle
function ObjectService.RunCycle(object : table) : bool
    -- Check for player key

    -- Check player key is dirty if washing machine or clean if dryer

    -- Check that object coin count + profit < maxCoinCount

    -- If all of these checks are true, switch state

    -- Disable proximity prompt

    -- Show time remaining using cycleTime
end

return ObjectService