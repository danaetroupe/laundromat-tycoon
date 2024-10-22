local ToolData = require(script.Parent.Parent)

type ToolInfo = ToolData.ToolInfo
type ToolState = ToolData.ToolState

local laundrybasket : ToolInfo = {
    name = "Laundry Basket",
    assetName = "laundrybasket",
    npc = nil,
    state = "Dirty"
}

return laundrybasket
