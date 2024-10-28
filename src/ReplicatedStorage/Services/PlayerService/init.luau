--!strict
-- This function is equipped to modify tycoon data

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ToolService = require(ReplicatedStorage.Services.ToolService)
local PlayerDataModule = require(ReplicatedStorage.Data.PlayerData)
local ToolData = require(ReplicatedStorage.Data.ToolData)
local MobileService = require(ReplicatedStorage.Services.MobileService)

local PlayerEvents = ReplicatedStorage.Events.PlayerEvents

type PlayerData = PlayerDataModule.PlayerData
type ToolInfo = ToolData.ToolInfo

local SETDOWN = "SETDOWN"

local placeImg = "rbxassetid://90664024735834"

local isServer = RunService:IsServer()
local LocalPlayer = if not isServer then Players.LocalPlayer else nil
local PlayerService = {}

-- GETTERS ------------------------------------------------------------------------------------
-- Get table of player data
function PlayerService.GetPlayerData(player : Player) : PlayerData 
    return if isServer then PlayerEvents.GetServerPlayerData:Invoke(player) else PlayerEvents.GetPlayerData:InvokeServer(player)
end

-- Returns base part
function PlayerService.GetBasePartFromPlayer(player : Player) : Part
    return PlayerService.GetPlayerData(player).tycoon.Base
end

-- Returns base part from player data (use on server)
function PlayerService.GetBasePartFromData(data : PlayerData) : Part
    return data.tycoon.Base
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

-- Request current player key (typically followed by a request to clear key)
function PlayerService.GetKey(player : Player) : ToolInfo
    return PlayerService.GetPlayerData(player).key
end

-- Get spawn rate
function PlayerService.GetSpawnRate(player : Player) : number
    return PlayerService.GetPlayerData(player)["spawn_rate"]
end

-- Get tycoon model
function  PlayerService.GetTycoon(player : Player) : Model
    return PlayerService.GetPlayerData(player)["tycoon"]
end

-- Get player money
function PlayerService.GetMoney(player : Player) : number
    return PlayerService.GetPlayerData(player)["money"]
end

-- GAME FUNCTIONALITY -------------------------------------------------------------------------
-- Assigns tycoon to player
function PlayerService.AssignToPlayer(player : Player, tycoon : Model) : PlayerData 
    local data : PlayerData = table.clone(PlayerDataModule)
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

    -- Initalize leaderboard
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local money = Instance.new("IntValue")
    money.Name = "Money"
    money.Value = data.money
    money.Parent = leaderstats
    return data
end

-- Inserts given model into baseobjects
function PlayerService.StoreObject(data : PlayerData, model : Model)
    table.insert(data.baseObjects, model)
end

-- Returns boolean to specify is part is in the baseObjects table
function PlayerService.IsBaseObject(player : Player, obj : Model) : boolean
    local playerData = PlayerService.GetPlayerData(player)
    local baseObjects = playerData["tycoon"].Base.BaseObjects:GetChildren()
    return if table.find(baseObjects, obj) then true else false
end

-- Toggles active value of playerdata
function PlayerService.ToggleActive(data : PlayerData) : boolean
    if not isServer then
        return PlayerEvents.ChangeActive:InvokeServer()
    else
        data["active"] = not data["active"]
        PlayerEvents.ActiveToggled:Fire(data["player"], data["active"])
        return data["active"]
    end
end

-- Move item into temp storage
function PlayerService.MoveToTemp(object, serverData) : nil
    if isServer then
        object.Parent = serverData["temp"]
    else
        return PlayerEvents.ExecuteOnServer:InvokeServer("MoveToTemp", object)
    end
end

-- Assign key (typically a tool)
function PlayerService.AssignKey(key : Tool, serverData : PlayerData) : boolean
    if isServer then
        if serverData["key"] then return false end
        serverData["key"] = key
        return true
    else
        ContextActionService:BindAction(SETDOWN, PlayerService._handleInput, true, Enum.KeyCode.P)
        MobileService.CreateMobileButton(SETDOWN, placeImg)
        return PlayerEvents.ExecuteOnServer:InvokeServer("AssignKey", key)
    end
