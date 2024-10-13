local RunService = game:GetService("RunService")

local ReplicateOnServer = script.Events.ReplicateOnServer

local isServer =  RunService:IsServer()
local ModelService = {}

function ModelService.CreateOnServer(object : Model, targetFolder : Folder)
    if isServer then
        local newObj = object:Clone()
        newObj.Parent = targetFolder
        return newObj
    else
        return ReplicateOnServer:InvokeServer(object, targetFolder)
    end  
end

if isServer then
    -- Handle client/server boundary
    ReplicateOnServer.OnServerInvoke = function(player, object, targetFolder)
        return ModelService.CreateOnServer(object, targetFolder)
    end
end


return ModelService