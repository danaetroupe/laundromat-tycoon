local AnalyticsService = game:GetService("AnalyticsService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIService = require(ReplicatedStorage.Services.UIService)
local Tutorial = require(ReplicatedStorage.UI.Tutorial)
local Default = require(ReplicatedStorage.UI.Default)
local Store = require(ReplicatedStorage.UI.Store)

local TutorialEvents = ReplicatedStorage.Events.TutorialEvents

local LocalPlayer = Players.LocalPlayer

local TutorialText
local TutorialFrame
local TextComplete
local buttons
local destroy
local Target : ScreenGui


local TutorialService = {}

local StageInfo =  {
    { -- 1 ---------------------------------------------------------------------
        Text = "Congratulations on opening your first laundromat!"
    },
    { -- 2 ---------------------------------------------------------------------
        Text = "These are your management buttons.",
        Execute = function()
            buttons = TutorialEvents.ShowButtons:Invoke()
        end,
        Destroy = function()
            local highlight, arrow = Default.HighightButtons()
            highlight.Parent = Target
            return {highlight}
        end
    },
    { -- 3 ---------------------------------------------------------------------
        Text = "To get started, select the build button.",
        Execute = function()
            Default.changeActive(buttons, true, "Build")
        end,
        CanClickForward = false,
        Event = function()
            local build = Default.GetButton("Build")
            if build then 
                return build.Activated -- todo: for some reason this only firing upon close
            else
                return warn("Build button cannot be found or does not exist")
            end
        end
    },
    { -- 4 ---------------------------------------------------------------------
        Text = "Buy a washing machine",
        Execute = function()
            Default.changeActive(buttons, false, "Build")
        end,
        Destroy = function()
            local highlight, arrow = Store.highlightIcon("washer")
            highlight.Parent = Target
            arrow.Parent = Target
            return {highlight, arrow}
        end,
        CanClickForward = false,
        Event = function()
            local washer = Store.GetIcon("washer")
            if washer then 
                return washer.Activated
            else
                return warn("Cannot find washer button")
            end
        end
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
    TextComplete = Instance.new("BoolValue")
    TextComplete.Value = true
    TutorialFrame = Tutorial.CreatePanel(TutorialText, TextComplete)
    Target = UIService.createScope(TutorialFrame)
    Target.DisplayOrder = 1
    ContextActionService:BindAction("Advance", TutorialService.NextStage, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
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

-- Advance to next stage in tutorial
function TutorialService.NextStage(_name, state, _input)
    if state ~= Enum.UserInputState.Begin then return end
    if TextComplete.Value == false then -- Finish showing text before advancing
        TextComplete.Value = true
        return
    end
    if destroy then -- Destroy previous values
        for _, d in destroy do
            d:Destroy()
        end
        destroy = nil
    end
    local currStage = LocalPlayer:GetAttribute("TutorialStage") + 1
    local info = StageInfo[currStage]
    LocalPlayer:SetAttribute("TutorialStage", currStage)
    -- End tutorial if not info
    if not info then 
        LocalPlayer:SetAttribute("TutorialMode", false)
        TutorialText:Destroy()
        TutorialFrame:Destroy()
        return 
    end
    -- Display stage text
    if info.Text then
        TextComplete.Value = false
        TutorialText.Value = info.Text
    end
    if info.Execute then -- Execute
        info.Execute()
    end
    destroy = if info.Destroy then info.Destroy() else nil -- check for destroy values
    if info.CanClickForward then -- Enable/Disable Click Binding
        ContextActionService:BindAction("Advance", TutorialService.NextStage, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
    elseif info.CanClickForward == false  then
        ContextActionService:UnbindAction("Advance")
    end
    if info.Event then -- Check for event 
        local event : RBXScriptSignal = info.Event()
        event:Connect(function()
            TextComplete.Value = true
            TutorialService.NextStage(nil, Enum.UserInputState.Begin)
        end)
    end
end

return TutorialService