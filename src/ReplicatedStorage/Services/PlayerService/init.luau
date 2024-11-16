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

local isServer: boolean = RunService:IsServer()
local LocalPlayer: Player = Players.LocalPlayer
local PlayerService = {}

-- GETTERS ------------------------------------------------------------------------------------
-- Get table of player data
function PlayerService.GetPlayerData(player : Player) : PlayerData 
    return if isServer then PlayerEvents.GetServerPlayerData:Invoke(player) else PlayerEvents.GetPlayerData:InvokeServer(player)
end

-- Returns base part
function PlayerService.GetBasePartFromPlayer(player : Player) : Part?
    local data: PlayerData  = PlayerService.GetPlayerData(player)
    return if data.tycoon then data.tycoon:FindFirstChild("Base") :: Part? else nil
end

-- Returns base part from player data (use on server)
function PlayerService.GetBasePartFromData(data : PlayerData) : Part?
    return if data.tycoon then data.tycoon:FindFirstChild("Base") :: Part? else nil
end

-- Gets entry point of tycoon for routing purposes
function PlayerService.GetStartPoint(player : Player) : Part?
    local data: PlayerData  = PlayerService.GetPlayerData(player)
    return if data.tycoon then data.tycoon:FindFirstChild("Entry") :: Part? else nil
end

function PlayerService.GetEndPoint(player : Player) : Part?
    local data: PlayerData  = PlayerService.GetPlayerData(player)
    return if data.tycoon then data.tycoon:FindFirstChild("Exit") :: Part? else nil
end

-- Request current player key (typically followed by a request to clear key)
function PlayerService.GetKey(player : Player) : ToolInfo?
    return PlayerService.GetPlayerData(player).key
end

-- Get spawn rate
function PlayerService.GetSpawnRate(player : Player) : number
    return PlayerService.GetPlayerData(player)["spawn_rate"]
end

-- Get tycoon model
function  PlayerService.GetTycoon(player : Player) : Model?
    return PlayerService.GetPlayerData(player).tycoon
end

-- Get player money
function PlayerService.GetMoney(player : Player) : number
    return PlayerService.GetPlayerData(player)["money"]
end

-- Get building status
function PlayerService.GetIsBuilding(player:Player) : boolean
    return PlayerService.GetPlayerData(player)["isBuilding"]
end

-- GAME FUNCTIONALITY -------------------------------------------------------------------------
-- Assigns tycoon to player
function PlayerService.AssignToPlayer(player : Player, tycoon : Model) : PlayerData 
    local data : PlayerData = table.clone(PlayerDataModule)
    data.player = player
    data.tycoon = tycoon
    PlayerEvents.ActiveToggled:Fire(data.player, data.active)

    local folder = Instance.new("Folder") -- create folder to store temp assets
    folder.Name = player.Name
    folder.Parent = ReplicatedStorage.Temp
    Players.PlayerRemoving:Connect(function(plr: Player) -- set to destroy folder when leave
        if player == plr then
            folder:Destroy()
        end
    end)
    data.temp = folder

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

-- Assign key (typically a tool)
function PlayerService.AssignKey(key : ToolInfo, serverData : PlayerData?) : boolean
    if isServer then
        if not serverData or serverData.key then return false end
        serverData.key = key
        return true
    else
        ContextActionService:BindAction(SETDOWN, PlayerService._handleInput, true, Enum.KeyCode.P)
        MobileService.CreateMobileButton(SETDOWN, placeImg)
        return PlayerEvents.ExecuteOnServer:InvokeServer("AssignKey", key)
    end
end

-- Accepts player data as parameter on server or player as paramater on client
function PlayerService.ClearKey(data : PlayerData?) : ()
    if isServer then
        if data then 
            data.key = nil 
        end
    else
        ContextActionService:UnbindAction(SETDOWN)
        PlayerEvents.ExecuteOnServer:InvokeServer("ClearKey")
    end
end

