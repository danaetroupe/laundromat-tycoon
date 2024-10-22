local ObjectData = require(script.Parent.Parent)

type Object = ObjectData.Object

local washer : Object = {
    name = "Vending Machine",
    currentLevel = 1,
    maxLevel = 3,
    cost = 100,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "vending",
    model = nil,
}

return washer