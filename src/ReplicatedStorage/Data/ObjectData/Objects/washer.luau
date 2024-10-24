local ObjectData = require(script.Parent.Parent)

type InteractableObject = ObjectData.InteractableObject

local washer : InteractableObject = {
    name = "Washing Machine",
    currentLevel = 1,
    maxLevel = 3,
    state = "Empty",
    cost = 100,
    cycleTime = 30,
    timeRemaining = 0,
    assetName = "washingmachine_closed",
    model = nil,
    prompt = nil,
    expectedLaundryState = "Dirty",
    nextState = "Clean"
}

return washer