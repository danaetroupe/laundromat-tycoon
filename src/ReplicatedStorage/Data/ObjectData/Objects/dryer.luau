local ObjectData = require(script.Parent.Parent)

type InteractableObject = ObjectData.Object
type MachineState = ObjectData.ObjectState

local dryer : InteractableObject = {
    name = "Dryer",
    currentLevel = 1,
    maxLevel = 3,
    state = "Empty",
    cost = 100,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "dryer",
    model = nil,
    prompt = nil
}

return dryer