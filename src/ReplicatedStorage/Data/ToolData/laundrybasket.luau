local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolStates = require(ReplicatedStorage.Data.StatesData.ToolStates)
local Types = require(ReplicatedStorage.Data.Types)
type ToolInfo = Types.ToolInfo

local laundrybasket : ToolInfo = {
    name = "Laundry Basket",
    assetName = "laundrybasket",
    npc = nil,
    state = ToolStates.defaultState
}

return laundrybasket
