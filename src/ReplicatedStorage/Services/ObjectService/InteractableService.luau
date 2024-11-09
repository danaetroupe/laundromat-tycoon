-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ToolService = require(ReplicatedStorage.Services.ToolService)
local UIService = require(ReplicatedStorage.Services.UIService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

-- Data
local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local ToolData = require(ReplicatedStorage.Data.ToolData)

-- UI
local Messages = require(ReplicatedStorage.UI.Messages)

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

local function timer(object: Interactable)
	object.prompt.Enabled = false
	for i = object.cycleTime, 0, -1 do
		object.timeRemaining = i
		task.wait(1)
	end
	object.state = "Complete"
	object.prompt.Enabled = true
end

-- Create display if machine has display
function InteractableService.Display(object: Interactable)
	local display = object.model:FindFirstChild("Display")
	if not display then
		timer(object)
		return
	end -- Folding table does not have a display

	local time = coroutine.create(timer)
	coroutine.resume(time, object)

	local part: Part = display.Part
	local decal: Decal = part.Decal
	local text: TextLabel = display.DisplayGui.TextLabel

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

-- Clear machinde display if display
function InteractableService.ClearDisplay(object)
	local display = object.model:FindFirstChild("Display")
	if not display then
		return
	end

	display.Part.Decal.Transparency = 1
	display.DisplayGui.TextLabel.Text = ""
end

function InteractableService.TableInteract(table : Interactable) : boolean
	-- Check for player key
    local objectState : MachineState = table.state
    local key = PlayerService.GetKey(LocalPlayer)
    local keyState = if key then key.state else nil
    local message

	-- Check for machine in progress.. do nothing
	if objectState == "In Progress" then
		return error("Table can never be in progress lol")
	-- If machine is empty, check for expectedLaundry state and load machine
	elseif objectState == "Empty" then
		if key and keyState == table.expectedLaundryState then -- if empty and laundry dirty, start cycle
			table.state = "Complete"
			LocalPlayer.Character.Humanoid:UnequipTools()
			key.model.Parent = workspace
			local cf = PlacementService.CalcPlacementCFrame(table.model:FindFirstChild("Surface"), 
				key.model, 
				table.model.PrimaryPart.CFrame.Position + Vector3.new(0,table.model.PrimaryPart.Size.Y/2,0),
				0)
			key.model:PivotTo(cf)
			table.tool = key
			PlayerService.ClearKey()
			table.prompt.HoldDuration = 10
		else
			if keyState then
				message = "Cannot fold " ..keyState.. " laundry."
			else
				message = "Need laundry for ".. table.name
			end
		end
	-- If complete, make sure no key exists
	elseif objectState == "Complete" then
		if not key then
			key = ToolService.EquipExistingTool(LocalPlayer, table.tool, table.nextState)
			table.tool = nil
			table.state = "Empty"
			table.prompt.HoldDuration = 0
			return PlayerService.AssignKey(key)
		else
			message = "Table already has laundry. Please fold first."
		end
	else
		error("Object state not recognized: " .. objectState)
		return false
	end
	-- Show message if applicable
    if message then 
        local messageFrame = Messages.createMessage(message)
		UIService.createScope(messageFrame)
		task.delay(3, function()
			Messages.fade(messageFrame, 0)
		end)
		return false
    end

	return true
end

-- Run machine cycle if applicable
function InteractableService.RunCycle(object : Interactable) : boolean
	if object.assetName == "foldingtable" then return InteractableService.TableInteract(object) end
    -- Check for player key
    local objectState : MachineState = object.state
    local key = PlayerService.GetKey(LocalPlayer)
    local keyState = if key then key.state else nil
    local message

	-- Check for machine in progress.. do nothing
	if objectState == "In Progress" then
		return false
	-- If machine is empty, check for expectedLaundry state and load machine
	elseif objectState == "Empty" then
		if key and keyState == object.expectedLaundryState then -- if empty and laundry dirty, start cycle
			object["state"] = "In Progress"
			ToolService.DestroyModel(key)
			object.tool = key
			PlayerService.ClearKey()
			InteractableService.Display(object)
		else
			if keyState then
				message = keyState.. " laundry does not go in ".. object.name
			else
				message = "Need ".. object.expectedLaundryState " laundry for ".. object.name
			end
		end
	-- If complete, make sure no key exists
	elseif objectState == "Complete" then
		if not key then
			InteractableService.ClearDisplay(object)
			key = ToolService.EquipExistingTool(LocalPlayer, object.tool, object.nextState)
			object.tool = nil
			object["state"] = "Empty"
			return PlayerService.AssignKey(key)
		else
			message = "Machine already has laundry. Please unload."
		end
	else
		error("Object state not recognized: " .. objectState)
		return false
	end
	-- Show message if applicable
    if message then 
        local messageFrame = Messages.createMessage(message)
		UIService.createScope(messageFrame)
		task.delay(3, function()
			Messages.fade(messageFrame, 0)
		end)
		return false
    end

	return true
end

-- Create proximity prompt
function InteractableService.CreatePrompt(object: Interactable)
	object.prompt = Instance.new("ProximityPrompt")
	object.prompt.ObjectText = object.name
	object.prompt.Parent = object.model

	object.prompt.Triggered:Connect(function(_trigger)
		InteractableService.RunCycle(object)
	end)
end

return InteractableService
