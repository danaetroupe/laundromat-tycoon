local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
    name = "Washing Machine",
    currentLevel = 1,
    maxLevel = 3,
    status = "Empty", -- Empty, Cycle In Progress, Complete
    cost = 100,
    profit = 50,
    waterCharge = 25,
    electricCharge = 10,
    weeklyUses = 0,
    cycleTime = 30,
    coinCount = 0,
    maxCoinCount = 500, 
    timeRemaining = 0,
    model = "washingmachine"
}