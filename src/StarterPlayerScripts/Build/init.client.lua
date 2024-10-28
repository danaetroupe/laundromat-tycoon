local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local PanelsGui : ScreenGui = PlayerGui:WaitForChild("Panels")
local BuildFrame : Frame = PanelsGui.Build
local BuildPanel = BuildFrame:FindFirstChild("Panel")

local Store : ScrollingFrame = BuildPanel:FindFirstChild("Store")
local Inventory : ScrollingFrame = BuildPanel:FindFirstChild("Inventory")

local PlaceObject = require(script.PlaceObject)

local Icon = ReplicatedStorage.Assets.UI:WaitForChild("Icon")

-- Clear UI page for reset
local function clear()
    for _, icon in BuildPanel.Store:GetChildren() do
        if icon:IsA("ImageButton") then
            icon:Destroy()
        end
    end
end

local function showStore()
    clear()
    for _, objectName in Objects.GetObjectNames() do
        print(objectName)
        local button = Icon:Clone()
        button.Parent = Store
        --[[
        todo: implement image
        local image = objects.GetProperty(objectName, "image")
        button.Image =  if image then image else button.Image
        ]]
        button.Top.Text = Objects.GetProperty(objectName, "name")
        local cost = Objects.GetProperty(objectName, "cost")
        button.Display.Text = if cost then "$"..cost else "$ERR"
        PlaceObject(button, objectName, BuildFrame)
     end
end

local function showInventory()
    clear()

end

BuildFrame.Changed:Connect(function(property)
    if property == "Visible" then
        showStore()
    end
end)