end

-- Accepts player data as parameter on server or player as paramater on client
function PlayerService.ClearKey(player) : nil
    if isServer then
        player["key"] = nil
    else
        ContextActionService:UnbindAction(SETDOWN)
        PlayerEvents.ExecuteOnServer:InvokeServer("ClearKey")
    end
end

function PlayerService.MoveToNPCFolder(player : Player, model : Model) : nil
    model.Parent = PlayerService.GetPlayerData(player)["tycoon"]["NPCs"]
end

-- Update leaderstats value
function PlayerService._UpdateLeaderstats(player : Player, value : number) : nil
    local moneyVal : IntValue = player.leaderstats.Money
    moneyVal.Value = value
end

-- Add money to player 
function PlayerService.AddMoney(data : PlayerData) : nil
    if isServer then
        local newAmt = data.money + data.profit
        PlayerEvents.ChangeValue:Fire(data.player, "money", newAmt)
        PlayerService._UpdateLeaderstats(data.player, newAmt)
    else
        PlayerEvents.ExecuteOnServer:InvokeServer("AddMoney")
    end
end

-- Checks if player can purchase item, and if yes, then makes purchase
function PlayerService.MakePurchase(cost : number, data : PlayerData) : boolean
    if isServer then
        if data.money >= cost then
            local newAmt = data.money - cost
            PlayerEvents.ChangeValue:Fire(data.player, "money", newAmt)
            PlayerService._UpdateLeaderstats(data.player, newAmt)
            return true
        end
        return false
    else
        return PlayerEvents.ExecuteOnServer:InvokeServer("MakePurchase", cost)
    end
end

function PlayerService._isWithinBounds(position)
    local floorPart = PlayerService.GetBasePartFromPlayer(LocalPlayer)
    local floorSize = floorPart.Size
    local floorPos = floorPart.Position

    local xMin = floorPos.X - (floorSize.X / 2)
    local xMax = floorPos.X + (floorSize.X / 2)
    local zMin = floorPos.Z - (floorSize.Z / 2)
    local zMax = floorPos.Z + (floorSize.Z / 2)

    return position.X >= xMin and position.X <= xMax and position.Z >= zMin and position.Z <= zMax
end

function PlayerService._handleInput(name, userInputState, _input)
    if userInputState == Enum.UserInputState.Begin and name == SETDOWN then
        -- Get player key and position
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local lookVector = character.HumanoidRootPart.CFrame.LookVector
        local position = character.HumanoidRootPart.Position + (lookVector * 2)
        local key = PlayerService.GetKey(LocalPlayer)
        --  Check if valid
        if key and PlayerService._isWithinBounds(position) then
            PlayerService.MoveToWorld(key, position)
        end
    end
end

function PlayerService.MoveToWorld(tool : ToolInfo, position : Vector3) : nil
    if isServer then
        tool.model.Handle.Name = "NotHandle"
        tool.model.Parent = workspace
        tool.model.PrimaryPart.Anchored = true
    else
        PlayerService.ClearKey(LocalPlayer)
        -- Create prompt on client to pick basket back up
        local prompt = Instance.new("ProximityPrompt")
        prompt.Parent = tool.model.PrimaryPart
        prompt.ObjectText = "Basket"
        prompt.ActionText = "Pick Up"
        -- If prompt triggered, then reassign key and destroy prompt
        prompt.Triggered:Connect(function(player)
            -- Check to make sure player doesn't have existing key
            if not PlayerService.GetKey(LocalPlayer) then
                ToolService._ReEnableTool(tool)
                ToolService.EquipExistingTool(player,tool)
                PlayerService.AssignKey(tool)
                prompt:Destroy()
            end
        end)
        PlayerEvents.ExecuteOnServer:InvokeServer("MoveToWorld", tool, position)
    end
end

return PlayerService