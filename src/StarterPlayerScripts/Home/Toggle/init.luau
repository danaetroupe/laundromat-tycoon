local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
-- Function to toggle frame visibility

local function togglePanel(name : string, frames)
    for _, frame : Instance in frames:GetChildren() do
        if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
            if frame.Name == name then
                frame.Visible = not frame.Visible
            else
                frame.Visible = false
            end
        end
    end
end


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

return function(buttons, frames)
    for _, button in buttons:GetChildren() do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            -- Activate panel toggle
            button.Activated:Connect(function()
                togglePanel(button.Name, frames)
            end) 
            ContextActionService:BindAction(button.Name, function(_name, state, _obj)
                if state == Enum.UserInputState.Begin then
                    togglePanel(button.Name, frames)
                end
            end, false, KEYS[button.LayoutOrder+1])
        end
    end
    
end