local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolData = require(ReplicatedStorage.Data.ToolData)
type ToolInfo = ToolData.ToolInfo

export type NPCState = "dropoff" | "pickup" | "leaving"

export type NPC = {
	id: string?,
	name: string?,
	happiness: number,
	rarity : "common" | "premium",
	character : Model?,
	player : Player?,
    state : NPCState,
	spawntime: number?
}

export type Employee = NPC&{
	salary : number, -- cost per day,
	upgradeCost: number,
	key : ToolInfo
}

local data : NPC = {
	name = nil,
	happiness = 100,
	rarity = "common",
	character = nil,
	status = nil,
	player = nil,
	state = "dropoff"
}

return data