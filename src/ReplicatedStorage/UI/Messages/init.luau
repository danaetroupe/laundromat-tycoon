local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIService = require(ReplicatedStorage.Services.UIService)
local TweenService = game:GetService("TweenService")
local Messages = {}

function Messages.createMessage(message : string) : Frame
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageFrame"
    messageFrame.AnchorPoint = Vector2.new(0, 1)
    messageFrame.BackgroundTransparency = 1
    messageFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    messageFrame.BorderSizePixel = 0
    messageFrame.Position = UDim2.fromScale(0, 0.9)
    messageFrame.Size = UDim2.fromScale(1, 0.1)

    local warning = Instance.new("ImageLabel")
    warning.Name = "Warning"
    warning.BackgroundTransparency = 1
    warning.BorderColor3 = Color3.fromRGB(0, 0, 0)
    warning.BorderSizePixel = 0
    warning.Image = "rbxassetid://97186161743545"
    warning.Size = UDim2.fromScale(0.5, 0.5)
    warning.SizeConstraint = Enum.SizeConstraint.RelativeYY
    warning.Parent = messageFrame

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout.Padding = UDim.new(0, 5)
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.Parent = messageFrame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.AutomaticSize = Enum.AutomaticSize.X
    messageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.BackgroundTransparency = 1
    messageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    messageLabel.BorderSizePixel = 0
    messageLabel.FontFace = Font.new("rbxasset://fonts/families/Arial.json")
    messageLabel.Size = UDim2.fromScale(0, 0.3)
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(245, 245, 240)
    messageLabel.TextScaled = true
    messageLabel.TextSize = 14
    messageLabel.TextStrokeColor3 = Color3.fromRGB(12, 23, 19)
    messageLabel.TextStrokeTransparency = 0
    messageLabel.TextWrapped = true
    messageLabel.Parent = messageFrame

    return messageFrame
end

function Messages.fade(frame, transparency)
	for _, v in pairs(frame:GetDescendants()) do
		if v:IsA("GuiObject") then
			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(1), {TextTransparency = transparency}):Play()
            elseif v:IsA("ImageLabel") then
                TweenService:Create(v, TweenInfo.new(1), {ImageTransparency = transparency}):Play()
			else
				TweenService:Create(v, TweenInfo.new(1), {Transparency = transparency}):Play()
			end	
		end
	end
    -- Clean up frame
    frame:Destroy()
end

function Messages.showMessage(message)
    local messageFrame = Messages.createMessage(message)
		UIService.createScope(messageFrame)
		task.delay(3, function()
			Messages.fade(messageFrame, 0)
		end)
end


return Messages