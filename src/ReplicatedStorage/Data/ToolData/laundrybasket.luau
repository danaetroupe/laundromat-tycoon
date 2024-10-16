local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatesData = require(ReplicatedStorage.Data.StatesData)

return
{
    name = "Laundry Basket",
    model = "laundrybasket",
    npc = nil,
    state = StatesData.GetProperty("laundry", "defaultState")
}