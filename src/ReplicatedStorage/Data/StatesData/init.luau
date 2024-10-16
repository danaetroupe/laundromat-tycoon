-- This script returns info about different object data

local StatesData = {}
local _data = {}

local function _init()
	for _, module in script:GetChildren() do
		local tbl = require(module)
		_data[module.Name] = tbl
	end
end

-- Returns module table
function StatesData.Get(name : string) : any
	return _data[name]
end

-- Returns property of a specific object type
function StatesData.GetProperty(name: string, property: string) : any
	return _data[name][property]
end

-- Returns property list of a specific object type
function StatesData.GetProperties(name: string, properties: {string}) : {[string] : any}
	local out = {}
	for _, key in properties do
		out[key] = _data[name][key]
	end
	return out
end

_init()
return StatesData
