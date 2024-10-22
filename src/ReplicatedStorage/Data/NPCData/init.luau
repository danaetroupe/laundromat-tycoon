export type NPCState = "DropOff" | "PickUp"

export type NPC = {
	name: string?,
	happiness: number,
	rarity : "common" | "premium",
	character : Model?,
	player : Player?,
    state : NPCState
}

local data : NPC = {
	name = nil,
	happiness = 100,
	rarity = "common",
	character = nil,
	status = nil,
	player = nil,
	state = "DropOff"
}

return data