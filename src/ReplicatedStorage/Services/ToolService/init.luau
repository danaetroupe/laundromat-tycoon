local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ModelService = require(ReplicatedStorage.Util.ModelService)

local ToolData = require(ReplicatedStorage.Data.ToolData)
local Tools = require(ReplicatedStorage.Data.ToolData.Tools)
local NPCData = require(ReplicatedStorage.Data.NPCData)

local ToolEvents = ReplicatedStorage.Events.ToolEvents
local NPCEvents = ReplicatedStorage.Events.NPCEvents

type ToolInfo = ToolData.ToolInfo
type NPCState = NPCData.NPCState
type ToolState = ToolData.ToolState
type NPC = NPCData.NPC

local isServer = RunService:IsServer()
local LocalPlayer = if not isServer then Players.LocalPlayer else nil
local ToolService = {}

-- Gives player tool and activates it
function ToolService.GiveTool(player : Player, toolName : string, npc : NPC) : table
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character.Humanoid
    local tool : ToolInfo = table.clone(Tools.GetTool(toolName))
    tool.npc = npc
    tool.model = ModelService.GetModelFromStorage(tool.assetName, "Tools")
    humanoid:EquipTool(tool.model)
    return tool
end

-- Client script to equip tool
function ToolService.EquipExistingTool(player : Player, tool : ToolInfo)
    if isServer then
        local character = player.Character or player.CharacterAdded:Wait()
        character.Humanoid:EquipTool(tool.model)
    else
        if not tool.model then
            tool.model = ModelService.GetModelFromStorage(tool.assetName, "Tools")
        end
        ToolEvents.ExecuteOnServer:InvokeServer("EquipExistingTool", LocalPlayer, tool)
    end
end

function ToolService.Destroy(toolData : ToolInfo) : nil
    toolData.model:Destroy()
    table.clear(toolData)
end

-- Associates an npc with the tool
function ToolService.AssignNPC(data : ToolInfo, npc : NPC) : nil -- !!should npc be passed in as the model? 
    data["npc"] = npc
end

-- Get tool state
function ToolService.GetState(tool : ToolInfo) : ToolState
    return tool["state"]
end

-- Change tool state
function ToolService.ChangeState(tool : ToolInfo, state : ToolState)
    tool["state"] = state
    if state == "Ready" then
        NPCEvents.SpawnNPC:FireServer("pickup", tool.npc)
    end
end

function ToolService.DestroyModel(tool : ToolInfo)
    if isServer then
        tool.model:Destroy()
    else
        ToolEvents.ExecuteOnServer:InvokeServer("DestroyModel", tool)
    end
end

function ToolService.GetNPC(tool : ToolInfo) : NPC
    return tool.npc
end

function ToolService._ReEnableTool(tool : ToolInfo)
    if isServer then
        tool.model.NotHandle.Name = "Handle"
        tool.model.PrimaryPart.Anchored = false
    else
        ToolEvents.ExecuteOnServer:InvokeServer("_ReEnableTool", tool)
    end
end

-- Allows server side communication
if isServer then
    ToolEvents.ExecuteOnServer.OnServerInvoke = function(player, func, ...)
        return ToolService[func](...)
    end
end



return ToolService