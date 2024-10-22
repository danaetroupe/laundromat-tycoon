local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolData = require(ReplicatedStorage.Data.ToolData)

type ToolInfo = ToolData.ToolInfo

export type PlayerData = {
    money: number,
	player: Player,
	tycoon: Model?,
	baseObjects: table,
	active: boolean,
	key: ToolInfo?
}

local info : PlayerData = {
	money = 0,
	player = nil,
	tycoon = nil,
	baseObjects = {},
	active = true,
	key = nil
}

return info