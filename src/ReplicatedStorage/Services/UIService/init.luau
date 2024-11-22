local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UIService = {}

function UIService.createScope(object) : ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Parent = LocalPlayer.PlayerGui
    object.Parent = gui

    -- If no more children, clean up gui :)
    gui.ChildRemoved:Connect(function()
        if #gui:GetChildren() == 0 then
            gui:Destroy()
        end
    end)

    return gui
end

function UIService.changeButtonEnabled(folder, active : boolean, name : string)
    if name then
        local button = folder:FindFirstChild(name)
        if button:IsA("ImageButton") then
            button.ImageColor3 = if active then Color3.new(1,1,1) else Color3.new(0.345098, 0.345098, 0.345098)
            button.Active = active
        end
    else
        for _, button :ImageButton in folder:GetChildren() do
            if button:IsA("ImageButton") then
                button.ImageColor3 = if active then Color3.new(1,1,1) else Color3.new(0.345098, 0.345098, 0.345098)
                button.Active = active
            end
        end
    end
end

local typing -- todo: hacky fix may need to come back later
local label
function UIService.TypingEffect(textLabel, text, speed)
    if typing and textLabel == label then 
        coroutine.close(typing)
    end
    label = textLabel
    typing = coroutine.create(function()
        speed = speed or 0.08
        local i = 1
        while i <= #text do
            textLabel.Text = string.sub(text, 1, i)
            task.wait(speed)
            i += 1
        end
    end)
    coroutine.resume(typing)
end

return UIService