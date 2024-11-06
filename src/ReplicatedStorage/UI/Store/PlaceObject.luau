local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)
local ObjectService = require(ReplicatedStorage.Services.ObjectService)
local InteractableService = require(ReplicatedStorage.Services.ObjectService.InteractableService)

local Spr = require(ReplicatedStorage.Packages.Spr)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)

type Object = ObjectData.Object
type InteractableObject = ObjectData.InteractableObject

-- Varaibles
local LocalPlayer = Players.LocalPlayer
local MobileButtons = ReplicatedStorage.Assets.UI.ObjectEditor_Mobile
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local objName : string = nil
local rotation : number = 0
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil
local objectData : Object = nil
local buildPanel : Frame = nil

local ROTATE = "Rotate"
local QUIT = "Quit"
local PLACE = "Place"
local MOUSEUP = "TouchEnded"

local PlaceObject = {}

local function createNewObj()
    objectData = ObjectService.CreateNew(objName, LocalPlayer)
end

local function show(cf : CFrame)
    cf = cf or PlacementService.CalcPlacementCFrame(basePart, currModel, currModel.PrimaryPart.CFrame.Position, rotation)
    currModel:PivotTo(cf)
    local color = if PlacementService.IsColliding(currModel) then Color3.new(1,0,0) else Color3.new(0,1,0)
    ObjectService.CreateHighlight(currModel, color)
end

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

    -- Reopen panel if it exists 
    if buildPanel then
        Spr.target(buildPanel.Panel, 1, 1, {
            Position = UDim2.fromScale(0, 0)
        })
            -- Hide keybinds
        Spr.target(buildPanel.Keybinds.Buy, 1, 1, {
                Position = UDim2.fromScale(-0.1, 0.5)
        })
    end
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
        if PlacementService.IsColliding(currModel) or not PlayerService.MakePurchase(objectData.cost) then return end
        local model = ObjectService.GetModel(objectData)
        PlacementService.Place(model, currModel.PrimaryPart.CFrame, basePart)
        -- Check if object is interactable
        if objectData.state then 
            --Create proximity prompt
            InteractableService.CreatePrompt(objectData)
        end
        -- Reset data/create new object
        createNewObj()
        show()
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
    local frame : Frame = MobileButtons:Clone()
    frame.Parent = buildPanel.Keybinds

    -- Bind position to object position
    RunService:BindToRenderStep("FrameMovement", 0, function()
        local screenPosition: Vector2 = Camera:WorldToScreenPoint(currModel.PrimaryPart.CFrame.Position)
        frame.Position = UDim2.fromOffset(screenPosition.X, screenPosition.Y)
    end)

    local placeButton : ImageButton = frame:FindFirstChild("Place")
    local rotateButton : ImageButton = frame:FindFirstChild("Rotate")
    local moveButton : ImageButton = frame:FindFirstChild("Move")
    local quitButton : ImageButton = frame:FindFirstChild("Quit")
    local inventoryButton : ImageButton = frame:FindFirstChild("Inventory")

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
        frame:Destroy()
        handleInput(QUIT, Enum.UserInputState.Begin)
    end)
end


function PlaceObject.Init(button : TextButton, objectName : string, panel : Frame) -- Gives functionality to "Place" dev button
    button.Activated:Connect(function()
        -- Delete existing values
        handleInput(QUIT, Enum.UserInputState.Begin)
        -- Create new object
        objName = objectName
        createNewObj()
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
        Mouse.TargetFilter = basePart.BaseObjects

        currModel = objectData.model:Clone()
        currModel.Parent = Mouse.TargetFilter
        buildPanel = panel

        -- Bind actions 
        ContextActionService:BindAction(ROTATE, handleInput, false, Enum.KeyCode.R)
        ContextActionService:BindAction(QUIT, handleInput, false, Enum.KeyCode.Q)
        ContextActionService:BindAction(PLACE, handleInput, false, Enum.UserInputType.MouseButton1) 

        -- Enable mobile buttons
        if UserInputService.TouchEnabled then 
            -- Put close to player
            local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, LocalPlayer.Character.HumanoidRootPart.CFrame.Position + Vector3.new(4, 0, 0), rotation)
            show(cf)
            -- Show buttons
            showButtons()
        else
            -- Only set placeactive always true on computer
            placeActive = true
            -- Show keybinds
            local keybindPanel : Frame = panel.Keybinds.Buy
            Spr.target(keybindPanel, 1, 1, {
                Position = UDim2.fromScale(0, 0.5)
            })
        end

        -- Close build panel
        Spr.target(buildPanel.Panel, 1, 1, {
            Position = UDim2.fromScale(0, -1)
        })
    end)
end

return PlaceObject