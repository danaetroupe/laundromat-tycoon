local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementEvents = ReplicatedStorage.Events.MovementEvents

local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = "rbxassetid://507777826"

local MovementService = {}

function MovementService.Move(character : Model, destination : Vector3, parameters : {}?)
    local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid.Animator or humanoid:WaitForChild("Animator")
	local humRootPart : Part = character:FindFirstChild("HumanoidRootPart") :: Part

	-- Load animation
	local track : AnimationTrack = animator:LoadAnimation(walkAnim)
 
	-- Set pathfinding variables
	parameters = parameters or {} -- {AgentCanJump = false}
    local path : Path = PathfindingService:CreatePath(parameters)
    local blockedConnection
    local reachedConnection
    local nextWaypointIndex

    local success, errorMessage = pcall(function()
		path:ComputeAsync(humRootPart.Position, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		local waypoints = path:GetWaypoints()

		-- Detect if path becomes blocked
		blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
			-- Check if the obstacle is further down the path
			if blockedWaypointIndex >= nextWaypointIndex then
				-- Stop detecting path blockage until path is re-computed
				blockedConnection:Disconnect()
				-- Call function to re-compute new path
				MovementService.Move(character, destination)
			end
		end)

		-- Detect when movement to next waypoint is complete
		if not reachedConnection then
			reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
				if reached and nextWaypointIndex < #waypoints then
					-- Increase waypoint index and move to next waypoint
					nextWaypointIndex += 1
					humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
				else
					reachedConnection:Disconnect()
					blockedConnection:Disconnect()
					track:Stop()
					MovementEvents.MovementComplete:Fire(character)
				end
			end)
		end

		-- Initially move to second waypoint (first waypoint is path start; skip it)
		nextWaypointIndex = 2
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
		track:Play()
	else
		warn("Path not computed!", errorMessage)
	end

	return reachedConnection
end

return MovementService