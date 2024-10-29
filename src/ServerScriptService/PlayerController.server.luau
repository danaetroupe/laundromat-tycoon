local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

local PD = require(ReplicatedStorage.Data.PlayerData)

local PlayerEvents = ReplicatedStorage.Events.PlayerEvents
local PlacementEvents = ReplicatedStorage.Events.PlacementEvents

type PlayerData = PD.PlayerData
local PlayerInfo : PlayerData = {}

local function Init() : nil -- Initalize service
    for _, tycoon in workspace.Tycoons:GetChildren() do
        local claim : Part = tycoon.Claim
        claim.Touched:Connect(function(touch)
            local character = touch.Parent
            local player = Players:GetPlayerFromCharacter(character)
            if player and not PlayerInfo[player] then -- assign tycoon to player
                claim.Transparency = 1
                claim.CanCollide = false
                PlayerInfo[player] = PlayerService.AssignToPlayer(player, tycoon)
                PlacementService.Init(tycoon.Base)
            end
        end)
    end
end

Init()

PlayerEvents.GetPlayerData.OnServerInvoke = function(player : Player)
    return PlayerInfo[player]
end

-- Places object on server side
PlacementEvents.InvokePlacement.OnServerEvent:Connect(function(player : Player, model : Model, cf : CFrame) : nil
    local data = PlayerInfo[player]
    if data then
        PlayerService.StoreObject(data, model)
        PlacementService.Place(model, cf, PlayerService.GetBasePartFromData(PlayerInfo[player]))
    end
end)

Players.PlayerRemoving:Connect(function(plr) -- Clear player data 
    PlayerInfo[plr] = nil
end)

PlayerEvents.GetServerPlayerData.OnInvoke = function(player : Player)
    return PlayerInfo[player]
end

PlayerEvents.ChangeActive.OnServerInvoke = function(player)
    return PlayerService.ToggleActive(PlayerInfo[player])
end

-- Set player data to new value
PlayerEvents.ChangeValue.Event:Connect(function(player : Player, key : string, value : any)
    PlayerInfo[player][key] = value
end)

-- Execute function on server
PlayerEvents.ExecuteOnServer.OnServerInvoke = function(player : Player, func : string, ...)
    if PlayerInfo[player] then
        return if ... ~= nil then PlayerService[func](..., PlayerInfo[player]) else PlayerService[func](PlayerInfo[player])
    end
end