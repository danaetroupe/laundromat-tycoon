-- This script returns info about different object data
export type LaundryState = "Dirty" | "Clean" | "Dry" | "Folded"
export type ToolState = LaundryState

export type ToolInfo = {
    name: string?,
    assetName: string?,
    model: Tool?, 
    state: ToolState,
    npcId : string?
}

return {}