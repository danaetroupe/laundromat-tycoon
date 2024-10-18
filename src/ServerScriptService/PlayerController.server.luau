local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

local PlayerEvents = ReplicatedStorage.Events.PlayerEvents
local PlacementEvents = ReplicatedStorage.Events.PlacementEvents

local PlayerData = {}

local function Init() : nil -- Initalize service
    for _, tycoon in workspace.Tycoons:GetChildren() do
        local claim : Part = tycoon.Claim
        claim.Touched:Connect(function(touch)
            local character = touch.Parent
            local player = Players:GetPlayerFromCharacter(character)
            if player and not PlayerData[player] then -- assign tycoon to player
                claim.Transparency = 1
                claim.CanCollide = false
                PlayerData[player] = PlayerService.AssignToPlayer(player, tycoon)
                PlacementService.Init(tycoon.Base)
            end
        end)
    end   
end

Init()

PlayerEvents.GetPlayerData.OnServerInvoke = function(player : Player)
    return PlayerData[player]
end

-- Places object on server side
PlacementEvents.InvokePlacement.OnServerEvent:Connect(function(player : Player, model : Model, cf : CFrame) : nil
    local data = PlayerData[player]
    if data then
        PlayerService.StoreObject(data, model)
        PlacementService.Place(model, cf, PlayerService.GetBasePartFromData(PlayerData[player]))
    end
end)

Players.PlayerRemoving:Connect(function(plr) -- Clear player data 
    PlayerData[plr] = nil
end)

PlayerEvents.GetServerPlayerData.OnInvoke = function(player : Player)
    return PlayerData[player]
end

PlayerEvents.ChangeActive.OnServerInvoke = function(player)
    return PlayerService.ToggleActive(PlayerData[player])
end

-- Set player data to new value
PlayerEvents.ChangeValue.Event:Connect(function(player : Player, key : string, value : any)
    PlayerData[player][key] = value
end)