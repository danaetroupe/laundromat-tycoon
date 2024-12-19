--local AnalyticsService = game:GetService("AnalyticsService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIService = require(ReplicatedStorage.Services.UIService)
local NPCService = require(ReplicatedStorage.Services.NPCService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)

local Tutorial = require(ReplicatedStorage.UI.Tutorial)
local Default = require(ReplicatedStorage.UI.Default)
local Store = require(ReplicatedStorage.UI.Store)
local PlaceObject = require(ReplicatedStorage.UI.Store.PlaceObject)

local TutorialEvents = ReplicatedStorage.Events.TutorialEvents
local PlacementEvents = ReplicatedStorage.Events.PlacementEvents
local ObjectEvents = ReplicatedStorage.Events.ObjectEvents

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
            local highlight: Frame = Default.HighightButtons()
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
            -- Default.changeActive(buttons, false, "Build") I forgot why I disabled the button
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
    },
    { -- 4 ---------------------------------------------------------------------
        Text = "Place your washing machine.",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return PlacementEvents.Place.Event
        end
    },
    { -- 5 ---------------------------------------------------------------------
        Text = "Buy a dryer.",
        Execute = function()
            PlaceObject.quit()
        end,
        Destroy = function()
            local highlight, arrow = Store.highlightIcon("dryer")
            highlight.Parent = Target
            arrow.Parent = Target
            return {highlight, arrow}
        end,
        CanClickForward = false,
        Event = function()
            local dryer = Store.GetIcon("dryer")
            if dryer then 
                return dryer.Activated
            else
                return warn("Cannot find dryer button")
            end
        end
    },
    { -- 6 ---------------------------------------------------------------------
        Text = "Place your dryer.",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return PlacementEvents.Place.Event
        end
    },
    { -- 7 ---------------------------------------------------------------------
        Text = "Buy a folding table.",
        Execute = function()
            PlaceObject.quit()
        end,
        Destroy = function()
            local highlight, arrow = Store.highlightIcon("table")
            highlight.Parent = Target
            arrow.Parent = Target
            return {highlight, arrow}
        end,
        CanClickForward = false,
        Event = function()
            local table = Store.GetIcon("table")
            if table then 
                return table.Activated
            else
                return warn("Cannot find table button")
            end
        end
    },
    { -- 6 ---------------------------------------------------------------------
        Text = "Place your table.",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return PlacementEvents.Place.Event
        end
    },
    { -- 7 ---------------------------------------------------------------------
        Text = "Get the laundry from the customer.",
        CanClickForward = false,
        Execute = function()
            PlayerService.ToggleActive(LocalPlayer)
        end,
        Destroy = function()
            local beam = NPCService.CreateBeam(LocalPlayer)
            return {beam}
        end,
        Event = function() : RBXScriptSignal
            return NPCService.GetPrompt(LocalPlayer).Triggered
        end
    },
    { -- 8 ---------------------------------------------------------------------
        Text = "Load laundry in washing machine",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.ObjectInteraction.Event
        end
    },
    { -- 9 ---------------------------------------------------------------------
        Text = "Wait for cycle to complete",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.CycleComplete.Event
        end
    },
    { -- 10 ---------------------------------------------------------------------
        Text = "Get laundry out of the machine.",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.ObjectInteraction.Event
        end
    },
    { -- 11 ---------------------------------------------------------------------
        Text = "Load laundry in dryer",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.ObjectInteraction.Event
        end
    },
    { -- 12 ---------------------------------------------------------------------
        Text = "Wait for cycle to complete",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.CycleComplete.Event
        end
    },
    { -- 13 ---------------------------------------------------------------------
        Text = "Get laundry out of the machine.",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.ObjectInteraction.Event
        end
    },
    { -- 14 ---------------------------------------------------------------------
        Text = "Place laundry on folding table",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.ObjectInteraction.Event
        end
    },
    { -- 15 ---------------------------------------------------------------------
        Text = "Fold laundry by holding down.",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return ObjectEvents.ObjectInteraction.Event
        end
    },
    { -- 16 ---------------------------------------------------------------------
        Text = "Give laundry back to the customer.",
        CanClickForward = false,
        Event = function() : RBXScriptSignal
            return NPCService.GetPickup(LocalPlayer).Triggered
        end
    },
    { -- 17 ---------------------------------------------------------------------
        Text = "Thank you for completing the tutorial. That's all you need to know for now. Have fun!",
        CanClickForward = true,
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
    -- runs on client
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
        local connection
        connection = event:Connect(function()
            TextComplete.Value = true
            TutorialService.NextStage(nil, Enum.UserInputState.Begin)
            connection:Disconnect()
        end)
    end
end

return TutorialService