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

local Object : Model = nil
local Mouse = LocalPlayer:GetMouse()

local rotation : number = 0
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil

type Object = ObjectData.Object
type InteractableObject = ObjectData.InteractableObject
local objInfo : Object = nil

local ROTATE = "Rotate"
local QUIT = "Quit"
local PLACE = "Place"

local function handleInput(name, userInputState, input)
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
            if not PlacementService.IsColliding(currModel) then
                PlacementService.Place(Object, PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation))
                -- Check if object is interactable
                if objInfo.state then 
                    local prompt = Instance.new("ProximityPrompt")
                    prompt.ObjectText = ObjectService.GetName(objInfo)
                    prompt.Parent = ObjectService.GetModel(objInfo)
    
                    local clone : InteractableObject = objInfo
                    clone.prompt = prompt
    
                    prompt.Triggered:Connect(function(trigger)
                        local success = ObjectService.RunCycle(clone)
                        success = if success then "True" else "False"
                    end)
                end
                handleInput(QUIT, Enum.UserInputState.Begin, nil)
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

return function(button : TextButton, object : table) -- Gives functionality to "Place" dev button
    button.Activated:Connect(function()
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
        Mouse.TargetFilter = basePart.BaseObjects
        placeActive = true

        ContextActionService:BindAction(PLACE, handleInput, false, Enum.UserInputType.MouseButton1)
        Object = ObjectService.GetModel(object)
        currModel = Object:Clone()
        currModel.Parent = Mouse.TargetFilter
        objInfo = object
    end)
end