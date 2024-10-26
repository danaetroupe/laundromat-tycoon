local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)
local ObjectService = require(ReplicatedStorage.Services.ObjectService)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)

local PlayerEvents = ReplicatedStorage.Events.PlayerEvents
--local PlacementEvents = ReplicatedStorage.Events.PlacementEvents

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local rotation : number = 0
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil

type Object = ObjectData.Object
type InteractableObject = ObjectData.InteractableObject
local objectData : Object = nil

local ROTATE = "Rotate"
local QUIT = "Quit"
local PLACE = "Place"

local function handleInput(name, userInputState, _input)
    if userInputState == Enum.UserInputState.Begin then
        if name == ROTATE then
            rotation = rotation + math.pi/2
        elseif name == QUIT then
            currModel:Destroy()
            rotation = 0
            placeActive = false
            ContextActionService:UnbindAction(PLACE)
            Mouse.TargetFilter = nil
        elseif name == PLACE then
            if not PlacementService.IsColliding(currModel) and PlayerService.MakePurchase(LocalPlayer, objectData.cost) then
                PlacementService.Place(
                    ObjectService.GetModel(objectData), -- Server model
                    PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation) -- Get CFrame
            )
                -- Check if object is interactable
                if objectData.state then 
                    -- Reset data 
                    local prompt = Instance.new("ProximityPrompt")
                    prompt.ObjectText = ObjectService.GetName(objectData)
                    prompt.Parent = ObjectService.GetModel(objectData)
    
                    local clone : InteractableObject = objectData
                    clone.prompt = prompt
    
                    prompt.Triggered:Connect(function(trigger)
                        local success = ObjectService.RunCycle(clone)
                        success = if success then "True" else "False"
                    end)
                end
            end
        end
    end
end


-- Bind actions 
ContextActionService:BindAction(ROTATE, handleInput, true, Enum.KeyCode.R)
ContextActionService:BindAction(QUIT, handleInput, true, Enum.KeyCode.Q)

RunService.RenderStepped:Connect(function(dt)
    if placeActive then
        local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation)
        currModel:PivotTo(cf)
    end
end)

return function(button : TextButton, objectName : string) -- Gives functionality to "Place" dev button
    button.Activated:Connect(function()
        objectData = ObjectService.CreateNew(objectName, LocalPlayer)
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
        Mouse.TargetFilter = basePart.BaseObjects
        placeActive = true

        ContextActionService:BindAction(PLACE, handleInput, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
        currModel = ObjectService.GetModel(objectData):Clone()
        currModel.Parent = Mouse.TargetFilter
    end)
end