local Tools = {}
local _data = {}

local function _init()
	for _, module in script:GetChildren() do
		local tbl = require(module)
		_data[module.Name] = tbl
	end
end

-- Returns module table
function Tools.GetTool(name : string) : any
	return _data[name]
end

_init()
return Tools