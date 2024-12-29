local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)

local TAKEN = "Taken"
local _Data = {}

Players.PlayerAdded:Connect(function(player)
    for _, tycoon in _Data["Tycoons"].GetChildren() do
        if tycoon:GetAttribute(TAKEN) == false then
            tycoon:SetAttribute(TAKEN, true)
            PlayerService.AssignToPlayer(player, tycoon)
            local entry : Part = tycoon:FindFirstChild("Entry")
            local character = player.Character or player.CharacterAdded:Wait()
            character.HumanoidRootPart.CFrame = entry.CFrame

            Players.PlayerRemoving:Connect(function(plr)
                if player ~= plr then return end
                tycoon:SetAttribute(TAKEN, false)
                PlayerService.DestroyData(player)
            end)
            break
        end
    end
end)

local function Init() : () -- Initalize service
    _Data["Tycoons"] = workspace:FindFirstChild("Tycoons")
    for _, tycoon in _Data["Tycoons"].GetChildren() do
        tycoon:SetAttribute(TAKEN, false)
    end
end

Init()
