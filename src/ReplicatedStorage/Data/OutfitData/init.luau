local OutfitData = {}
local _data = {}

local function _init()
	for _, module in script:GetChildren() do
		local tbl = require(module)
		_data[module.Name] = tbl
        -- if module.category then            -- Allows index by category
        --     if _data[module.category] then 
        --         table.insert(_data[module.category], tbl)
        --     else
        --         _data[module.category] = {tbl}
        --     end 
        -- end
	end
end

-- Returns module table
function OutfitData.Get(name : string) : any
	return _data[name]
end

-- Returns property of a specific NPC type
function OutfitData.GetProperty(name: string, property: string) : any
	return _data[name][property]
end

-- Returns property list of a specific NPC type
function OutfitData.GetProperties(name: string, properties: {string}) : {[string] : any}
	local out = {}
	for _, key in properties do
		out[key] = _data[name][key]
	end
	return out
end

-- -- Returns all tables in specified category
-- function OutfitData.GetCateogry(category : string)
--     return _data[category]
-- end

-- Returns a random id from category
function OutfitData.GetRandomFromCategory(category : string) : string
    local tbl = _data[category]
    local num = math.random(#tbl)
    return tbl[num]
end

_init()
return OutfitData
