local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- This script returns info about different object data
export type LaundryState = "Dirty" | "Clean" | "Dry" | "Ready"
export type ToolState = LaundryState

local NPCData = require(ReplicatedStorage.Data.NPCData)
type NPC = NPCData.NPC

export type ToolInfo = {
    name: string?,
    assetName: string?,
    model: Tool?, 
    state: ToolState,
    npc : NPC?
}

return {}