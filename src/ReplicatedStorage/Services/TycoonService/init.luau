--!strict
-- This function is equipped to modify tycoon data

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TycoonData = require(ReplicatedStorage.Data.TycoonData)

local TycoonService = {}

function TycoonService.Init() : table
    local data = TycoonData.Get("tycoon")
    local allData = {}
    for _, tycoon : Model in workspace.Tycoons:GetChildren() do
        local tycoonData = table.clone(data)
        tycoonData["base"] = tycoon.Base
        tycoonData["claim"] = tycoon.Claim
        table.insert(allData, tycoonData)
    end
    return allData
end

function TycoonService.GetClaim(data : table) : Part
    return data["claim"]
end

function TycoonService.AssignToPlayer(data : table, player) : nil -- Assigns tycoon to player
    print('made it this far')
    data["player"] = player
    data["claim"].Transparency = 1
    data["claim"].CanCollide = false

    Players.PlayerRemoving:Connect(function(plr)
        if player == plr then
            data["player"] = nil
            data["claim"].Transparency = 0
            data["money"] = 0
        end
    end)
end

return TycoonService