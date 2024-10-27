local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = if LocalPlayer then LocalPlayer.PlayerGui else nil
local MobileGui = if PlayerGui then PlayerGui:WaitForChild("Mobile") else nil

local MobileService = {}

-- Create mobile button on the client
function MobileService.CreateMobileButton(actionName : string, img : string) : nil
    local button = ContextActionService:GetButton(actionName)
    if button then
        button.Image = img
        button.Parent = MobileGui.ActionButtons
        button.Changed:Connect(function(property)
            if property == "Image" then
                button.Image = img
            end
        end)
    end
end

return MobileService