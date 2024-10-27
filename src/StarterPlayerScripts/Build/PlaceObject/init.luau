local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)
local ObjectService = require(ReplicatedStorage.Services.ObjectService)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)

type Object = ObjectData.Object
type InteractableObject = ObjectData.InteractableObject

-- Varaibles
local LocalPlayer = Players.LocalPlayer
local MobileButtons = ReplicatedStorage.Assets.UI.ObjectEditor_Mobile
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local rotation : number = 0
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil
local objectData : Object = nil

local ROTATE = "Rotate"
local QUIT = "Quit"
local PLACE = "Place"
local MOUSEUP = "TouchEnded"

local function handleInput(name, userInputState, _input)
    if userInputState ~= Enum.UserInputState.Begin then return end
    -- Handle rotations
    if name == ROTATE then
        rotation = rotation + math.pi/2
    -- Exit placement mode
    elseif name == QUIT then
        placeActive = false
        if currModel then 
            currModel:Destroy() 
        end
        rotation = 0
        ContextActionService:UnbindAction(PLACE)
        ContextActionService:UnbindAction(ROTATE)
        ContextActionService:UnbindAction(QUIT)
        Mouse.TargetFilter = nil
    -- Handle placement
    elseif name == PLACE and not PlacementService.IsColliding(currModel) and PlayerService.MakePurchase(objectData.cost) then
        local model = ObjectService.GetModel(objectData)
        --local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation)
        PlacementService.Place(model, currModel.PrimaryPart.CFrame, basePart)
        -- Check if object is interactable
        if not objectData.state then return end
        -- Reset data 
        local prompt = Instance.new("ProximityPrompt")
        prompt.ObjectText = ObjectService.GetName(objectData)
        prompt.Parent = objectData.model
        
        local interactObjectData : InteractableObject = objectData
        interactObjectData.prompt = prompt

        prompt.Triggered:Connect(function(trigger)
            local success = ObjectService.RunCycle(interactObjectData)
            success = if success then "True" else "False"
        end)
    elseif name == MOUSEUP then
        placeActive = false
        ContextActionService:UnbindAction(MOUSEUP)
    else
        print(name.. " not recognized.")
    end
end

RunService.RenderStepped:Connect(function(dt)
    if placeActive then
        local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.Position, rotation)
        currModel:PivotTo(cf)
    end
end)

-- Handle mobile input
local function showButtons(keybinds : Folder)
    local frame : Frame = MobileButtons:Clone()
    frame.Parent = keybinds

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
        local connection
        connection = Mouse.Button1Up:Connect(function()
            placeActive = false
            connection:Disconnect()
        end)
    end)

    -- Bind button to rotate function
    rotateButton.Activated:Connect(function()
        handleInput(ROTATE, Enum.UserInputState.Begin)
    end)

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


return function(button : TextButton, objectName : string, buildPanel : Frame) -- Gives functionality to "Place" dev button
    button.Activated:Connect(function()
        -- Delete existing values
        handleInput(QUIT, Enum.UserInputState.Begin)
        -- Create new object
        objectData = ObjectService.CreateNew(objectName, LocalPlayer)
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
            -- Put close to player
            local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, LocalPlayer.Character.HumanoidRootPart.CFrame.Position + Vector3.new(4, 0, 0), rotation)
            currModel:PivotTo(cf)
            -- Show buttons
            showButtons(buildPanel.Keybinds)
        else
            -- Only set placeactive always true on computer
            placeActive = true
        end
    end)
end
