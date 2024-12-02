-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Events
local PlacementEvents = ReplicatedStorage.Events.PlacementEvents

-- Constants
local isServer = RunService:IsServer()
local GRID_UNIT = 1

local PlacementService = {}

function PlacementService.Init(basePart: Part)
	local objectsFolder = Instance.new("Folder")
	objectsFolder.Name = "BaseObjects"
	objectsFolder.Parent = basePart
	return objectsFolder
end

-- Place Object In World
function PlacementService.Place(model: Model, cf: CFrame, basePart: Part): ()
	if isServer then
		model.Parent = basePart:FindFirstChild("BaseObjects")
		model:PivotTo(cf)
	else
		PlacementEvents.Place:Fire(model)
		PlacementEvents.InvokePlacement:FireServer(model, cf)
	end
end

-- Calculate placement surface
function PlacementService._CalcSurface(data: {}, surface: Enum.NormalId): Enum.NormalId
	local surfaceType = data["surface"]
	if surfaceType then
		if surface == Enum.NormalId.Top then
			return Enum.NormalId.Top
		elseif
			table.find(
				{ Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Back },
				surfaceType
			)
		then
			return surface
		else
			return Enum.NormalId.Left
		end
	else
		return Enum.NormalId.Top
	end
end

-- Calculates base size in world space for placement
function PlacementService._CalcBase(base: Part | BasePart, surface: Enum.NormalId?)
	local canvasSize = base.Size
	surface = surface or Enum.NormalId.Top

	local up = Vector3.new(0, 1, 0)
	local back = -Vector3.FromNormalId(surface :: Enum.NormalId)

	-- if we are using the top or bottom then we treat right as up
	local dot = back:Dot(Vector3.new(0, 1, 0))
	local axis = (math.abs(dot) == 1) and Vector3.new(-dot, 0, 0) or up

	-- rotate around the axis by 90 degrees to get right vector
	local right = CFrame.fromAxisAngle(axis, math.pi / 2) * back
	-- use the cross product to find the final vector
	local top = back:Cross(right).unit

	-- convert to world space
	local cf = base.CFrame * CFrame.fromMatrix(-back * canvasSize / 2, right, top, back)
	-- use object space vectors to find the width and height
	local size = Vector2.new((canvasSize * right).magnitude, (canvasSize * top).magnitude)

	return cf, size
end

-- Calculates the CFrame of the Object
function PlacementService.CalcPlacementCFrame(
	base: Part | BasePart,
	model: Model,
	position: Vector3,
	rotation: number
): CFrameValue?
	if not model.PrimaryPart then 
		warn(model.Name.. " does not contain a primary part.")
		return 
	end
	-- use other method to get info about the surface
	local cf, size = PlacementService._CalcBase(base)

	-- rotate the size so that we can properly constrain to the surface
	local modelSize = CFrame.fromEulerAnglesYXZ(0, rotation, 0) * model.PrimaryPart.Size
	modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))

	-- get the position relative to the surface's CFrame
	local lpos = cf:pointToObjectSpace(position)
	-- the max bounds the model can be from the surface's center
	local size2 = (size - Vector2.new(modelSize.x, modelSize.z)) / 2

	-- constrain the position using size2
	local x = math.clamp(lpos.x, -size2.x, size2.x)
	local y = math.clamp(lpos.y, -size2.y, size2.y)
	local g = GRID_UNIT

	if g > 0 then
		x = math.sign(x) * ((math.abs(x) - math.abs(x) % g) + (size2.x % g))
		y = math.sign(y) * ((math.abs(y) - math.abs(y) % g) + (size2.y % g))
	end

	-- create and return the CFrame
	return cf * CFrame.new(x, y, -modelSize.y / 2) * CFrame.Angles(-math.pi / 2, rotation, 0)
end
-- !! still need to implement way to pass in surface mouse is pointing at

function PlacementService.IsColliding(model: Model): boolean
	if not model.PrimaryPart then 
		warn(model.Name.. " does not contain a primary part.")
		return true
	end
	local touching = workspace:GetPartsInPart(model.PrimaryPart)
	-- if intersecting with something that isn't part of the model then can't place
	for _, part in touching do
		if not part:IsDescendantOf(model) and part.CanCollide then
			return true
		end
	end
	return false
end

return PlacementService
