local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolData = require(ReplicatedStorage.Data.ToolData)

type ToolInfo = ToolData.ToolInfo

export type PlayerData = {
    money: number,
	player: Player,
	tycoon: Model?,
	baseObjects: {},
	active: boolean,
	key: ToolInfo?,
	spawn_rate : number,
	profit: number,
	isBuilding : boolean,
	temp : Folder?
}

local info : PlayerData = {
	money = 250,
	player = nil,
	tycoon = nil,
	baseObjects = {},
	active = false,
	key = nil,
	spawn_rate = 30,
	profit = 10,
	isBuilding = false
}

return info