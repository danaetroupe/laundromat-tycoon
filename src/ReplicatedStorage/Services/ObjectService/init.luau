-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ObjectData = require(ReplicatedStorage.Data.ObjectData)

-- Constants

-- Events
local ObjectService = {}

-- Updates state and creates interaction to reflect state
function ObjectService.UpdateStatus(data : table, status : string)
    data["status"] = status
end

function ObjectService.GetModel(data : table) : Model
    return data["model"]
end

return ObjectService