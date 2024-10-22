local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolState = require(ReplicatedStorage.Data.StatesData.ToolStates)
local NPCStates = require(ReplicatedStorage.Data.StatesData.NPCStates)
local ObjectStates = require(ReplicatedStorage.Data.StatesData.ObjectStates)

export type NPC = {
	name: string?,
	happiness: number,
	rarity : "common" | "premium",
	character : Model?,
	player : Player?,
    state : NPCStates.NPCState
}

export type ToolInfo = {
    name: string?,
    assetName: string?,
    model: Tool?, 
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

export type Tycoon = {
    money: number,
	player: Player,
	tycoon: Model?,
	baseObjects: table,
	active: boolean,
	key: ToolInfo?
}

return {}