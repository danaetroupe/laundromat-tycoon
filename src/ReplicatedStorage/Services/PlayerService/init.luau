--!strict
-- This function is equipped to modify tycoon data

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerData = require(ReplicatedStorage.Data.PlayerData)
local PlayerEvents = ReplicatedStorage.Events.PlayerEvents

local isServer = RunService:IsServer()
local PlayerService = {}

function PlayerService.Reset(data : table) : nil
    data["claim"].Transparency = 0
end

function PlayerService.GetClaim(data : table) : Part
    return data["claim"]
end

-- Assigns tycoon to player
function PlayerService.AssignToPlayer(player : Player, tycoon : Model) : nil 
    local data = table.clone(PlayerData.Get())
    data["player"] = player
    data["tycoon"] = tycoon
    PlayerEvents.ActiveToggled:Fire(data["player"], data["active"])

    local folder = Instance.new("Folder") -- create folder to store temp assets
    folder.Name = player.Name
    folder.Parent = ReplicatedStorage.Temp
    Players.PlayerRemoving:Connect(function(plr) -- set to destroy folder when leave
        if player == plr then
            folder:Destroy()
        end
    end)
    data["temp"] = folder
    
    PlayerEvents.InitTycoon:FireClient(player, data)
    return data
end

-- Get table of player data
function PlayerService.GetPlayerData(player : Player) : table 
    return if isServer then PlayerEvents.GetServerPlayerData:Invoke(player) else PlayerEvents.GetPlayerData:InvokeServer(player)
end

-- Returns base part from player value (use on client)
function PlayerService.GetBasePartFromPlayer(player : Player) : Part
    return PlayerService.GetPlayerData(player)["tycoon"].Base
end

-- Returns base part from player data (use on server)
function PlayerService.GetBasePartFromData(data : table) : Part
    return data["tycoon"].Base
end

-- Inserts given model into baseobjects -- !! TODO: Add additional state property to objects (inventory or in world)
function PlayerService.StoreObject(data : table, model : Model)
    table.insert(data["baseObjects"], model)
end

-- Returns boolean to specify is part is in the baseObjects table
function PlayerService.IsBaseObject(player : Player, obj : Model) : boolean
    local playerData = PlayerService.GetPlayerData(player)
    local baseObjects = playerData["tycoon"].Base.BaseObjects:GetChildren()
    return if table.find(baseObjects, obj) then true else false
end

-- Toggles active value of playerdata
function PlayerService.ToggleActive(data : table) : boolean
    if not isServer then
        return PlayerEvents.ChangeActive:InvokeServer()
    else
        data["active"] = not data["active"]
        PlayerEvents.ActiveToggled:Fire(data["player"], data["active"])
        return data["active"]

    end
end

-- Gets entry point of tycoon for routing purposes
function PlayerService.GetStartPoint(player : Player) : Part
    return PlayerService.GetPlayerData(player)["tycoon"].Entry
end

function PlayerService.GetEndPoint(player : Player) : Part
    return PlayerService.GetPlayerData(player)["tycoon"].Exit
end

-- Get temp folder for storage
function PlayerService.GetTempFolder(player : Player) : Folder
    return PlayerService.GetPlayerData(player)["temp"]
end

return PlayerService