local ObjectData = require(script.Parent.Parent)

type Object = ObjectData.Object

local drinkmachine : Object = {
    name = "Drink Machine",
    currentLevel = 1,
    maxLevel = 3,
    cost = 250,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "vendingmachine_drinks",
    model = nil,
}

return drinkmachine