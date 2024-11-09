local ObjectData = require(script.Parent.Parent)

type InteractableObject = ObjectData.InteractableObject

local washer : InteractableObject = {
    name = "Washing Machine",
    currentLevel = 1,
    maxLevel = 3,
    state = "Empty",
    cost = 0,
    cycleTime = 15,
    timeRemaining = 0,
    assetName = "washingmachine_closed",
    model = nil,
    prompt = nil,
    expectedLaundryState = "Dirty",
    nextState = "Clean",
}

return washer