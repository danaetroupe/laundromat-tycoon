local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModelService = require(ReplicatedStorage.Util.ModelService)
local NPCEvents = ReplicatedStorage.Events.NPCEvents

local ToolData = require(ReplicatedStorage.Data.ToolData)
local Tools = require(ReplicatedStorage.Data.ToolData.Tools)
local NPCData = require(ReplicatedStorage.Data.NPCData)

type ToolInfo = ToolData.ToolInfo
type NPCState = NPCData.NPCState
type ToolState = ToolData.ToolState
type NPC = NPCData.NPC

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
    tool.model:Destroy()
end

function ToolService.GetNPC(tool : ToolInfo) : NPC
    return tool.npc
end

return ToolService