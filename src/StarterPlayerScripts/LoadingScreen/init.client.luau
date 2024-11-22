local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIService = require(ReplicatedStorage.Services.UIService)
local LoadingScreen = require(ReplicatedStorage.UI.LoadingScreen)
local TutorialService = require(ReplicatedStorage.Services.TutorialService)


-- Initalize toggle functionaity
function Init()
    local gui = UIService.createScope(LoadingScreen.Show())
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    local buttonFrame, button : TextButton = LoadingScreen.ShowButtons()
    buttonFrame.Parent = gui
    button.Activated:Connect(function()
        gui:Destroy()
        TutorialService.Start(Players.LocalPlayer)
    end)
end

Init()
