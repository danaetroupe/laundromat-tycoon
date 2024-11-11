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
type Storage = ObjectData.Storage
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

function InteractableService._PlaceOnTop(object : Interactable, key : ToolInfo)
	LocalPlayer.Character.Humanoid:UnequipTools()
	key.model.Parent = workspace
	local cf = PlacementService.CalcPlacementCFrame(object.model.PrimaryPart, 
				key.model, 
				object.model.PrimaryPart.CFrame.Position + Vector3.new(0,object.model.PrimaryPart.Size.Y/2,0),
				0)	
	key.model:PivotTo(cf)
	key.model.PrimaryPart.Anchored = true
	object.tool = key
	PlayerService.ClearKey()
end

function InteractableService.TableInteract(tableObj : Interactable) : boolean
	-- Check for player key
    local objectState : MachineState = tableObj.state
    local key = PlayerService.GetKey(LocalPlayer)
    local keyState = if key then key.state else nil
    local message

	-- Check for machine in progress.. do nothing
	if objectState == "In Progress" then
		return error("Table can never be in progress lol")
	-- If machine is empty, check for expectedLaundry state and load machine
	elseif objectState == "Empty" then
		if key and keyState == tableObj.expectedLaundryState then -- if empty and laundry dirty, start cycle
			tableObj.state = "Complete"
			InteractableService._PlaceOnTop(tableObj, key)
			tableObj.prompt.HoldDuration = 5
		else
			if keyState then
				message = "Cannot fold " ..keyState.. " laundry."
			else
				message = "Need laundry for ".. tableObj.name
			end
		end
	-- If complete, make sure no key exists
	elseif objectState == "Complete" then
		if not key then
			tableObj.tool.model.PrimaryPart.Anchored = false
			key = ToolService.EquipExistingTool(LocalPlayer, tableObj.tool, tableObj.nextState)
			tableObj.tool = nil
			tableObj.state = "Empty"
			tableObj.prompt.HoldDuration = 0
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
			object.state = "In Progress"
			InteractableService._PlaceOnTop(object, key)
			InteractableService.Display(object)
		else
			if keyState then
				message = keyState.. " laundry does not go in ".. object.name
			else
				message = "Need ".. object.expectedLaundryState.. " laundry for ".. object.name
			end
		end
	-- If complete, make sure no key exists
	elseif objectState == "Complete" then
		if not key then
			InteractableService.ClearDisplay(object)
			object.tool.model.PrimaryPart.Anchored = false
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
        Messages.showMessage(message)
		return false
    end

	return true
end

-- Run shelf interaction
function InteractableService.Interact(action : string, shelf : Storage) 
	-- Check for player key
    --local objectState : ObjectData.ShelfState = shelf.state
    local key = PlayerService.GetKey(LocalPlayer)
    local message

	-- Check for machine in progress.. do nothing
	if action == "pickup" then
		if not key then 
			for _, spot in shelf.spots do
				if spot.tool then
					spot.tool.model.PrimaryPart.Anchored = false
					key = ToolService.EquipExistingTool(LocalPlayer, spot.tool)
					PlayerService.AssignKey(key)
					spot.tool = nil
					shelf.spotCount -= 1
					break
				end
			end
			shelf.addPrompt.Enabled = true
			if shelf.spotCount == 0 then 
				shelf.takePrompt.Enabled = false
			end
		else
			message = "Cannot pick up item with laundry in hand."
		end
	elseif action == "setdown" then
		if key then
			LocalPlayer.Character.Humanoid:UnequipTools()
			key.model.Parent = workspace
			for _, spot in shelf.spots do
				if not spot.tool then
					local cf = PlacementService.CalcPlacementCFrame(spot.part, key.model, spot.part.CFrame.Position, 0)
					key.model:PivotTo(cf)
					key.model.PrimaryPart.Anchored = true
					spot.tool = key
					shelf.spotCount += 1
					PlayerService.ClearKey()
					break
				end
			end
			shelf.takePrompt.Enabled = true
			-- Check to make sure it isn't full
			if shelf.spotCount == #shelf.spots then
				shelf.addPrompt.Enabled = false
			end
		else
			message = "Do not have an item to set down."
		end
	else
		message = "Action not recognized. GAME ERR"
	end
	-- Show message if applicable
    if message then 
        Messages.showMessage(message)
		return false
    end
end

-- Special case for shelf
function InteractableService.CreateShelfPrompt(shelf : Storage)
	shelf.addPrompt = Instance.new("ProximityPrompt")
	shelf.addPrompt.ActionText = "Set Down"
	shelf.addPrompt.Parent = shelf.model
	shelf.addPrompt.KeyboardKeyCode = Enum.KeyCode.P
	shelf.addPrompt.UIOffset = Vector2.new(0, 80)

	shelf.takePrompt = Instance.new("ProximityPrompt")
	shelf.takePrompt.ActionText = "Pick Up"
	shelf.takePrompt.Parent = shelf.model
	shelf.takePrompt.Enabled = false -- there's nothing to pick up

	for _, item : Part in shelf.model:GetChildren() do
		if item:HasTag("Surface") then
			table.insert(shelf.spots, {
				part = item,
				tool = nil
			})
		end
	end

	shelf.takePrompt.Triggered:Connect(function(_trigger)
		InteractableService.Interact("pickup", shelf)
	end)
	shelf.addPrompt.Triggered:Connect(function(_trigger)
		InteractableService.Interact("setdown", shelf)
	end)
end

-- Create proximity prompt
function InteractableService.CreatePrompt(object: Interactable)
	-- Check if object is storage type
	if object.name == "Shelf" then
		InteractableService.CreateShelfPrompt(object) 
		return 
	end
	object.prompt = Instance.new("ProximityPrompt")
	object.prompt.ObjectText = object.name
	object.prompt.Parent = object.model

	object.prompt.Triggered:Connect(function(_trigger)
		InteractableService.RunCycle(object)
	end)
end

return InteractableService
