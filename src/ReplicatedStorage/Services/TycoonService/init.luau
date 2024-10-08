--!strict
-- This function is equipped to modify tycoon data

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TycoonData = require(ReplicatedStorage.Data.TycoonData)
local TycoonEvents = ReplicatedStorage.Events.TycoonEvents

local isServer = RunService:IsServer()
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

function TycoonService.GetBasePart(data : table) : Part -- Returns base part for tycoon
    return data["base"]
end 

function TycoonService.GetPlayerData(player : Player) : table -- Request player data from client
    if not isServer then
        return TycoonEvents.GetPlayerData:InvokeServer(player)
    else
        error("Requesting TycoonService.GetPlayerData from server")
    end
end

return TycoonService