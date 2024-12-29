-- This function is equipped to modify tycoon data

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ObjectService = require(script.Parent.ObjectService)
local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)
local ToolService = require(ReplicatedStorage.Services.ToolService)
local PlayerDataModule = require(ReplicatedStorage.Data.PlayerData)
local ToolData = require(ReplicatedStorage.Data.ToolData)
local MobileService = require(ReplicatedStorage.Services.MobileService)
local PlacementService = require(ReplicatedStorage.Util.PlacementService)

local PlayerEvents = ReplicatedStorage.Events.PlayerEvents
local PlacementEvents = ReplicatedStorage.Events.PlacementEvents

type PlayerData = PlayerDataModule.PlayerData
type ToolInfo = ToolData.ToolInfo

local SETDOWN = "SETDOWN"

local placeImg = "rbxassetid://90664024735834"

local isServer: boolean = RunService:IsServer()
local LocalPlayer: Player = Players.LocalPlayer
local PlayerService = {}
local PlayerInfo = {}

-- GETTERS ------------------------------------------------------------------------------------
-- Get table of player data
function PlayerService.GetPlayerData(player : Player) : PlayerData 
    return if isServer then PlayerInfo[player] else PlayerEvents.ExecuteOnServer:InvokeServer("GetPlayerData", player)
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
function PlayerService.AssignToPlayer(player : Player, tycoon : Model) : ()
    local data : PlayerData = table.clone(PlayerDataModule)
    data.player = player
    data.tycoon = tycoon
    PlayerEvents.ActiveToggled:Fire(data.player, data.active)

    -- Initalize front desk and create prompts
    local baseparts = tycoon:FindFirstChild("BaseParts")
    if baseparts then
        local deskModel = baseparts:FindFirstChild("frontdesk")
        if deskModel then
            local _desk = ObjectService.AttatchToModel("frontdesk", player, deskModel)
            --todo: implement storage mechanisms
        end
    end
    local folder = Instance.new("Folder") -- create folder to store temp assets
    folder.Name = player.Name
    folder.Parent = ReplicatedStorage.Temp
    local baseObjects = PlacementService.Init(tycoon:FindFirstChild("Base") :: Part)
    Players.PlayerRemoving:Connect(function(plr: Player) -- set to destroy folder when leave
        if player == plr then
            folder:Destroy()
            baseObjects:Destroy()
        end
    end)
    data.temp = folder

    -- Initalize leaderboard
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local money = Instance.new("IntValue")
    money.Name = "Money"
    money.Value = data.money
    money.Parent = leaderstats
    PlayerInfo[player] = data
    
end


-- Toggles active value of playerdata
function PlayerService.ToggleActive(player : Player) : boolean
    if not isServer then
        return PlayerEvents.ExecuteOnServer:InvokeServer("ToggleActive", player)
    else
        local data = PlayerInfo[player]
        data["active"] = not data["active"]
        PlayerEvents.ActiveToggled:Fire(data["player"], data["active"])
        return data["active"]
    end
end

-- Assign key (typically a tool)
function PlayerService.AssignKey(key : ToolInfo, player : Player?) : boolean
    if isServer then
        local data = PlayerInfo[player]
        data.key = key
        return true
    else
        ContextActionService:BindAction(SETDOWN, PlayerService._handleInput, true, Enum.KeyCode.P)
        MobileService.CreateMobileButton(SETDOWN, placeImg)
        return PlayerEvents.ExecuteOnServer:InvokeServer("AssignKey", key, LocalPlayer)
    end
end

-- Accepts player data as parameter on server or player as paramater on client
function PlayerService.ClearKey(player) : ()
    if isServer then
        PlayerInfo[player].key = nil
    else
        ContextActionService:UnbindAction(SETDOWN)
        PlayerEvents.ExecuteOnServer:InvokeServer("ClearKey", LocalPlayer)
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
function PlayerService.AddMoney(player : Player) : ()
    if isServer then
        local data = PlayerInfo[player]
        data.money = data.money + data.profit
        PlayerService._UpdateLeaderstats(data.player, data.money)
    else
        PlayerEvents.ExecuteOnServer:InvokeServer("AddMoney", player)
    end
end

-- Checks if player can purchase item, and if yes, then makes purchase
function PlayerService.MakePurchase(player : Player, cost : number) : boolean
    if isServer then
        local data = PlayerInfo[player]
        if data.money >= cost then
            data.money = data.money - cost
            PlayerService._UpdateLeaderstats(data.player, data.money)
            return true
        end
        return false
    else
        return PlayerEvents.ExecuteOnServer:InvokeServer("MakePurchase", player, cost)
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
function PlayerService.SetBuildState(player : Player, status : boolean)
    if isServer then
        PlayerInfo[player]["isBuilding"] = status
    else
        PlayerEvents.ExecuteOnServer:InvokeServer("SetBuildState", player, status)
    end
end

-- EVENTS ----------------------------------------------------------------------------
if isServer then
    PlayerEvents.ExecuteOnServer.OnServerInvoke = function(_player, func : string, ...)
        return PlayerService[func](...)
    end

    -- Places object on server side
    PlacementEvents.InvokePlacement.OnServerEvent:Connect(function(player : Player, model : Model, cf : CFrame) : ()
        local data = PlayerInfo[player]
        if data then
            table.insert(data.baseObjects, model)
            PlacementService.Place(model, cf, PlayerService.GetBasePartFromData(PlayerInfo[player]) :: Part)
        end
    end)
end

function PlayerService.DestroyData(player)
    PlayerInfo[player] = nil
end

return PlayerService