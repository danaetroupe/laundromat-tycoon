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
            print('gui destroyed because no more children')
        end
    end)

    return gui
end

return UIService