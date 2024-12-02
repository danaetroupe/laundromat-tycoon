--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules

-- Data
local ObjectData = require(ReplicatedStorage.Data.ObjectData)

-- Events

-- Types
type ObjectCategory = ObjectData.ObjectCategory

-- Constants
local MAX_STARS = 5

-- Space Values
local MAX_OBJECTS = {50, 75, 100}
local AMENITIES_TO_STAR = 1
local DECORATIONS_TO_STAR = 5
local OBJECTS_TO_STAR = 10

-- Speed
local MAX_RATINGS = 10
local MAX_SPEED = 30
local TIME_TO_STARS = 15

-- Cleanliness Values
local DIRT_TO_STARS = 3

local RatingService = {}
local _Data = {}

function RatingService._RecalculateTotal(player : Player) : ()
    local data = _Data[player]
    data.total = (data.space + data.speed + data.amenities + data.cleanliness + data.decorations) / 5
    print(player.Name.. ": ".. data.total.."/5 stars")
end

function RatingService.InitPlayer(player : Player)
    _Data[player] = {
        space = 3,
        speed = 5,
        amenities = 0,
        cleanliness = 5,
        decorations = 0,
        -- metrics to calculate ratings
        speed_ratings = {}, -- speed
        object_count = 0, -- space
        store_level = 1, -- space
        amenities_count = 0, -- amenities
        dirt_count = 0, -- cleanliness
        decoration_count = 0 -- decorations
    }
    RatingService._RecalculateTotal(player)
end

-- Initalize starting values when player is added
Players.PlayerAdded:Connect(RatingService.InitPlayer)

function RatingService.AddObject(player : Player, category : ObjectCategory)
    local data = _Data[player]
    data.object_count += 1
    local maxStars = MAX_STARS - (3 - data.store_level)
    if category == "Amenity" then
        data.amenities_count += 1
        data.amenities = math.clamp(data.amenities_count / AMENITIES_TO_STAR, 0, maxStars)
    elseif category == "Decoration" then
        data.decoration_count += 1
        data.decorations = math.clamp(data.decoration_count / DECORATIONS_TO_STAR, 0, maxStars)
    end
    local maxObjects = MAX_OBJECTS[data.store_level]
    data.space = if data.object_count < maxObjects then MAX_STARS else 
        math.clamp(MAX_STARS - (data.object_count - maxObjects) / OBJECTS_TO_STAR, 0, maxStars)
    RatingService._RecalculateTotal(player)
end

function RatingService.UpdateDirt(player : Player, increment : number)
    local data = _Data[player]
    data.dirt_count += increment
    data.cleanliness = math.clamp(MAX_STARS - data.dirt_count/DIRT_TO_STARS, 0, MAX_STARS)
    RatingService._RecalculateTotal(player)
end

function RatingService.AddTime(player : Player, time : number)
    local data = _Data[player]
    table.insert(data.speed_ratings, time)
    if #data.speed_ratings > MAX_RATINGS then
        table.remove(data.speed_ratings, 1)
    end
    local sum = 0
    for _, num in data.speed_ratings do
        sum += num
    end
    local average = sum / #data.speed_ratings
    data.speed = if average <= MAX_SPEED then MAX_STARS else
        math.clamp(MAX_SPEED - average / TIME_TO_STARS, 0, MAX_STARS)
    print("speed: ".. data.speed)
    RatingService._RecalculateTotal(player)
end

return RatingService