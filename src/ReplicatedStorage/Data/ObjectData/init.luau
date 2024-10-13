-- This script returns info about different object data

local ObjectData = {}
local _data = {}

local function _init()
	for _, module in script:GetChildren() do
		local tbl = require(module)
		_data[module.Name] = tbl
	end
end

-- Returns module table
function ObjectData.Get(name : string) : any
	return _data[name]
end

-- Returns property of a specific object type
function ObjectData.GetProperty(name: string, property: string) : any
	return _data[name][property]
end

-- Returns property list of a specific object type
function ObjectData.GetProperties(name: string, properties: {string}) : {[string] : any}
	local out = {}
	for _, key in properties do
		out[key] = _data[name][key]
	end
	return out
end

function ObjectData.GetObjectNames()
	local names = {}
	for _, module in script:GetChildren() do
		table.insert(names, module.Name)
	end
	return names
end

_init()
return ObjectData
