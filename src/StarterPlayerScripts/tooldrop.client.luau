local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SETDOWN = "Setdown"
local LocalPlayer = Players.LocalPlayer
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ToolService = require(ReplicatedStorage.Services.ToolService)

local function isWithinBounds(position)
    local floorPart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
    local floorSize = floorPart.Size
    local floorPos = floorPart.Position

    local xMin = floorPos.X - (floorSize.X / 2)
    local xMax = floorPos.X + (floorSize.X / 2)
    local zMin = floorPos.Z - (floorSize.Z / 2)
    local zMax = floorPos.Z + (floorSize.Z / 2)

    return position.X >= xMin and position.X <= xMax and position.Z >= zMin and position.Z <= zMax
end

local function handleInput(name, userInputState, input)
    if userInputState == Enum.UserInputState.Begin and name == SETDOWN then
        -- Get player key and position
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local lookVector = character.HumanoidRootPart.CFrame.LookVector
        local position = character.HumanoidRootPart.Position + (lookVector * 2)
        local key = PlayerService.RequestKey(LocalPlayer)
        --  Check if valid
        if key and isWithinBounds(position) then
            ToolService.MoveToWorld(key, position)
        end
    end
end


ContextActionService:BindAction(SETDOWN, handleInput, true, Enum.KeyCode.P)