function PlayerService.MoveToNPCFolder(player : Player, model : Model) : ()
    local data: PlayerData = PlayerService.GetPlayerData(player)
    local folder = if data.tycoon then data.tycoon:FindFirstChild("NPCs") :: Folder else Instance.new("Folder")
    folder.Name = "NPCs"
    folder.Parent = data.tycoon
    model.Parent = folder
end

-- Update leaderstats value
function PlayerService._UpdateLeaderstats(player : Player, value : number) : ()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local moneyVal = leaderstats:FindFirstChild("Money") :: IntValue
        moneyVal.Value = value
    end
end

-- Add money to player 
function PlayerService.AddMoney(data : PlayerData) : ()
    if isServer then
        local newAmt = data.money + data.profit
        PlayerEvents.ChangeValue:Fire(data.player, "money", newAmt)
        PlayerService._UpdateLeaderstats(data.player, newAmt)
    else
        PlayerEvents.ExecuteOnServer:InvokeServer("AddMoney")
    end
end

-- Checks if player can purchase item, and if yes, then makes purchase
function PlayerService.MakePurchase(cost : number, data : PlayerData?) : boolean
    if isServer then
        if not data then return error('Player data does not exist') end
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

function PlayerService._isWithinBounds(position : Vector3): ()
    local floorPart: Part? = PlayerService.GetBasePartFromPlayer(LocalPlayer)
    if not floorPart then return end
    local floorSize: Vector3 = floorPart.Size
    local floorPos: Vector3 = floorPart.Position

    local xMin: number = floorPos.X - (floorSize.X / 2)
    local xMax: number = floorPos.X + (floorSize.X / 2)
    local zMin: number = floorPos.Z - (floorSize.Z / 2)
    local zMax: number = floorPos.Z + (floorSize.Z / 2)

    return position.X >= xMin and position.X <= xMax and position.Z >= zMin and position.Z <= zMax
end

function PlayerService._handleInput(name, userInputState, _input)
    if userInputState == Enum.UserInputState.Begin and name == SETDOWN then
        -- Get player key and position
        local character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum: Part = character:WaitForChild("HumanoidRootPart") :: Part
        local lookVector: Vector3 = hum.CFrame.LookVector
        local position: Vector3 = hum.Position + (lookVector * 2)
        local key: ToolInfo? = PlayerService.GetKey(LocalPlayer)
        --  Check if valid
        if key and PlayerService._isWithinBounds(position) then
            PlayerService.MoveToWorld(key, position)
        end
    end
end

function PlayerService.MoveToWorld(tool : ToolInfo, position : Vector3) : ()
    if isServer then
        if not tool.model then return end
        local handle: Instance? = tool.model:FindFirstChild("Handle")
        if not handle then return end
        handle.Name = "NotHandle"
        tool.model.Parent = workspace
        if not tool.model.PrimaryPart then return end
        tool.model.PrimaryPart.Anchored = true
    else
        PlayerService.ClearKey()
        -- Create prompt on client to pick basket back up
        local prompt = Instance.new("ProximityPrompt")
        if not tool.model or tool.model.PrimaryPart then return end
        prompt.Parent = tool.model.PrimaryPart
        prompt.ObjectText = "Basket"
        prompt.ActionText = "Pick Up"
        -- If prompt triggered, then reassign key and destroy prompt
        prompt.Triggered:Connect(function(player)
            -- Check to make sure player doesn't have existing key
            if not PlayerService.GetKey(LocalPlayer) then
                ToolService._ReEnableTool(tool)
                tool = ToolService.EquipExistingTool(player,tool)
                PlayerService.AssignKey(tool)
                prompt:Destroy()
            end
        end)
        PlayerEvents.ExecuteOnServer:InvokeServer("MoveToWorld", tool, position)
    end
end

-- Toggle via client
function PlayerService.SetBuildState(status : boolean, playerdata : PlayerData?)
    if isServer then
        if not playerdata then return end
        PlayerEvents.ChangeValue:Fire(playerdata.player, "isBuilding", status)
    else
        PlayerEvents.ExecuteOnServer:InvokeServer("SetBuildState", status)
    end
end

return PlayerService