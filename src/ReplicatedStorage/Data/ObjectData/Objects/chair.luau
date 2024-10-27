local ObjectData = require(script.Parent.Parent)

type Object = ObjectData.Object
type ObjectState = ObjectData.ObjectState

local chair : Object = {
    name = "Chair",
    currentLevel = 1,
    maxLevel = 3,
    cost = 30,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "chair",
    model = nil,
    prompt = nil
}

return chair