-- Function to toggle frame visibility
return function(buttons, frames)
    for _, button in buttons:GetChildren() do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local name = button.Name
            -- Activate panel toggle
            button.Activated:Connect(function()
                for _, frame : Instance in frames:GetChildren() do
                    if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
                        if frame.Name == name then
                            frame.Visible = not frame.Visible
                        else
                            frame.Visible = false
                        end
                    end
                end
            end) 
        end
    end
    
end