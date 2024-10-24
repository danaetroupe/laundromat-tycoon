local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ObjectService = require(ReplicatedStorage.Services.ObjectService)

local PlayerEvents = ReplicatedStorage.Events.PlayerEvents

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Move = require(script.Move)
--local Destroy = require(script.Destroy)
local Active = require(script.Active)
local PlaceObject = require(script.PlaceObject)

local DevButtons : ScreenGui = PlayerGui:WaitForChild("DevButtons")

Move(DevButtons.LeftFrame.Move)
Active(DevButtons.LeftFrame.Toggle)

PlayerEvents.InitTycoon.OnClientEvent:Connect(function(playerData)
    for _, object in ObjectService.GetNames() do
        local button = DevButtons.RightFrame.Template:Clone()
        button.Parent = DevButtons.RightFrame
        local data = ObjectService.CreateNew(object, LocalPlayer)
        button.Text = ObjectService.GetName(data)
         PlaceObject(button, data)
     end
     DevButtons.RightFrame.Template.Visible = false
end)