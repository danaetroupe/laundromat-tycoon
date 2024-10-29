local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolData = require(ReplicatedStorage.Data.ToolData)

type ToolInfo = ToolData.ToolInfo

export type PlayerData = {
    money: number,
	player: Player,
	tycoon: Model?,
	baseObjects: table,
	active: boolean,
	key: ToolInfo?,
	spawn_rate : number,
	profit: number,
	isBuilding : boolean
}

local info : PlayerData = {
	money = 250,
	player = nil,
	tycoon = nil,
	baseObjects = {},
	active = true,
	key = nil,
	spawn_rate = 30,
	profit = 10,
	isBuilding = false
}

return info