local ObjectData = require(script.Parent.Parent)

type Object = ObjectData.Object
type ObjectState = ObjectData.ObjectState
type Storage = ObjectData.Storage

local shelf : Storage = {
    name = "Shelf",
    currentLevel = 1,
    maxLevel = 3,
    cost = 30,
    cycleTime = 0,
    timeRemaining = 0,
    assetName = "shelvingunit",
    model = nil,
    prompt = nil,
    state = "Empty",
    spotCount = 0,
    spots = {}
}

return shelf