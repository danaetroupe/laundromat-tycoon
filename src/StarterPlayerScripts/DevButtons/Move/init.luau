local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local selectObj : Model = nil
local rotation : number = 0
local selectActive : boolean = false
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil
local orginParent = nil

local SELECT = "Select"
local QUIT = "Quit"
local PLACE = "Place"

local function handleInput(name, userInputState, input)
    if userInputState == Enum.UserInputState.Begin then
        if name == SELECT then
            selectObj = Mouse.Target.Parent
            if PlayerService.IsBaseObject(LocalPlayer, selectObj) then
                orginParent = selectObj.Parent
                selectObj.Parent = ReplicatedStorage.Temp
                currModel = selectObj:Clone()
                Mouse.TargetFilter = basePart.BaseObjects
                currModel.Parent = Mouse.TargetFilter

                selectActive = false
                placeActive = true

                ContextActionService:UnbindAction(SELECT)
                ContextActionService:BindAction(PLACE, handleInput, false, Enum.UserInputType.MouseButton1)
            end
        elseif name == QUIT then
            if placeActive then
                selectObj.Parent = orginParent
            end
            currModel:Destroy()
            rotation = 0
            ContextActionService:UnbindAction(PLACE)
            Mouse.TargetFilter = nil
        elseif name == PLACE then
            if not PlacementService.IsColliding(currModel) then
                placeActive = false
                PlacementService.Place(selectObj, PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation))
                handleInput(QUIT, Enum.UserInputState.Begin, nil)
            end
        end
    end
end


-- Bind actions 
ContextActionService:BindAction(QUIT, handleInput, true, Enum.KeyCode.Q)

RunService.RenderStepped:Connect(function(dt)
    if placeActive then
        local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation)
        currModel:PivotTo(cf)
    end
end)

return function(button : TextButton) -- Gives functionality to "Place" dev button
    button.Activated:Connect(function()
        selectActive = true
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
        ContextActionService:BindAction(SELECT, handleInput, false, Enum.UserInputType.MouseButton1)
    end)
end