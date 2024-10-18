local ReplicatedStorage = game:GetService("ReplicatedStorage")
--!strict
local Types = require(ReplicatedStorage.Data.Types)

local playerInfo : Types.PlayerData = {
	money = 0,
	player = nil,
	tycoon = nil,
	baseObjects = {},
	active = true,
	key = nil
}

return playerInfo