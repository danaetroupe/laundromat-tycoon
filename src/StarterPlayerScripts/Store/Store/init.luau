-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local InventoryService = require(ReplicatedStorage.Services.InventoryService)

-- Data
local ObjectData = require(ReplicatedStorage.Data.ObjectData)
local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)

-- Types
type Object = ObjectData.Object


return function(icon : Frame, iconFrame : Frame, dataFrame : Frame)
    local names = Objects.GetObjectNames()
    for _, name in names do
        local object : Object = Objects.GetObject(name)
        -- Clone icon and move to iconFrame
        local clone : TextButton = icon:Clone()
        clone.Label.Text = object.name
        clone.Price.Text = "$"..object.cost
        clone.Visible = true
        clone.Parent = iconFrame
        -- TODO: Set up clone.ImageLabel.Image = object.image

        -- Show item in more detail
        clone.Activated:Connect(function()
            local buyButton : TextButton = dataFrame.Buy
            dataFrame.Visible = true
            dataFrame.Label.Text = object.name
            dataFrame.Price.Text = "$"..object.cost
            -- Buy object
            buyButton.Activated:Connect(function()
                local success = InventoryService.BuyItem(name)
                buyButton.BackgroundColor3 = if success then Color3.new(0, 1, 0) else Color3.new(1, 0, 0)
                task.wait(0.2)
                buyButton.BackgroundColor3 = Color3.new(1,1,1)
            end)
        end)
    end
end