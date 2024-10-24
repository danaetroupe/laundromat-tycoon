local ObjectData = require(script.Parent.Parent)

type Object = ObjectData.Object
type ObjectState = ObjectData.ObjectState

local chair : Object = {
    name = "Shelf",
    currentLevel = 1,
    maxLevel = 3,
    cost = 100,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "shelvingunit",
    model = nil,
    prompt = nil
}

return chair