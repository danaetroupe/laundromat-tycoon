local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModelService = require(ReplicatedStorage.Util.ModelService)

local ToolData = require(ReplicatedStorage.Data.ToolData)
local ToolStates = require(ReplicatedStorage.Data.StatesData.ToolStates)
local Types = require(ReplicatedStorage.Data.Types)

type Tool = Types.Tool
type NPC = Types.NPC

local ToolService = {}

-- Gives player tool and activates it
function ToolService.GiveTool(player : Player, toolName : string) : table
    local character = player.Character or player.CharacterAdded:Wait()
    local tool = table.clone(ToolData.Get(toolName))
    tool.model = ModelService.GetModelFromStorage(tool.assetName, "Tools")
    tool.model.Parent = character
    return tool
end

function ToolService.Destroy(toolData : Tool) : nil
    toolData.model:Destroy()
    table.clear(toolData)
end

-- Associates an npc with the tool
function ToolService.AssignNPC(data : Tool, npc : NPC) : nil -- !!should npc be passed in as the model? 
    data["npc"] = npc
end

-- Get tool state
function ToolService.GetState(tool : Tool) : ToolStates.tool
    return tool["state"]
end

return ToolService