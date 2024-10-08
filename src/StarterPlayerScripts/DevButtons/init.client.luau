local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Place = require(script.Place)

local DevButtons : ScreenGui = PlayerGui:WaitForChild("DevButtons")

Place(DevButtons.LeftFrame.Place)
