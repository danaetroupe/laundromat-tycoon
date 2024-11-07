local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UILabs = require(ReplicatedStorage.Packages.UILabs)

local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)

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
    display.Parent = icon

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
end

local function makeFrame()
    local store = Instance.new("ScrollingFrame")
    store.Name = "Store"
    store.Active = true
    store.AnchorPoint = Vector2.new(0.5, 0.5)
    store.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    store.BackgroundTransparency = 1
    store.BorderColor3 = Color3.fromRGB(0, 0, 0)
    store.BorderSizePixel = 0
    store.ElasticBehavior = Enum.ElasticBehavior.Always
    store.Position = UDim2.fromScale(0.5, 0.5)
    store.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    store.ScrollBarImageTransparency = 1
    store.Size = UDim2.new(1, -20, 0.4, 0)

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.Padding = UDim.new(0, 5)
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Parent = store

    return store
end



local function show(props : UILabs.GenericProps)
    local target = props.target

    local storeFrame = makeFrame()
    storeFrame.Parent = target

    for _, objectName in Objects.GetObjectNames() do
        local button = createIcon()
        button.Top.Text = Objects.GetProperty(objectName, "name")
        local cost = Objects.GetProperty(objectName, "cost")
        button.Display.Text = if cost then "$"..cost else "$ERR"
        button.Parent = storeFrame
    end

    return function()

        for _, item in target:GetChildren() do
            item:Destroy()
        end
    end
end

return {
    controls = {
        Visible = UILabs.Boolean(true)
    },
    render = show
}