local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Store = require(ReplicatedStorage.UI.Store)
local PlaceObject = require(ReplicatedStorage.UI.Store.PlaceObject)
local UIService = require(ReplicatedStorage.Services.UIService)

local LocalPlayer = Players.LocalPlayer


return function()
    local moneyVal = LocalPlayer:FindFirstChild("leaderstats"):FindFirstChild("Money")
    if not moneyVal then return end
    
    -- Initalize UI
    local store = Store.createMenu(moneyVal.Value)
    local gui = UIService.createScope(store)
    local keybinds = Store.createBuildKeybinds()
    keybinds.Parent = gui

    -- Initalize control values
    local isBuilding = Instance.new("BoolValue")
    isBuilding.Value = false
    local isEditing = Instance.new("BoolValue")

    -- Connect icons to game functionality
    for _, icon : ImageButton in store:GetChildren() do
        if icon:IsA("ImageButton") then
            PlaceObject.Init(icon, icon:GetAttribute("name"), isBuilding, isEditing)
        end
    end

    -- Update store values if money changes
    moneyVal.Changed:Connect(function(newValue)
        Store.updateIconValues(store, newValue)
    end)

    isEditing.Value = true
    -- Toggle keybind/store visibility
    isBuilding.Changed:Connect(function(newValue)
        Store.toggle(store, not newValue)
        isEditing.Value = not newValue
        if not UserInputService.TouchEnabled then -- Only show keybinds if not on touch screen
            Store.toggleKeybinds(keybinds, newValue) 
        end
    end)

    return function() -- Destroy when quit
        PlaceObject.quit()
        gui:Destroy()
        isBuilding:Destroy()
        isEditing.Value = false
        isEditing:Destroy()
    end
end