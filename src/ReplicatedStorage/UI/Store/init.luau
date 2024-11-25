local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Spr = require(ReplicatedStorage.Packages.Spr)
-- Data
local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)

-- Locals
local KEY_IMAGE = "rbxassetid://71593851686379"
local keys = 
{
    {
        Name = "Rotate",
        ButtonImage = "rbxassetid://101527014073084",
        Key = "R",
        Binding = Enum.UserInputType.MouseButton1
    },
    {
        Name = "Close",
        ButtonImage = "rbxassetid://90664024735834",
        Key = "Q",
        Binding = Enum.KeyCode.Q
    },
    {
        Name = "Place",
        ButtonImage = "rbxassetid://115789813803218",
        BindingImage = "rbxassetid://93666975351602",
        Binding = Enum.KeyCode.Q
    }
}

local DEFAULT_COLOR = Color3.fromRGB(245, 245, 240)
local ERROR_COLOR = Color3.fromRGB(255, 0, 0)

local Store = {}
local Data = {}

-- Create build keys
function Store.createBuildKeybinds()
    local buy = Instance.new("Frame")
    buy.Name = "Buy"
    buy.AnchorPoint = Vector2.new(0, 0.5)
    buy.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    buy.BackgroundTransparency = 1
    buy.BorderColor3 = Color3.fromRGB(0, 0, 0)
    buy.BorderSizePixel = 0
    buy.Position = UDim2.fromScale(-0.1, 0.5)
    buy.Size = UDim2.fromScale(0.15, 0.375)
    buy.SizeConstraint = Enum.SizeConstraint.RelativeYY

    local uIGridLayout = Instance.new("UIGridLayout")
    uIGridLayout.Name = "UIGridLayout"
    uIGridLayout.CellPadding = UDim2.new()
    uIGridLayout.CellSize = UDim2.fromScale(0.5, 0.2)
    uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIGridLayout.Parent = buy

    for i, key in keys do
        local label = Instance.new("ImageLabel")
        label.Name = key.Name
        label.BackgroundTransparency = 1
        label.BorderColor3 = Color3.fromRGB(0, 0, 0)
        label.BorderSizePixel = 0
        label.Image = key.ButtonImage
        label.LayoutOrder = i
        label.Position = UDim2.fromScale(0, 1)
        label.Size = UDim2.fromScale(1, 0.25)
        label.SizeConstraint = Enum.SizeConstraint.RelativeXX
        label.Parent = buy

        if key.Key then -- Check if key exists
            local r = Instance.new("ImageLabel")
            r.BackgroundTransparency = 1
            r.BorderColor3 = Color3.fromRGB(0, 0, 0)
            r.BorderSizePixel = 0
            r.Image = KEY_IMAGE
            r.LayoutOrder = i+1
            r.Size = UDim2.fromOffset(100, 100)
            r.SizeConstraint = Enum.SizeConstraint.RelativeXX

            local textLabel = Instance.new("TextLabel")
            textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.BackgroundTransparency = 1
            textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            textLabel.BorderSizePixel = 0
            textLabel.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
            textLabel.Position = UDim2.fromScale(0.5, 0.5)
            textLabel.Size = UDim2.fromScale(0.5, 0.5)
            textLabel.Text = key.Key
            textLabel.TextColor3 = Color3.fromRGB(245, 245, 240)
            textLabel.TextScaled = true
            textLabel.TextSize = 1
            textLabel.TextStrokeTransparency = 0
            textLabel.TextWrapped = true
            textLabel.Parent = r

            r.Parent = buy
        else
            local mouse = Instance.new("ImageLabel")
            mouse.BackgroundTransparency = 1
            mouse.BorderColor3 = Color3.fromRGB(0, 0, 0)
            mouse.BorderSizePixel = 0
            mouse.Image = key.BindingImage
            mouse.LayoutOrder = i+1
            mouse.Size = UDim2.fromOffset(100, 100)
            mouse.SizeConstraint = Enum.SizeConstraint.RelativeXX
            mouse.Parent = buy
        end
    end
    return buy
end

function Store.toggleKeybinds(frame : Frame, visible : boolean)
    local targetValue = if visible then 0 else -0.1
    Spr.target(frame, 1, 1, {
        Position = UDim2.fromScale(targetValue, 0.5)
    })
end


