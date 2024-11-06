local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)

local StoreScript = require(ReplicatedStorage.UI.Store)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local PanelsGui : ScreenGui = PlayerGui:WaitForChild("Panels")
local BuildFrame : Frame = PanelsGui.Build
local BuildPanel = BuildFrame:FindFirstChild("Panel")

local Store : ScrollingFrame = BuildPanel:FindFirstChild("Store")
--local Inventory : ScrollingFrame = BuildPanel:FindFirstChild("Inventory")


local Icon = ReplicatedStorage.Assets.UI:WaitForChild("Icon")

local isBuilding = false



local function showInventory()
    
end

BuildFrame.Changed:Connect(function(property)
    isBuilding = property == "Visible"
    -- Set player state
    PlayerService.SetBuildState(isBuilding)
    if isBuilding then 
        -- Reset to store when opening and closing panel
        StoreScript.show(Store, Icon)
    else
        StoreScript.hide()
    end
end)
