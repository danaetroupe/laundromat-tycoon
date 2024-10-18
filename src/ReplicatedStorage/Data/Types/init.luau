local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolState = require(ReplicatedStorage.Data.StatesData.ToolStates)

export type NPC = {
	name: string?,
	happiness: number,
	rarity : "common" | "premium",
	character : Model?,
	player : Player?
}

export type Tool = {
    name: string?,
    assetName: string?,
    model: Model?, 
    state: ToolState.ToolState,
    npc : NPC?
}

return {}