local function _createIcon(objectName : string, money : number)
    local itemCost = Objects.GetProperty(objectName, "cost")

    local icon = Instance.new("ImageButton")
    icon.Name = objectName
    icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    icon.BorderSizePixel = 0
    icon.Image = "rbxassetid://71280947937677"
    icon.Size = UDim2.fromScale(0.1, 0.1)
    icon.SizeConstraint = Enum.SizeConstraint.RelativeXX
    icon.Active = itemCost <= money
    icon:SetAttribute("cost", itemCost)
    icon:SetAttribute("name", objectName)

    local price = Instance.new("TextLabel")
    price.Name = "Price"
    price.AnchorPoint = Vector2.new(0, 1)
    price.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    price.BackgroundTransparency = 1
    price.BorderColor3 = Color3.fromRGB(0, 0, 0)
    price.BorderSizePixel = 0
    price.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
    price.Position = UDim2.fromScale(0, 1)
    price.Size = UDim2.new(1, -5, 0.25, 0)
    price.TextColor3 = if itemCost <= money then DEFAULT_COLOR else ERROR_COLOR
    price.TextScaled = true
    price.TextSize = 14
    price.Text = if itemCost then "$"..itemCost else "$ERR"
    price.TextStrokeColor3 = Color3.fromRGB(12, 23, 19)
    price.TextStrokeTransparency = 0
    price.TextWrapped = true
    price.TextXAlignment = Enum.TextXAlignment.Right
    price.Parent = icon

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 20)
    uICorner.Parent = icon

    local itemName = Instance.new("TextLabel")
    itemName.BackgroundTransparency = 1
    itemName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    itemName.BorderSizePixel = 0
    itemName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
    itemName.Size = UDim2.fromScale(1, 0.75)
    itemName.TextColor3 = Color3.fromRGB(245, 245, 240)
    itemName.TextScaled = true
    itemName.TextSize = 14
    itemName.Text = Objects.GetProperty(objectName, "name")
    itemName.TextStrokeColor3 = Color3.fromRGB(12, 23, 19)
    itemName.TextStrokeTransparency = 0
    itemName.TextWrapped = true
    itemName.TextYAlignment = Enum.TextYAlignment.Bottom
    itemName.Parent = icon
    return icon
end

local function _makeFrame()
    local store = Instance.new("ScrollingFrame")
    store.Name = "Store"
    store.Active = true
    store.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    store.BackgroundTransparency = 1
    store.BorderColor3 = Color3.fromRGB(0, 0, 0)
    store.BorderSizePixel = 0
    store.ElasticBehavior = Enum.ElasticBehavior.Always
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

function Store.createMenu(moneyVal  : number)
    local storeFrame = _makeFrame()

    for _, objectName in Objects.GetObjectNames() do
        local button = _createIcon(objectName, moneyVal)
        button.Parent = storeFrame
    end

    Data.Frame = storeFrame
    return storeFrame
end

-- Close build panel
function Store.toggle(frame : Frame, visible : boolean)
    local targetValue = if visible then 0 else -1
    Spr.target(frame, 1, 1, {
        Position = UDim2.fromScale(0, targetValue)
    })
end

function Store.updateIconValues(frame : Frame, moneyVal : number)
    for _, icon: Instance in frame:GetChildren() do 
        if not icon:IsA("ImageButton") then continue end
        local cost = icon:GetAttribute("cost")
        local price : TextLabel = icon:FindFirstChild("Price") :: TextLabel
        price.TextColor3 = if cost <= moneyVal then DEFAULT_COLOR else ERROR_COLOR
    end
end

function Store.highlightIcon(iconName : string) : (Frame, ImageLabel)
    repeat 
        task.wait()
    until Data.Frame 
    local store: ScrollingFrame = Data.Frame
    local icon : ImageButton = store:FindFirstChild(iconName) :: ImageButton
    store.ScrollingEnabled = false

    local highlight: Frame = Instance.new("Frame")
    highlight.Size = UDim2.fromOffset(icon.AbsoluteSize.X, icon.AbsoluteSize.Y)
    highlight.Position = UDim2.fromOffset(icon.AbsolutePosition.X, icon.AbsolutePosition.Y)
    highlight.BackgroundTransparency = 1

    local stroke: UIStroke = Instance.new("UIStroke")
    stroke.Parent = highlight
    stroke.Thickness = 50000
    stroke.Transparency = 0.2

    local arrow: ImageLabel = Instance.new("ImageLabel")
    arrow.Size = UDim2.fromOffset(icon.AbsoluteSize.X, icon.AbsoluteSize.Y)
    arrow.Position = UDim2.fromOffset(icon.AbsolutePosition.X, icon.AbsolutePosition.Y+icon.AbsoluteSize.Y+10)
    arrow.Image = "rbxassetid://94390079914087"
    arrow.BackgroundTransparency = 1
    -- Alt + Shift + A
    return highlight, arrow
end

-- Get store icon for events
function Store.GetIcon(iconName : string) : ImageButton
    repeat 
        task.wait()
    until Data.Frame 
    local store: ScrollingFrame = Data.Frame
    return store:FindFirstChild(iconName) :: ImageButton
end

return Store