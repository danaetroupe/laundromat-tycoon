local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjectStates = require(ReplicatedStorage.Data.StatesData.ObjectStates)
local Types = require(ReplicatedStorage.Data.Types)

type Object = Types.Object

local dryer : Object = {
    name = "Dryer",
    currentLevel = 1,
    maxLevel = 3,
    state = ObjectStates.defaultState,
    cost = 100,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "dryer",
    model = nil,
    prompt = nil
}

return dryer