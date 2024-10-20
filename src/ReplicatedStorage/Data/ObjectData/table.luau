local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjectStates = require(ReplicatedStorage.Data.StatesData.ObjectStates)
local Types = require(ReplicatedStorage.Data.Types)

type Object = Types.Object

local table : Object = {
    name = "Folding Table",
    currentLevel = 1,
    maxLevel = 3,
    state = ObjectStates.defaultState,
    cost = 100,
    cycleTime = 15,
    timeRemaining = 0,
    assetName = "table",
    model = nil,
    prompt = nil
}

return table