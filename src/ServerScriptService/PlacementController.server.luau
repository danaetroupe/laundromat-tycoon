-- CODE MOVED TO PLAYERCONTROLLER.LUAU 

--[[ !! FOR TESTING PURPOSES ONLY
local CollectionService = game:GetService("CollectionService")
local Washers = CollectionService:GetTagged("Washer")
local WasherData = require(ReplicatedStorage.Data.ObjectData.washer)

Players.PlayerAdded:Connect(function(plr)
    Placements[plr] = {}

    for _, washer in Washers do
        local data = table.clone(WasherData)
        data["model"] = washer
        table.insert(Placements[plr], data)
    end
end)]]