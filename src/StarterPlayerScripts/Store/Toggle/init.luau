-- Function to toggle frame visibility
return function(button : TextButton | ImageButton, frames : Folder)
    local name = button.Name

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