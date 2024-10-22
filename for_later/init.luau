local Services = {}
local _data = {}

local function _init()
	for _, module : ModuleScript in script:GetChildren() do
		local tbl = require(module)
		_data[module.Name] = tbl
	end
end

-- Returns service
function Services.GetService(name : string) : any
	return _data[name]
end

_init()
return Services
