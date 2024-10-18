local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolState = require(ReplicatedStorage.Data.StatesData.ToolStates)
local ObjectStates = require(ReplicatedStorage.Data.StatesData.ObjectStates)

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

export type Object = {
    name: string,
    currentLevel: number,
    maxLevel: number,
    state: ObjectStates.ObjectState,
    cost: number,
    cycleTime: number,
    timeRemaining: number,
    assetName: string,
    model: Model?,
    prompt: ProximityPrompt?
}

return {}