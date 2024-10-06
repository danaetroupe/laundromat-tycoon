-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local InteractableData = require(ReplicatedStorage.Data.InteractableData)

-- Constants

-- Events
local InteractionService = {}

-- Updates state and creates interaction to reflect state
function InteractionService.UpdateStatus(data : table, status : string)
    data["status"] = status
end

return InteractionService