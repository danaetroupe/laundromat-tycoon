local Controllers = {}
local _Data = {}

function Init()
    for _, service in script:GetChildren() do
        if service:IsA("ModuleScript") then
            _Data[service.Name] = require(service)
        end
    end
end

function Controllers.GetController(serviceName : string)
    return _Data[serviceName]
end

Init()

return Controllers