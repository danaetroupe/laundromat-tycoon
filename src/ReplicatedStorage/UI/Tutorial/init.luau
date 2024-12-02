local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIService = require(ReplicatedStorage.Services.UIService)

local Tutorial = {}

function Tutorial.CreatePanel(TextToShow : StringValue, Complete : BoolValue)
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.AnchorPoint = Vector2.new(0.5, 1)
    frame.BackgroundColor3 = Color3.fromRGB(167, 216, 240)
    frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.fromScale(0.5, 0.85)
    frame.Size = UDim2.fromScale(0.5, 0.25)
    frame.ZIndex = 2

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 15)
    uICorner.Parent = frame

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.AnchorPoint = Vector2.new(0.25, 0.5)
    header.BackgroundColor3 = Color3.fromRGB(250, 208, 46)
    header.BorderColor3 = Color3.fromRGB(0, 0, 0)
    header.BorderSizePixel = 0
    header.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
    header.Size = UDim2.fromScale(0.25, 0.25)
    header.Text = "Tutorial"
    header.TextColor3 = Color3.fromRGB(245, 245, 240)
    header.TextScaled = true
    header.TextSize = 14
    header.TextStrokeTransparency = 0
    header.TextWrapped = true
    header.ZIndex = 3

    local uICorner1 = Instance.new("UICorner")
    uICorner1.Name = "UICorner"
    uICorner1.CornerRadius = UDim.new(0, 15)
    uICorner1.Parent = header

    header.Parent = frame

    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.AnchorPoint = Vector2.new(0.5, 0.5)
    body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    body.BackgroundTransparency = 1
    body.BorderColor3 = Color3.fromRGB(0, 0, 0)
    body.BorderSizePixel = 0
    body.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
    body.Position = UDim2.fromScale(0.5, 0.5)
    body.Size = UDim2.fromScale(0.9, 0.8)
    body.Text = TextToShow.Value
    body.TextColor3 = Color3.fromRGB(245, 245, 240)
    body.TextScaled = true
    body.TextStrokeTransparency = 0
    body.Parent = frame
    body.ZIndex = 3

    TextToShow.Changed:Connect(function(value)
        UIService.TypingEffect(body, value, nil, Complete)
    end)

    return frame
end

function Tutorial.CreateBeam(player : Player, attatchment : Attachment)
    local beam = Instance.new("Beam")
    beam.Name = "Beam"
    beam.Segments = 1
    beam.Texture = "rbxassetid://94390079914087"
    beam.TextureMode = Enum.TextureMode.Static
    beam.TextureSpeed = 0
    beam.Parent = workspace
    beam.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(1, 0.2),
    })
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humPart = character:FindFirstChild("HumanoidRootPart")
    local rootAttatchment = humPart:FindFirstChild("RootAttachment")
    beam.Attachment1 = rootAttatchment
    beam.Attachment0 = attatchment

    return beam
end

return Tutorial