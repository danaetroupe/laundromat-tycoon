local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIService = require(ReplicatedStorage.Services.UIService)
local Default = {}
local Data = {}

local BUTTONS = {
    {
        Name = "Store",
        Image = "rbxassetid://94153337734928"
    },
    {
        Name = "Build",
        Image = "rbxassetid://76407564740227"
    },
    {
        Name = "Manage",
        Image = "rbxassetid://128406918024562"
    },
    {
        Name = "Stats",
        Image = "rbxassetid://127723348434402"
    },
    {
        Name = "Employees",
        Image = "rbxassetid://82812271030168"
    },
    {
        Name = "Settings",
        Image = "rbxassetid://79098638441759"
    }
}

local KEYS = {
    Enum.KeyCode.One,
    Enum.KeyCode.Two,
    Enum.KeyCode.Three,
    Enum.KeyCode.Four,
    Enum.KeyCode.Five,
    Enum.KeyCode.Six,
    Enum.KeyCode.Seven,
    Enum.KeyCode.Eight,
    Enum.KeyCode.Nine
}

local currMenu = nil
local destroy = nil
local SCRIPTS = {}

local function _toggle(name : string)
    if currMenu then
        destroy()
    end
    if currMenu ~= name and SCRIPTS[name] then
        currMenu = name
        destroy = SCRIPTS[name]()
    else 
        currMenu = nil
        destroy = nil
    end
end

function Default.createButtons(scripts)
    SCRIPTS = scripts

    local frame = Instance.new("Frame")
    frame.Name = "Left"
    frame.AnchorPoint = Vector2.new(0, 1)
    frame.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
    frame.BackgroundTransparency = 1
    frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.fromScale(0, 1)
    frame.Size = UDim2.new(0, 0, 0.1, 0)
    frame.AutomaticSize = Enum.AutomaticSize.X

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.Parent = frame

    local uIPadding = Instance.new("UIPadding")
    uIPadding.Name = "UIPadding"
    uIPadding.PaddingBottom = UDim.new(0, 5)
    uIPadding.PaddingLeft = UDim.new(0, 10)
    uIPadding.Parent = frame

    local buttons = Instance.new("Folder")
    buttons.Name = "Buttons"

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.Padding = UDim.new(0, 5)
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Parent = buttons

    for i, buttonInfo in BUTTONS do
        local button = Instance.new("ImageButton")
        button.Name = buttonInfo.Name
        button.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
        button.BackgroundTransparency = 1
        button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        button.BorderSizePixel = 0
        button.Image = buttonInfo.Image
        button.LayoutOrder = i
        button.Position = UDim2.fromOffset(-2, -2)
        button.Size = UDim2.fromScale(1, 1)
        button.SizeConstraint = Enum.SizeConstraint.RelativeYY
        button.Parent = buttons

        -- Bind to script
        button.Activated:Connect(function()
            _toggle(buttonInfo.Name)
        end) 
        ContextActionService:BindAction(button.Name, function(_name, state, _obj)
            if state == Enum.UserInputState.Begin and button.Active then
                _toggle(buttonInfo.Name)
            end
        end, false, KEYS[i])

    end

    buttons.Parent = frame
    Data.Buttons = buttons
    return frame
end

-- Toggle button activity. Name is an optional paramaeter to disable a specific button
function Default.changeActive(frame : Frame, active : boolean, name : string?)
    UIService.changeButtonEnabled(frame:FindFirstChild("Buttons"), active, name)
end

function Default.createCoinDisplay(value : IntValue)
    local frame = Instance.new("Frame")
    frame.Name = "Right"
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 1
    frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, -10, 1, 0)
    frame.Size = UDim2.new(0, 250, 0.1, 0)

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "ImageLabel"
    imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    imageLabel.BackgroundTransparency = 1
    imageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    imageLabel.BorderSizePixel = 0
    imageLabel.Image = "rbxassetid://96724677890916"
    imageLabel.Size = UDim2.new(1, -5, 1, -5)
    imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
    imageLabel.Parent = frame

    local coins = Instance.new("TextLabel")
    coins.Name = "Coins"
    coins.AutomaticSize = Enum.AutomaticSize.X
    coins.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    coins.BackgroundTransparency = 1
    coins.BorderColor3 = Color3.fromRGB(0, 0, 0)
    coins.BorderSizePixel = 0
    coins.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
    coins.Size = UDim2.fromScale(0, 0.8)
    coins.Text = value.Value
    coins.TextColor3 = Color3.fromRGB(245, 245, 240)
    coins.TextScaled = true
    coins.TextSize = 24
    coins.TextStrokeColor3 = Color3.fromRGB(44, 62, 80)
    coins.TextStrokeTransparency = 0
    coins.TextWrapped = true
    coins.TextXAlignment = Enum.TextXAlignment.Left

    -- Connect display to value
    value.Changed:Connect(function(newValue)
        coins.Text = newValue
    end)

    local uIStroke = Instance.new("UIStroke")
    uIStroke.Name = "UIStroke"
    uIStroke.Color = Color3.fromRGB(44, 62, 80)
    uIStroke.Thickness = 3
    uIStroke.Parent = coins

    coins.Parent = frame

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    uIListLayout.Padding = UDim.new(0, 5)
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.Parent = frame
    return frame
end

return Default