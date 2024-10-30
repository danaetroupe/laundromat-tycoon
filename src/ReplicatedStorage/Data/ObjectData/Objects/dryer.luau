local ObjectData = require(script.Parent.Parent)

type InteractableObject = ObjectData.Object
type MachineState = ObjectData.ObjectState

local dryer : InteractableObject = {
    name = "Dryer",
    currentLevel = 1,
    maxLevel = 3,
    state = "Empty",
    cost = 0,
    cycleTime = 15,
    timeRemaining = 0,
    assetName = "dryermachine_closed",
    model = nil,
    prompt = nil,
    expectedLaundryState = "Clean",
    nextState = "Dry"
}

return dryer