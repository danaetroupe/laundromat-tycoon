local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Data.Types)
local NPCStates = require(ReplicatedStorage.Data.StatesData.NPCStates)

local data : Types.NPC = {
	name = nil,
	happiness = 100,
	rarity = "common",
	character = nil,
	status = nil,
	player = nil,
	state = NPCStates.defaultState
}

return data