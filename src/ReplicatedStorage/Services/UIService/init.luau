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

function UIService.CreateScopeWithMultipleObjects(objects) : ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Parent = LocalPlayer.PlayerGui
    for _, object in objects do
        object.Parent = gui
    end

    -- If no more children, clean up gui :)
    gui.ChildRemoved:Connect(function()
        if #gui:GetChildren() == 0 then
            gui:Destroy()
        end
    end)

    return gui
end


function UIService.changeButtonEnabled(folder: Folder, active : boolean, name : string?)
    if name then
        local button = folder:FindFirstChild(name)
        if button:IsA("ImageButton") then
            button.ImageColor3 = if active then Color3.new(1,1,1) else Color3.new(0.345098, 0.345098, 0.345098)
            button.Active = active
        end
    else
        for _, button in folder:GetChildren() do
            if button:IsA("ImageButton") then
                button.ImageColor3 = if active then Color3.new(1,1,1) else Color3.new(0.345098, 0.345098, 0.345098)
                button.Active = active
            end
        end
    end
end

local typing -- todo: hacky fix may need to come back later
function UIService.TypingEffect(textLabel, text, speed : number?, complete : BoolValue?)
    if complete then
        local disconnect
        disconnect = complete.Changed:Connect(function(value)
            if value then
                if typing then
                    coroutine.close(typing)
                end
                textLabel.Text = text
                typing = nil
                disconnect:Disconnect()
            end
        end)
    end

    typing = coroutine.create(function()
        speed = speed or 0.08
        local i = 1
        while i <= #text do
            textLabel.Text = string.sub(text, 1, i)
            task.wait(speed)
            i += 1
        end
        if complete then 
            complete.Value = true 
        end
        typing = nil
    end)
    coroutine.resume(typing)
end

return UIService