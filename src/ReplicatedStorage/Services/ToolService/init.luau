local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModelService = require(ReplicatedStorage.Util.ModelService)
local NPCService = require(ReplicatedStorage.Services.NPCService)

local ToolData = require(ReplicatedStorage.Data.ToolData)
local ToolStates = require(ReplicatedStorage.Data.StatesData.ToolStates)
local Types = require(ReplicatedStorage.Data.Types)

type ToolInfo = Types.ToolInfo
type NPC = Types.NPC

local LocalPlayer = Players.LocalPlayer
local ToolService = {}

-- Gives player tool and activates it
function ToolService.GiveTool(player : Player, toolName : string) : table
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character.Humanoid
    local tool = table.clone(ToolData.Get(toolName))
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
function ToolService.GetState(tool : ToolInfo) : ToolStates.ToolState
    return tool["state"]
end

-- Change tool state
function ToolService.ChangeState(tool : ToolInfo, state : ToolStates.ToolState)
    tool["state"] = state
    if state == "Ready" then
        NPCService.AddToQueue(tool.npc)
    end
end

function ToolService.DestroyModel(tool : ToolInfo)
    tool.model:Destroy()
end

return ToolService