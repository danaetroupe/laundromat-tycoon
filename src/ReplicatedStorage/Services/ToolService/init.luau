local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModelService = require(ReplicatedStorage.Util.ModelService)

local ToolData = require(ReplicatedStorage.Data.ToolData)
local ToolStates = require(ReplicatedStorage.Data.StatesData.tool)

local ToolService = {}

-- Gives player tool and activates it
function ToolService.GiveTool(player : Player, toolName : string) : table
    local character = player.Character or player.CharacterAdded:Wait()
    local tool = table.clone(ToolData.Get(toolName))
    tool.model = ModelService.GetModelFromStorage(tool.model, "Tools")
    tool.model.Parent = character
    return tool
end

function ToolService.Destroy(toolData : table) : nil
    toolData.model:Destroy()
    table.clear(toolData)
end

-- Associates an npc with the tool
function ToolService.AssignNPC(data : table, npc : table) : nil -- !!should npc be passed in as the model? 
    data["npc"] = npc
end

-- Get tool state
function ToolService.GetState(tool : table) 
    return ToolStates
end

return ToolService