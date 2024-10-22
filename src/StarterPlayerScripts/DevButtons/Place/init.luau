local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

local ObjectData = require(ReplicatedStorage.Data.ObjectData)
--local PlacementEvents = ReplicatedStorage.Events.PlacementEvents

local LocalPlayer = Players.LocalPlayer
type Object = ObjectData.Object

local TESTOBJECT : Model = ReplicatedStorage.Assets.Objects.washingmachine --[[
    change this to whichever asset you want to test
    this should get passed in as clone model in player inventory 
    ]]
local Mouse = LocalPlayer:GetMouse()

local rotation : number = 0
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil

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
            print('Mouse clicked')
            if not PlacementService.IsColliding(currModel) then
                PlacementService.Place(TESTOBJECT, PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation))
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

return function(button : TextButton, object : Object) -- Gives functionality to "Place" dev button
    button.Activated:Connect(function()
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
        Mouse.TargetFilter = basePart.BaseObjects
        placeActive = true

        ContextActionService:BindAction(PLACE, handleInput, false, Enum.UserInputType.MouseButton1)
        currModel = TESTOBJECT:Clone()
        currModel.Parent = Mouse.TargetFilter   
    end)
end