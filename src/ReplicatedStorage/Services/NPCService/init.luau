-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local NPCData = require(ReplicatedStorage.Data.NPCData)
local NPCService = {}

function NPCService.Init()
    local data = NPCData.Get("regular")
    if data then
        for _, val in data do
            print(val)
        end
    end
end

return NPCService