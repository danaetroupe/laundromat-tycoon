local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)
local ObjectService = require(ReplicatedStorage.Services.ObjectService)
local InteractableService = require(ReplicatedStorage.Services.ObjectService.InteractableService)
local UIService = require(ReplicatedStorage.Services.UIService)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)

type Object = ObjectData.Object
type InteractableObject = ObjectData.InteractableObject

-- Varaibles
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local objName : string = nil
local rotation : number = 0
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil
local objectData : Object = nil
local isBuilding : BoolValue = nil
local isEditing : BoolValue = nil
local moveObj : Model = nil

local ROTATE = "Rotate"
local QUIT = "Quit"
local PLACE = "Place"
local MOUSEUP = "TouchEnded"

local PlaceObject = {}

-- Create mobile buttons
local function _createMobileButtons() : Frame
    local frame = Instance.new("Frame")
    frame.Name = "ObjectEditor_Mobile"
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 1
    frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.fromScale(0.1, 0.1)
    frame.SizeConstraint = Enum.SizeConstraint.RelativeYY

    local place = Instance.new("ImageButton")
    place.Name = "Place"
    place.AnchorPoint = Vector2.new(0, 1)
    place.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    place.BackgroundTransparency = 1
    place.BorderColor3 = Color3.fromRGB(0, 0, 0)
    place.BorderSizePixel = 0
    place.Image = "rbxassetid://115789813803218"
    place.LayoutOrder = 1
    place.Size = UDim2.fromScale(1, 1)
    place.Parent = frame

    local rotate = Instance.new("ImageButton")
    rotate.Name = "Rotate"
    rotate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rotate.BackgroundTransparency = 1
    rotate.BorderColor3 = Color3.fromRGB(0, 0, 0)
    rotate.BorderSizePixel = 0
    rotate.Image = "rbxassetid://101527014073084"
    rotate.LayoutOrder = 1
    rotate.Position = UDim2.fromScale(1, 0)
    rotate.Size = UDim2.fromScale(1, 1)
    rotate.Parent = frame

    local quit = Instance.new("ImageButton")
    quit.Name = "Quit"
    quit.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    quit.BackgroundTransparency = 1
    quit.BorderColor3 = Color3.fromRGB(0, 0, 0)
    quit.BorderSizePixel = 0
    quit.Image = "rbxassetid://90664024735834"
    quit.LayoutOrder = 6
    quit.Position = UDim2.fromScale(0, 1)
    quit.Size = UDim2.fromScale(1, 1)
    quit.Parent = frame

    local move = Instance.new("ImageButton")
    move.Name = "Move"
    move.AnchorPoint = Vector2.new(0.5, 0.5)
    move.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    move.BackgroundTransparency = 1
    move.BorderColor3 = Color3.fromRGB(0, 0, 0)
    move.BorderSizePixel = 0
    move.Image = "rbxassetid://116198684807917"
    move.Position = UDim2.fromScale(0.5, 0.5)
    move.Size = UDim2.fromScale(1, 1)
    move.Parent = frame

    local inventory = Instance.new("ImageButton")
    inventory.Name = "Inventory"
    inventory.AnchorPoint = Vector2.new(1, 0)
    inventory.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inventory.BackgroundTransparency = 1
    inventory.BorderColor3 = Color3.fromRGB(0, 0, 0)
    inventory.BorderSizePixel = 0
    inventory.Image = "rbxassetid://139137859541107"
    inventory.LayoutOrder = 2
    inventory.Size = UDim2.fromScale(1, 1)
    inventory.Parent = frame

    return frame
end

local function createNewObj()
    objectData = ObjectService.CreateNew(objName)
end

local function show(cf : CFrame)
    cf = cf or PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.Position, rotation)
    currModel:PivotTo(cf)
    local color = if PlacementService.IsColliding(currModel) then Color3.new(1,0,0) else Color3.new(0,1,0)
    ObjectService.CreateHighlight(currModel, color)
end

-- End object placement
function PlaceObject.quit()
    placeActive = false
    if currModel then 
        currModel:Destroy() 
    end
    rotation = 0
    ContextActionService:UnbindAction(PLACE)
    ContextActionService:UnbindAction(ROTATE)
    ContextActionService:UnbindAction(QUIT)
    Mouse.TargetFilter = nil
    moveObj = nil
    objectData = nil

    isBuilding.Value = false
end

local function handleInput(name, userInputState, _input)
    if userInputState ~= Enum.UserInputState.Begin then return end
    -- Handle rotations
    if name == ROTATE then
        rotation = rotation + math.pi/2
        show()
    -- Exit placement mode
    elseif name == QUIT then
        PlaceObject.quit()
    -- Handle placement
    elseif name == PLACE then
        -- Check object can be placed
        if PlacementService.IsColliding(currModel) then return end
        if not isEditing.Value and not PlayerService.MakePurchase(LocalPlayer, objectData.cost) then return end
        local model = if isEditing.Value then moveObj else ObjectService.GetModel(objectData)
        PlacementService.Place(model, currModel.PrimaryPart.CFrame, basePart)
        PlaceObject.InitEditObject(model)
        -- Check if object is interactable
        if objectData and objectData.state then 
            --Create proximity prompt
            InteractableService.CreatePrompt(objectData)
        end
        -- Reset data/create new object
        if not isEditing.Value then
            createNewObj()
            show()
        else
            PlaceObject.quit()
        end
    elseif name == MOUSEUP then
        placeActive = false
        ContextActionService:UnbindAction(MOUSEUP)
    else
        print(name.. " not recognized.")
    end
