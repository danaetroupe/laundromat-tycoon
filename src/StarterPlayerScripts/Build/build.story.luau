local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Store = require(ReplicatedStorage.UI.Store)
local UiLabs = require(ReplicatedStorage.Packages["ui-labs"])

--[[
local function createIcon()
    local icon = Instance.new("ImageButton")
    icon.Name = "Icon"
    icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    icon.BorderSizePixel = 0
    icon.Image = "rbxassetid://71280947937677"
    icon.Size = UDim2.fromScale(0.1, 0.1)
    icon.SizeConstraint = Enum.SizeConstraint.RelativeXX

    local display = Instance.new("TextLabel")
    display.Name = "Display"
    display.AnchorPoint = Vector2.new(0, 1)
    display.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    display.BackgroundTransparency = 1
    display.BorderColor3 = Color3.fromRGB(0, 0, 0)
    display.BorderSizePixel = 0
    display.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
    display.Position = UDim2.fromScale(0, 1)
    display.Size = UDim2.new(1, -5, 0.25, 0)
    display.Text = "$100"
    display.TextColor3 = Color3.fromRGB(245, 245, 240)
    display.TextScaled = true
    display.TextSize = 14
    display.TextStrokeColor3 = Color3.fromRGB(12, 23, 19)
    display.TextStrokeTransparency = 0
    display.TextWrapped = true
    display.TextXAlignment = Enum.TextXAlignment.Right

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 20)
    uICorner.Parent = icon

    local top = Instance.new("TextLabel")
    top.Name = "Top"
    top.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    top.BackgroundTransparency = 1
    top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    top.BorderSizePixel = 0
    top.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
    top.Size = UDim2.fromScale(1, 0.75)
    top.TextColor3 = Color3.fromRGB(245, 245, 240)
    top.TextScaled = true
    top.TextSize = 14
    top.TextStrokeColor3 = Color3.fromRGB(12, 23, 19)
    top.TextStrokeTransparency = 0
    top.TextWrapped = true
    top.TextYAlignment = Enum.TextYAlignment.Bottom
    top.Parent = icon
    return icon
end]]

return function(target)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(200, 200)
    frame.Parent = target
end