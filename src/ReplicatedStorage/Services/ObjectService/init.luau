-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules
local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)
local ToolService = require(ReplicatedStorage.Services.ToolService)
local ObjectStates = require(ReplicatedStorage.Data.StatesData.ObjectStates)
local Types = require(ReplicatedStorage.Data.Types)

-- Constants
type Object = Types.Object
type Tool = Types.Tool
type MachineState = ObjectStates.MachineState

local isServer = RunService:IsServer()
local LocalPlayer = Players.LocalPlayer

-- Events
local ObjectService = {}

-- GET PROPERTIES --------------------------------------------------------------------
-- Get object state
function ObjectService.GetState(object : Object) : ObjectStates.ObjectState
    return object["state"]
end

-- Gets object model
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


-- CHANGE PROPERTY -------------------------------------------------------------------
-- Updates state and creates interaction to reflect state
function ObjectService.UpdateStatus(data : table, status : string)
    data["status"] = status
end


-- GAME FUNCTIONALITY ----------------------------------------------------------------
-- Returns new data table of object name
function ObjectService.CreateNew(name : string, player : Player)
    local data : Object = ObjectData.Get(name)
    data = table.clone(data)
    local model = ReplicatedStorage.Assets.Objects:FindFirstChild(data["assetName"], true)
    data["model"] = ModelService.CreateOnServer(model, PlayerService.GetTempFolder(player))

    -- Create a proximity prompt for interactions
    local prompt = Instance.new("ProximityPrompt")
    prompt.Parent = data["model"]
    prompt.Enabled = false
    return data
end

-- Run object cycle
function ObjectService.RunCycle(object : Object) : bool
    -- Check for player key
    local objectState : MachineState = ObjectService.GetState(object)
    local key = PlayerService.RequestKey(LocalPlayer)
    local keyState = ToolService.GetState(key)

    -- Show time remaining using cycleTime
    if object.name == "Washing Machine" then
        if objectState == "In Progress" then
            print("machine in progress cannot interact.")
        elseif objectState == "Empty" then
            if keyState == "Dirty" then
                object["state"] = "In Progress"
                ToolService.ChangeState(key, "Clean")
                for time = object.cycleTime, 0, -1 do 
                    object.timeRemaining = time
                    print(time)
                    task.wait(1)
                end
                object["state"] = "Complete"
            else
                print(keyState.. " does not work with washing machine.")
            end
        elseif objectState == "Complete" then
            if not keyState then
                -- do unload? 
                object["state"] = "Empty"
            end
        end
        -- check for object state. if empty, check for key == dirty
        -- if complete check for no key
    elseif object.Name == "Dryer" then
        -- if empty and key == clean then load
        -- if complete check for no key
        continue
    else
        error(object.Name.. " not recognized for proximity prompt creation.")
    end
end

return ObjectService