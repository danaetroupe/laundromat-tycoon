local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Place = require(script.Place)
local Move = require(script.Move)
--local Destroy = require(script.Destroy)
local Active = require(script.Active)

local DevButtons : ScreenGui = PlayerGui:WaitForChild("DevButtons")

Place(DevButtons.LeftFrame.Place)
Move(DevButtons.LeftFrame.Move)
Active(DevButtons.LeftFrame.Toggle)
