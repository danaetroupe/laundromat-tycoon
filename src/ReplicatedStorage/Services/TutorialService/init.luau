local AnalyticsService = game:GetService("AnalyticsService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local UIService = require(ReplicatedStorage.Services.UIService)
local Tutorial = require(ReplicatedStorage.UI.Tutorial)
local Default = require(ReplicatedStorage.UI.Default)

local TutorialEvents = ReplicatedStorage.Events.TutorialEvents

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local TutorialText
local TutorialFrame
local buttons

local TutorialService = {}

local StageInfo = {
    {
        Text = "Congratulations on opening your first laundromat!"
    },
    {
        Text = "These are your management buttons.",
        Execute = function()
            buttons = TutorialEvents.ShowButtons:Invoke()
        end
    },
    {
        Text = "To get started, select the build button.",
        Execute = function()
            Default.changeActive(buttons, true, "Build")
        end,
        CanClickForward = false
    }
}

function TutorialService.Start()
    --[[ AnalyticsService:LogOnboardingFunnelStepEvent(
        player,
        1,
        "Tutorial Started"
    ) ]]
    LocalPlayer:SetAttribute("TutorialMode", true)
    LocalPlayer:SetAttribute("TutorialStage", 0)
    TutorialText = Instance.new("StringValue")
    TutorialFrame = Tutorial.CreatePanel(TutorialText)
    local _target = UIService.createScope(TutorialFrame)
    ContextActionService:BindAction("Advance", TutorialService.NextStage, false, Enum.UserInputType.MouseButton1)
    TutorialService.NextStage(nil, Enum.UserInputState.Begin)
    --[[
    POSSIBLE STEPS: 
        - Washing Machine Placed
        - Dryer Placed
        - Folding Table Placed
        - Shelf Placed
        - NPC helped
        - Clothes In Washing Machine
        - Clothes In Dryer
        - Clothes Folded
        - Clothes Back to NPC
        - Tutorial Complete!
    ]]
end

function TutorialService.NextStage(_name, state, _input)
    if state ~= Enum.UserInputState.Begin then return end
    local currStage = LocalPlayer:GetAttribute("TutorialStage") + 1
    LocalPlayer:SetAttribute("TutorialStage", currStage)
    if not StageInfo[currStage] then -- End tutorial
        LocalPlayer:SetAttribute("TutorialMode", false)
        TutorialText:Destroy()
        TutorialFrame:Destroy()
        return 
    end
    if StageInfo[currStage]["Text"] then
        TutorialText.Value = StageInfo[currStage]["Text"]
    end
    if StageInfo[currStage]["Execute"] then
        StageInfo[currStage].Execute()
    end
    if StageInfo[currStage].CanClickForward then
        ContextActionService:BindAction("Advance", TutorialService.NextStage, false, Enum.UserInputType.MouseButton1)
    elseif StageInfo[currStage].CanClickForward == false  then
        ContextActionService:UnbindAction("Advance")
    end
end

return TutorialService