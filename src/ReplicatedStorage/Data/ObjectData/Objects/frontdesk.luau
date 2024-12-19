local ObjectData = require(script.Parent.Parent)

type Object = ObjectData.Object
type ObjectState = ObjectData.ObjectState
type Storage = ObjectData.Storage

local desk : Storage = {
    name = "Desk",
    currentLevel = 1,
    maxLevel = 3,
    cost = 0,
    cycleTime = 0,
    timeRemaining = 0,
    assetName = "frontdesk",
    model = nil,
    prompt = nil,
    state = "Empty",
    spotCount = 0,
    spots = {}
}

return desk