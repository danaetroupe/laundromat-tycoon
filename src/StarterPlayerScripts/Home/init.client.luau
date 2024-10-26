local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local HomeGui : ScreenGui = PlayerGui:WaitForChild("Home")
local PanelsGui : ScreenGui = PlayerGui:WaitForChild("Panels")

local Toggle = require(script.Toggle)

-- Initalize toggle functionaity
Toggle(HomeGui.Left.Buttons, PanelsGui)

-- Show player money value
local moneyVal : IntValue = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Money")
moneyVal.Changed:Connect(function(value)
    HomeGui.Right.Coins.Text = value
end)