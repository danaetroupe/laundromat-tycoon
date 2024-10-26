local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local PanelsGui : ScreenGui = PlayerGui:WaitForChild("Panels")
local Build : Frame = PanelsGui.Build

local Store : ScrollingFrame = Build:FindFirstChild("Store")
local Inventory : ScrollingFrame = Build:FindFirstChild("Inventory")

local PlaceObject = require(script.PlaceObject)

local Icon = ReplicatedStorage.Assets.UI:WaitForChild("Icon")

type BuildState = "Store" | "Inventory"
local currState : BuildState = "Store" 

-- Clear UI page for reset
local function clear()
    for _, icon in Build.Store:GetChildren() do
        if icon:IsA("ImageButton") then
            icon:Destroy()
        end
    end
end

local function showStore()
    clear()
    local objects = Objects.GetAllObjects()
    for _, objectName in Objects.GetObjectNames() do
        local button = Icon:Clone()
        button.Parent = Store
        -- todo: display image
        button.Top.Text = Objects.GetProperty(objectName, "name")
        local cost = Objects.GetProperty(objectName, "cost")
        button.Display.Text = if cost then "$"..cost else "$ERR"
        PlaceObject(button, objectName)
     end
end

local function showInventory()
    clear()

end

Build.Changed:Connect(function(property)
    if property == "Visible" then
        showStore()
    end
end)

