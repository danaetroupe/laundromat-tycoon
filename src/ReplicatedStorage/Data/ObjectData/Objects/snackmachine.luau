local ObjectData = require(script.Parent.Parent)

type Object = ObjectData.Object

local washer : Object = {
    name = "Snack Machine",
    currentLevel = 1,
    maxLevel = 3,
    cost = 100,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "vendingmachine_snacks",
    model = nil,
}

return washer