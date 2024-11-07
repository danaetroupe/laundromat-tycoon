local BuildMenu = {}

function BuildMenu.createBuildKeybinds()
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

    local rotate = Instance.new("ImageButton")
    rotate.Name = "Rotate"
    rotate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rotate.BackgroundTransparency = 1
    rotate.BorderColor3 = Color3.fromRGB(0, 0, 0)
    rotate.BorderSizePixel = 0
    rotate.Image = "rbxassetid://101527014073084"
    rotate.LayoutOrder = 2
    rotate.Position = UDim2.fromScale(1, 0)
    rotate.Size = UDim2.fromScale(1, 0.25)
    rotate.SizeConstraint = Enum.SizeConstraint.RelativeXX
    rotate.Parent = buy

    local close = Instance.new("ImageButton")
    close.Name = "Close"
    close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    close.BackgroundTransparency = 1
    close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    close.BorderSizePixel = 0
    close.Image = "rbxassetid://90664024735834"
    close.LayoutOrder = 7
    close.Position = UDim2.fromScale(0, 1)
    close.Size = UDim2.fromScale(1, 0.25)
    close.SizeConstraint = Enum.SizeConstraint.RelativeXX
    close.Parent = buy

    local uIGridLayout = Instance.new("UIGridLayout")
    uIGridLayout.Name = "UIGridLayout"
    uIGridLayout.CellPadding = UDim2.new()
    uIGridLayout.CellSize = UDim2.fromScale(0.5, 0.2)
    uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIGridLayout.Parent = buy

    local r = Instance.new("ImageLabel")
    r.Name = "R"
    r.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    r.BackgroundTransparency = 1
    r.BorderColor3 = Color3.fromRGB(0, 0, 0)
    r.BorderSizePixel = 0
    r.Image = "rbxassetid://71593851686379"
    r.LayoutOrder = 3
    r.Size = UDim2.fromOffset(100, 100)
    r.SizeConstraint = Enum.SizeConstraint.RelativeXX

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.BorderSizePixel = 0
    textLabel.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
    textLabel.Position = UDim2.fromScale(0.5, 0.5)
    textLabel.Size = UDim2.fromScale(0.5, 0.5)
    textLabel.Text = "R"
    textLabel.TextColor3 = Color3.fromRGB(245, 245, 240)
    textLabel.TextScaled = true
    textLabel.TextSize = 1
    textLabel.TextStrokeTransparency = 0
    textLabel.TextWrapped = true
    textLabel.Parent = r

    r.Parent = buy

    local q = Instance.new("ImageLabel")
    q.Name = "Q"
    q.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    q.BackgroundTransparency = 1
    q.BorderColor3 = Color3.fromRGB(0, 0, 0)
    q.BorderSizePixel = 0
    q.Image = "rbxassetid://71593851686379"
    q.LayoutOrder = 7
    q.Size = UDim2.fromOffset(100, 100)
    q.SizeConstraint = Enum.SizeConstraint.RelativeXX

    local textLabel1 = Instance.new("TextLabel")
    textLabel1.Name = "TextLabel"
    textLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    textLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel1.BackgroundTransparency = 1
    textLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    textLabel1.BorderSizePixel = 0
    textLabel1.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
    textLabel1.Position = UDim2.fromScale(0.5, 0.5)
    textLabel1.Size = UDim2.fromScale(0.5, 0.5)
    textLabel1.Text = "Q"
    textLabel1.TextColor3 = Color3.fromRGB(245, 245, 240)
    textLabel1.TextScaled = true
    textLabel1.TextSize = 1
    textLabel1.TextStrokeTransparency = 0
    textLabel1.TextWrapped = true
    textLabel1.Parent = q

    q.Parent = buy

    local place = Instance.new("ImageButton")
    place.Name = "Place"
    place.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    place.BackgroundTransparency = 1
    place.BorderColor3 = Color3.fromRGB(0, 0, 0)
    place.BorderSizePixel = 0
    place.Image = "rbxassetid://115789813803218"
    place.Position = UDim2.fromScale(1, 0)
    place.Size = UDim2.fromScale(1, 0.25)
    place.SizeConstraint = Enum.SizeConstraint.RelativeXX
    place.Parent = buy

    local mouse = Instance.new("ImageLabel")
    mouse.Name = "Mouse"
    mouse.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mouse.BackgroundTransparency = 1
    mouse.BorderColor3 = Color3.fromRGB(0, 0, 0)
    mouse.BorderSizePixel = 0
    mouse.Image = "rbxassetid://93666975351602"
    mouse.LayoutOrder = 1
    mouse.Size = UDim2.fromOffset(100, 100)
    mouse.SizeConstraint = Enum.SizeConstraint.RelativeXX
    mouse.Parent = buy