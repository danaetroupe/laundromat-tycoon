local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GREEN= "rbxassetid://132007560367733"
local YELLOW = "rbxassetid://119932121692936"
local RED = "rbxassetid://77219767567050"

local IMAGES = {GREEN, YELLOW, RED}

local NPCData = require(ReplicatedStorage.Data.NPCData)
type NPC = NPCData.NPC

-- Returns a billboard gui to be parented to an npc
return function(model : Model, image : number)  
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "BillboardGui"
    billboardGui.Active = true
    billboardGui.ClipsDescendants = false
    billboardGui.LightInfluence = 1
    billboardGui.MaxDistance = 50
    billboardGui.Size = UDim2.fromScale(1.5, 1.5)
    billboardGui.StudsOffset = Vector3.new(0, 4.5, 0)
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    imageLabel.BackgroundTransparency = 1
    imageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    imageLabel.BorderSizePixel = 0
    imageLabel.Image = IMAGES[image]
    imageLabel.Size = UDim2.fromScale(1, 1)
    imageLabel.Parent = billboardGui
    
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0, 20)
    uICorner.Parent = imageLabel

    billboardGui.Parent = model
    
    for _ = 0, 5 do
        print('before tween')
        local tween = TweenService:Create(imageLabel, 
            TweenInfo.new(0.1, Enum.EasingStyle.Elastic), 
            {Rotation = 15})
        tween:Play()
        tween.Completed:Wait()
        local tween2 = TweenService:Create(imageLabel, 
            TweenInfo.new(0.1, Enum.EasingStyle.Elastic), 
            {Rotation = -15})
        tween2:Play()
        tween.Completed:Wait()
    end
    imageLabel.Rotation = 0
    local tween: Tween = TweenService.Create(imageLabel, TweenInfo.new(0), {Transparency = 1})
    tween:Play()
    tween.Completed:Wait()
    billboardGui:Destroy()
    print('destroyed')
end
