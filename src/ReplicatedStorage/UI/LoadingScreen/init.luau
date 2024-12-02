local LoadingScreen = {}

function LoadingScreen.ShowButtons() : (Frame, TextButton)
    local buttons = Instance.new("Frame")
    buttons.Name = "Buttons"
    buttons.AnchorPoint = Vector2.new(0, 1)
    buttons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    buttons.BackgroundTransparency = 1
    buttons.BorderColor3 = Color3.fromRGB(0, 0, 0)
    buttons.BorderSizePixel = 0
    buttons.Position = UDim2.fromScale(0, 1)
    buttons.Size = UDim2.fromScale(1, 0.25)

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout.Padding = UDim.new(0, 30)
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.Parent = buttons

    local play = Instance.new("TextButton")
    play.Name = "Play"
    play.BackgroundColor3 = Color3.fromRGB(255, 161, 200)
    play.BorderColor3 = Color3.fromRGB(0, 0, 0)
    play.BorderSizePixel = 0
    play.FontFace = Font.fromEnum(Enum.Font.LuckiestGuy)
    play.Size = UDim2.fromScale(0.2, 0.4)
    play.Text = "play"
    play.TextColor3 = Color3.fromRGB(255, 255, 255)
    play.TextScaled = true
    play.TextSize = 14
    play.TextStrokeTransparency = 0
    play.TextWrapped = true

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 15)
    uICorner.Parent = play

    local uIPadding = Instance.new("UIPadding")
    uIPadding.Name = "UIPadding"
    uIPadding.PaddingLeft = UDim.new(0, 10)
    uIPadding.PaddingRight = UDim.new(0, 10)
    uIPadding.PaddingTop = UDim.new(0.2, 0)
    uIPadding.Parent = play

    local uIStroke = Instance.new("UIStroke")
    uIStroke.Name = "UIStroke"
    uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uIStroke.Thickness = 3
    uIStroke.Parent = play

    local uIStroke1 = Instance.new("UIStroke")
    uIStroke1.Name = "UIStroke"
    uIStroke1.Thickness = 3
    uIStroke1.Parent = play

    play.Parent = buttons
    return buttons, play
end

function LoadingScreen.Show() : Frame
    local screen = Instance.new("Frame")
    screen.Name = "Screen"
    screen.BackgroundColor3 = Color3.fromRGB(167, 216, 240)
    screen.BorderColor3 = Color3.fromRGB(0, 0, 0)
    screen.BorderSizePixel = 0
    screen.Size = UDim2.fromScale(1, 1)

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.Parent = screen

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "ImageLabel"
    imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    imageLabel.BackgroundTransparency = 1
    imageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    imageLabel.BorderSizePixel = 0
    imageLabel.Image = "rbxassetid://133068353180314"
    imageLabel.Position = UDim2.fromScale(0.193, 0.249)
    imageLabel.Size = UDim2.fromScale(0.5, 0.5)
    imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
    imageLabel.Parent = screen

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.BorderSizePixel = 0
    textLabel.FontFace = Font.fromEnum(Enum.Font.LuckiestGuy)
    textLabel.LayoutOrder = 1
    textLabel.Size = UDim2.fromScale(0.5, 0.25)
    textLabel.Text = "Laundromat Tycoon"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.TextSize = 14
    textLabel.TextStrokeTransparency = 0
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left

    local uIStroke = Instance.new("UIStroke")
    uIStroke.Name = "UIStroke"
    uIStroke.Thickness = 5
    uIStroke.Parent = textLabel

    textLabel.Parent = screen
    return screen
end

return LoadingScreen