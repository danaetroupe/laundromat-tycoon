return {
    name = "Dryer",
    currentLevel = 1,
    maxLevel = 3,
    status = "Empty", -- Empty, Cycle In Progress, Complete
    cost = 100,
    profit = 50,
    electricCharge = 10,
    weeklyUses = 0,
    model = nil,
    cycleTime = 30,
    coinCount = 0,
    maxCoinCount = 500,
    timeRemaining = 0,
    states = {
        closed = "dryer"
    }
}