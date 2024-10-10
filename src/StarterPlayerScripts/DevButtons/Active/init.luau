local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)

local LocalPlayer = Players.LocalPlayer

return function(button : TextButton)
    button.Activated:Connect(function()
        local active = PlayerService.ToggleActive(LocalPlayer)
        button.Text = if active then "Toggle OFF" else "Toggle ON"
    end)
end