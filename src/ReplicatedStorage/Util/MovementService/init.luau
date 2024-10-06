local PathfindingService = game:GetService("PathfindingService")

local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = "rbxassetid://507777826"

local MovementService = {}

function MovementService.Move(character : Model, destination : Vector3, parameters : table)
    local humanoid = character.Humanoid or character:WaitForChild("Humanoid")
	local animator = humanoid.Animator or humanoid:WaitForChild("Animator")

	-- Load animation
	local track : AnimationTrack = animator:LoadAnimation(walkAnim)
 
	-- Set pathfinding variables
	parameters = parameters or {}
    local path : Path = PathfindingService:CreatePath(parameters)
    local blockedConnection
    local reachedConnection
    local nextWaypointIndex

    local success, errorMessage = pcall(function()
		path:ComputeAsync(character.PrimaryPart.Position, destination)
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
				PathfindingService.Move(character, destination)
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
				end
			end)
		end

		-- Initially move to second waypoint (first waypoint is path start; skip it)
		nextWaypointIndex = 2
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
		track:Play()
	else
		warn("Path not computed!", errorMessage)
		return false
	end

	return true
end

return MovementService