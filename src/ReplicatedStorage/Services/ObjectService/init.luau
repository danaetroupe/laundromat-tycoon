-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)
local ToolService = require(ReplicatedStorage.Services.ToolService)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local ToolData = require(ReplicatedStorage.Data.ToolData)
local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)

-- Events

-- Constants
type Object = ObjectData.Object
type ToolInfo = ToolData.ToolInfo
type MachineState = ObjectData.MachineState
type LaundryState = ToolData.LaundryState

--local isServer = RunService:IsServer()
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


-- CHANGE PROPERTY -------------------------------------------------------------------
-- Updates state and creates interaction to reflect state
function ObjectService.UpdateStatus(data : table, status : string)
    data["status"] = status
end


-- GAME FUNCTIONALITY ----------------------------------------------------------------
-- Returns new data table of object name
function ObjectService.CreateNew(name : string, player : Player) 
    -- runs on client
    local data : Object = Objects.GetObject(name)
    data = table.clone(data)
    local model = ReplicatedStorage.Assets.Objects:FindFirstChild(data["assetName"], true)
    data["model"] = ModelService.CreateOnServer(model, PlayerService.GetTempFolder(player))

    return data
end

-- Run object cycle
function ObjectService.RunCycle(object : Object) : boolean
    -- Check for player key
    local objectState : MachineState = ObjectService.GetState(object)
    local key = PlayerService.RequestKey(LocalPlayer)
    local keyState = if key then ToolService.GetState(key) else nil

    local expectedLaundryState = nil
    local nextState = nil
    -- Get expected laundry state
    if object.name == "Washing Machine" then
        expectedLaundryState = "Dirty"
        nextState = "Clean"
    elseif object.name == "Dryer" then
        expectedLaundryState = "Clean"
        nextState = "Dry"
    elseif object.name == "Folding Table" then
        expectedLaundryState = "Dry"
        nextState = "Ready"
    else
        error("Machine not recognized for state: " ..object.name)
    end

    -- Check for machine in progress.. do nothing
    if objectState == "In Progress" then
        print("machine in progress cannot interact.")
        return false
    -- If machine is empty, check for expectedLaundry state and load machine
    elseif objectState == "Empty" then
        if key and keyState == expectedLaundryState then -- if empty and laundry dirty, start cycle
            print('Starting '.. object.name)
            object["state"] = "In Progress"
            ToolService.DestroyModel(key)
            PlayerService.ClearKey()
            for time = 5, 0, -1 do -- !! should be object.cycleTime but using 5 for testing
                object.timeRemaining = time
                print(time)
                task.wait(1)
            end
            -- When cycle is complete, change laundry + object state
            --ToolService.ChangeState(key, nextState)
            object["state"] = "Complete" -- when done move to complete
        else
            print("laundry does not load in ".. object.name)
            return false
        end
    -- If complete, make sure no key exists 
    elseif objectState == "Complete" then
        if not key then
            key = ToolService.GiveTool(LocalPlayer, "laundrybasket")
            ToolService.ChangeState(key, nextState)
            object["state"] = "Empty"
            return PlayerService.AssignKey(key)
        else
            print("Cannot load laundry with existing key.")
            return false
        end
    else
        error("Object state not recognized: ".. objectState)
        return false
    end
    return true
end

return ObjectService