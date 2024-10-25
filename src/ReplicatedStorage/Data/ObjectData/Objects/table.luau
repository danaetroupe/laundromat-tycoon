local ObjectData = require(script.Parent.Parent)

type InteractableObject = ObjectData.Object
type MachineState = ObjectData.ObjectState

local table : InteractableObject = {
    name = "Folding Table",
    currentLevel = 1,
    maxLevel = 3,
    state = "Empty",
    cost = 100,
    cycleTime = 5,
    timeRemaining = 0,
    assetName = "foldingtable",
    model = nil,
    prompt = nil,
    expectedLaundryState = "Dry",
    nextState = "Ready"
}

return table