export type NPCState = "dropoff" | "pickup" | "Waiting"

export type NPC = {
	id: string?,
	name: string?,
	happiness: number,
	rarity : "common" | "premium",
	character : Model?,
	player : Player?,
    state : NPCState
}

export type Employee = NPC&{
	salary : number, -- cost per day,
	upgradeCost: number
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