local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicateOnServer = script.Events.ReplicateOnServer

local isServer =  RunService:IsServer()
local ModelService = {}

function ModelService.CreateOnServer(object : Model)
    if isServer then
        local newObj = object:Clone()
        return newObj
    else
        return ReplicateOnServer:InvokeServer(object)
    end  
end

if isServer then
    -- Handle client/server boundary
    ReplicateOnServer.OnServerInvoke = function(_player, object, targetFolder)
        return ModelService.CreateOnServer(object)
    end
end

function ModelService.GetModelFromStorage(name : string, path : string) : Model
    local model = nil
    if path then
        model = ReplicatedStorage.Assets[path]:FindFirstChild(name, true)
    else
        model = ReplicatedStorage.Assets:FindFirstChild(name, true)
    end

    if not model then
        error("Model could not be found")
    end

    return ModelService.CreateOnServer(model)
end

return ModelService