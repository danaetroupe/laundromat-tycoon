local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjectStates = require(ReplicatedStorage.Data.StatesData.ObjectStates)
local Types = require(ReplicatedStorage.Data.Types)

type Object = Types.Object

local washer : Object = {
    name = "Vending Machine",
    currentLevel = 1,
    maxLevel = 3,
    state = ObjectStates.defaultState,
    cost = 100,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "vending",
    model = nil,
    prompt = nil
}

return washer