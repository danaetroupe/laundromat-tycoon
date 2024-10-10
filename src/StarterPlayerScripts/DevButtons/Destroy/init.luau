local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local playerData = nil
local selectObj : Model = nil
local rotation : number = 0
local selectActive : boolean = false
local placeActive : boolean = false
local currModel : Model = nil
local basePart : Part = nil

local SELECT = "Select"
local QUIT = "Quit"
local PLACE = "Place"

local function handleInput(name, userInputState, input)
    if userInputState == Enum.UserInputState.Begin and selectActive then
        if name == SELECT then
            local obj = Mouse.Target
            if PlacementService.IsBaseObject(playerData, obj) then
                obj.Parent = ReplicatedStorage.Temp
                currModel = obj:Clone()
                selectActive = false
                placeActive = true
                Mouse.TargetFilter = basePart.BaseObjects
                selectActive = true
                ContextActionService:BindAction(SELECT, handleInput, false, Enum.UserInputType.MouseButton1)
                
                RunService.RenderStepped:Connect(function(dt)
                    if selectActive then
                        local cf = PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation)
                        currModel:PivotTo(cf)
                    end
                end)
            end
        elseif name == QUIT then
            if placeActive then
                PlacementService.Place(selectObj, selectObj.Origin, basePart)
            end
            currModel:Destroy()
            rotation = 0
            selectActive = false
            ContextActionService:UnbindAction(PLACE)
            Mouse.TargetFilter = nil
        elseif name == PLACE then
            if not PlacementService.IsColliding(currModel) then
                PlacementService.Place(selectObj, PlacementService.CalcPlacementCFrame(basePart, currModel, Mouse.Hit.p, rotation))
                handleInput(QUIT, Enum.UserInputState.Begin, nil)
            end
        end
    end
end


-- Bind actions 
ContextActionService:BindAction(QUIT, handleInput, true, Enum.KeyCode.Q)

return function(button : TextButton) -- Gives functionality to "Place" dev button
    button.Activated:Connect(function()
        selectActive = true
        basePart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
    end)
end