-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ToolService = require(ReplicatedStorage.Services.ToolService)

-- Data
local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local ToolData = require(ReplicatedStorage.Data.ToolData)

-- Events

-- Types
type Object = ObjectData.Object
type Interactable = ObjectData.InteractableObject
type ToolInfo = ToolData.ToolInfo
type MachineState = ObjectData.MachineState
type LaundryState = ToolData.LaundryState

-- Constants
local washingDecal = "rbxassetid://136582297962433"
local clothesDecal = "rbxassetid://71280947937677"
local LocalPlayer = Players.LocalPlayer
local ROTATION_SPEED = 360


local InteractableService = {}

local function timer(object : Interactable) 
    object.prompt.Enabled = false
    for i = object.cycleTime, 0, -1 do
        object.timeRemaining = i
        task.wait(1)
    end
    object.state = "Complete"
    object.prompt.Enabled = true
end

function InteractableService.Display(object : Interactable)
    local display = object.model:FindFirstChild("Display")
    if not display then 
        timer(object)
        return
    end -- Folding table does not have a display
    
    local time = coroutine.create(timer)
    coroutine.resume(time, object)

    local part : Part = display.Part
    local decal : Decal = part.Decal
    local text : TextLabel = display.DisplayGui.TextLabel
    
    decal.Transparency = 0
    decal.Texture = if object.name == "Washing Machine" then washingDecal else clothesDecal
    while object.state == "In Progress" do
        text.Text = object.timeRemaining
         -- Wait for the next frame
        task.wait(0.01) -- Adjust this to control the smoothness of the rotation (default ~30 frames per second)
        -- Create a CFrame rotation (rotating around the Y-axis)
        part.CFrame = part.CFrame * CFrame.Angles(math.rad(ROTATION_SPEED) * 0.01, 0, 0)
    end
end

function InteractableService.ClearDisplay(object)
    local display = object.model:FindFirstChild("Display")
    if not display then return end

    display.Part.Decal.Transparency = 1
    display.DisplayGui.TextLabel.Text = ""
end

function InteractableService.RunCycle(object : Interactable) : boolean
    -- Check for player key
    local objectState : MachineState = object.state
    local key = PlayerService.GetKey(LocalPlayer)
    local keyState = if key then key.state else nil

    -- Check for machine in progress.. do nothing
    if objectState == "In Progress" then
        return false
    -- If machine is empty, check for expectedLaundry state and load machine
    elseif objectState == "Empty" then
        if key and keyState == object.expectedLaundryState then -- if empty and laundry dirty, start cycle
            object["state"] = "In Progress"
            ToolService.DestroyModel(key)
            PlayerService.ClearKey()
            InteractableService.Display(object)
        else
            if keyState then
                print(keyState.. " laundry does not go in ".. object.name)
            else
                print("Need ".. object.expectedLaundryState " laundry for ".. object.name)
            end
            return false
        end
    -- If complete, make sure no key exists 
    elseif objectState == "Complete" then
        if not key then
            InteractableService.ClearDisplay(object)
            key = ToolService.GiveTool(LocalPlayer, "laundrybasket")
            ToolService.ChangeState(key, object.nextState)
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

-- Create proximity prompt
function InteractableService.CreatePrompt(object : Interactable)
    object.prompt = Instance.new("ProximityPrompt")
    object.prompt.ObjectText = object.name
    object.prompt.Parent = object.model
    

    object.prompt.Triggered:Connect(function(trigger)
        InteractableService.RunCycle(object)
    end)
end

return InteractableService