-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules

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

return InteractableService