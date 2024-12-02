local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local UIService = require(ReplicatedStorage.Services.UIService)
local Default = require(ReplicatedStorage.UI.Default)

local TutorialEvents = ReplicatedStorage.Events.TutorialEvents

-- Initalize toggle functionaity
function Init()
    local scripts = {}
    for _, s in script.Scripts:GetChildren() do
        scripts[s.Name] = require(s)
    end
    local buttons = Default.createButtons(scripts)
    local gui = UIService.createScope(buttons)
    Default.changeActive(buttons, false)
    local moneyVal : IntValue = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Money")
    local coinDisplay = Default.createCoinDisplay(moneyVal)
    coinDisplay.Parent = gui
    return buttons
end

TutorialEvents.ShowButtons.OnInvoke = Init