end

-- Run update curr model each frame
RunService.RenderStepped:Connect(function(_dt)
    if placeActive then
        show()
    end
end)

-- Handle mobile input
local function showButtons()
    local mobileButtons = _createMobileButtons()
    mobileButtons.Parent = UIService.createScope(mobileButtons)

    -- Bind position to object position
    RunService:BindToRenderStep("FrameMovement", 0, function()
        local screenPosition: Vector2 = Camera:WorldToScreenPoint(currModel.PrimaryPart.CFrame.Position)
        mobileButtons.Position = UDim2.fromOffset(screenPosition.X, screenPosition.Y)
    end)

    local placeButton : ImageButton = mobileButtons:FindFirstChild("Place")
    local rotateButton : ImageButton = mobileButtons:FindFirstChild("Rotate")
    local moveButton : ImageButton = mobileButtons:FindFirstChild("Move")
    local quitButton : ImageButton = mobileButtons:FindFirstChild("Quit")
    local inventoryButton : ImageButton = mobileButtons:FindFirstChild("Inventory")

    -- Press button to place
    placeButton.Activated:Connect(function()
        handleInput(PLACE, Enum.UserInputState.Begin)
    end)

    -- Move press determines if placing is active
    moveButton.MouseButton1Down:Connect(function()
        placeActive = true
    end)

    -- If player removes touch, stop tracking 
    UserInputService.InputEnded:Connect(function(input, _gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            placeActive = false
        end
    end)

    -- Bind button to rotate function
    rotateButton.Activated:Connect(function()
        handleInput(ROTATE, Enum.UserInputState.Begin)
    end)

    -- Move object to inventory
    inventoryButton.Activated:Connect(function()
        print('This button has not been implemented.')
    end)

    -- Unbind render step and destory frame
    quitButton.Activated:Connect(function()
        RunService:UnbindFromRenderStep("FrameMovement")
        mobileButtons:Destroy()
        handleInput(QUIT, Enum.UserInputState.Begin)
    end)
end

function PlaceObject.InitEditObject(object : Model) 
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.Parent = object

    -- Check for hover
    clickDetector.MouseHoverEnter:Connect(function()
        if not isEditing.Value then return end
        local highlight = ObjectService.CreateHighlight(object, Color3.new(1,1,1))
        clickDetector.MouseHoverLeave:Connect(function()
            highlight:Destroy()
        end)
    end)

    -- Check for start moving
    clickDetector.MouseClick:Connect(function()
        if not isEditing.Value then return end
        isEditing.Value = true
        moveObj = object
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
        Mouse.TargetFilter = basePart.BaseObjects
        currModel = object:Clone()
        currModel.Parent = Mouse.TargetFilter

        -- Bind actions 
        ContextActionService:BindAction(ROTATE, handleInput, false, Enum.KeyCode.R)
        ContextActionService:BindAction(QUIT, handleInput, false, Enum.KeyCode.Q)
        ContextActionService:BindAction(PLACE, handleInput, false, Enum.UserInputType.MouseButton1) 

        -- Enable mobile buttons
        if UserInputService.TouchEnabled then 
            -- Place object
            local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, LocalPlayer.Character.HumanoidRootPart.CFrame.Position + Vector3.new(4, 0, 0), rotation)
            show(cf)
            showButtons() -- Show buttons
        else
            -- Only set placeactive always true on computer
            placeActive = true
        end
    end)
end

function PlaceObject.Init(button : ImageButton, objectName : string, buildValue : BoolValue, editValue : BoolValue) -- Gives functionality to "Place" dev button
    isBuilding = buildValue
    isEditing = editValue
    button.Activated:Connect(function()
        -- Delete existing values
        handleInput(QUIT, Enum.UserInputState.Begin)
        isBuilding.Value = true
        -- Create new object
        objName = objectName
        createNewObj()
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
        Mouse.TargetFilter = basePart.BaseObjects

        currModel = objectData.model:Clone()
        currModel.Parent = Mouse.TargetFilter

        -- Bind actions 
        ContextActionService:BindAction(ROTATE, handleInput, false, Enum.KeyCode.R)
        ContextActionService:BindAction(QUIT, handleInput, false, Enum.KeyCode.Q)
        ContextActionService:BindAction(PLACE, handleInput, false, Enum.UserInputType.MouseButton1) 

        -- Enable mobile buttons
        if UserInputService.TouchEnabled then 
            -- Place object
            local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, LocalPlayer.Character.HumanoidRootPart.CFrame.Position + Vector3.new(4, 0, 0), rotation)
            show(cf)
            showButtons() -- Show buttons
        else
            -- Only set placeactive always true on computer
            placeActive = true
        end
    end)
end

return PlaceObject