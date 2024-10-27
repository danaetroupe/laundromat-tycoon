local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui

--[[

-- Set footer buttons as toggle
for _, button in StoreGui.Footer:GetChildren() do
    if button:IsA("TextButton") then
        Toggle(button, StoreGui.Panels)
    end
end

-- Set up storefront
local StorePanel = StoreGui.Panels.Store
Store(StoreGui.Icon, StorePanel.LeftFrame, StorePanel.RightFrame.InnerFrame)]]