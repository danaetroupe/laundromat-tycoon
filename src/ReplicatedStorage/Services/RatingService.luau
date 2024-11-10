--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules

-- Data
local ObjectData = require(ReplicatedStorage.Data.ObjectData)

-- Events
local PlayerEvents = ReplicatedStorage.Events.PlayerEvents

-- Types
type ObjectCategory = ObjectData.ObjectCategory

-- Constants
local MAX_STARS = 5

-- Space Values
local MAX_OBJECTS = {50, 75, 100}
local AMENITIES_TO_STAR = 1
local DECORATIONS_TO_STAR = 5
local OBJECTS_TO_STAR = 10

local RatingService = {}
local _Data = {}

-- Initalize starting values when player is added
Players.PlayerAdded:Connect(RatingService.InitPlayer)

function RatingService.InitPlayer(player : Player)
    _Data[player] = {
        space = 5,
        speed = 0,
        amenities = 0,
        cleanliness = 5,
        decorations = 0,
        total = 2,
        -- metrics to calculate ratings
        speed_ratings = {}, -- speed
        object_count = 0, -- space
        store_level = 1, -- space
        amenities_count = 0, -- amenities
        dirt_count = 0, -- cleanliness
        decoration_count = 0 -- decorations
    }
end

function RatingService._RecalculateTotal(player : Player)
    local data = _Data[player]
    data.total = (data.space + data.speed + data.amenities + data.cleanliness + data.decorations) / 5
end


function RatingService.AddObject(player : Player, category : ObjectCategory)
    local data = _Data[player]
    data.object_count += 1
    if category == "Amenity" then
        data.amenities_count += 1
        data.amenities = math.clamp(data.amenities_count / AMENITIES_TO_STAR, 0, MAX_STARS)
    elseif category == "Decoration" then
        data.decoration_count += 1
        data.decorations = math.clamp(data.decoration_count / DECORATIONS_TO_STAR, 0, MAX_STARS)
    end
    local maxObjects = MAX_OBJECTS[data.store_level]
    data.space = if data.object_count < maxObjects then MAX_STARS else 
        math.clamp(MAX_STARS - (data.object_count - maxObjects) / OBJECTS_TO_STAR, 0, MAX_STARS)
    RatingService._RecalculateTotal(player)
end


return RatingService