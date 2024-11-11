-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Modules
local MovementService = require(ReplicatedStorage.Util.MovementService)
local ToolService = require(ReplicatedStorage.Services.ToolService)
local PlayerService = require(ReplicatedStorage.Services.PlayerService)
local ModelService = require(ReplicatedStorage.Util.ModelService)

-- Data
local NPCData = require(ReplicatedStorage.Data.NPCData)
local OutfitData = require(ReplicatedStorage.Data.OutfitData)

-- Events
local MovementEvents = ReplicatedStorage.Events.MovementEvents
local NPCEvents = ReplicatedStorage.Events.NPCEvents

-- Types
type NPC = NPCData.NPC
type NPCState = NPCData.NPC

-- Events
local isServer = RunService:IsServer()
local EmployeeService = {}
local _Data = {}

-- Takes tycoon active state and spawns NPCs
function EmployeeService.Init(player : Player, active : boolean)
	if not _Data[player] then
		_Data[player] = {}

        Players.PlayerRemoving:Connect(function(plr)
            if player == plr then
				print('wtf!')
                _Data[player] = nil
            end
        end)
	end

	_Data[player]["active"] = active
	if active then -- if any npcs even currently exist destroy all of them
		_Data[player]["step"] = 0 -- if active reset all values
		_Data[player]["dropoff"] = {} -- set queue to empty
		_Data[player]["pickup"] = {} -- set queue to empty
		_Data[player]["tycoon"] = PlayerService.GetTycoon(player)
		_Data[player]["purgatory"] = {}
	else
		EmployeeService.DestroyAll(_Data["pickup"])
		EmployeeService.DestroyAll(_Data["dropoff"])
		EmployeeService.DestroyAll(_Data["purgatory"])
	end

	while _Data[player]["active"] do -- increase step by 1 while player is active
		if _Data[player]["step"] % PlayerService.GetSpawnRate(player) == 0 then
			EmployeeService.SpawnNPC(player, "dropoff")
		end
		_Data[player]["step"] += 1
		task.wait(1)
	end
end

-- Spawn NPC and add to queue
function EmployeeService.SpawnNPC(player : Player, line : string, npc : NPC)
    local endPart : Part = _Data[player]["tycoon"][line]
	npc = EmployeeService.SpawnNewCharacter(player, _Data[player]["tycoon"].Entry.CFrame, npc)
	if line == "pickup" then -- If npc picking up, change to pickup status
		npc.state = "pickup"
	else
		local leave = coroutine.create(function()
			task.wait(60)
			-- NPC got tired of waiting and walked out
			if npc.state == "dropoff" then
				npc.state = "leaving"
				EmployeeService.WalkOut(npc, true)
				EmployeeService.UpdateLine(player, "dropoff")
			end
		end)
		coroutine.resume(leave)
	end
	-- Add to appropriate queue
	table.insert(_Data[player][line], npc)

	-- Walk to line position
    local pos = endPart.Position + Vector3.new(1, 0, 0) * 2 * (#_Data[player][line]-1)
	EmployeeService.WalkCharacter(npc, pos, endPart.Rotation)
	if #_Data[player][line] == 1 then
		EmployeeService.GivePrompt(npc)
	end
end

-- Spawns character in world and creates if necessary
function EmployeeService.SpawnNewCharacter(player : Player, point : CFrameValue, data : NPC) : NPC
	data = data or table.clone(NPCData)
	if not data.character then
		data.character = ModelService.GetModelFromStorage("NPC", "NPC")
		local humanoid = data.character.Humanoid or data.character:WaitForChild("Humanoid")
		local humDesc = humanoid:GetAppliedDescription()

		humDesc.Face = OutfitData.GetRandomFromCategory("face")
		humDesc.Shirt = OutfitData.GetRandomFromCategory("shirt")
		humDesc.Pants = OutfitData.GetRandomFromCategory("pants")
		humDesc.HairAccessory = OutfitData.GetRandomFromCategory("hair")
		humanoid:ApplyDescription(humDesc)
	end

	data.character.Parent = workspace
	data.character.HumanoidRootPart.CFrame = point -- Set to point
	data.player = player
	data.id = if data.id then data.id else HttpService:GenerateGUID(false)
	return data
end

-- Walks character to point
function EmployeeService.WalkCharacter(data : NPC, point : Vector3, rotation : Vector3)
    local character : Model = data.character
	if not character then
		error("Character not given.")
		return
	end

	MovementService.Move(character, point) -- run movement code

	local connect -- connection signal
	connect = MovementEvents.MovementComplete.Event:Connect(function(char)
		if char == character then
			character.PrimaryPart.Rotation = rotation
			connect:Disconnect()
		end
	end)
end

-- Destroy all NPCs in a table
function EmployeeService.DestroyAll(npcs : {NPC}) : nil
	for _, npc in npcs do
		npc.character:Destroy()
	end
end

--[[  May need to be deleted
function NPCService.FaceForwards(npc : NPC, part : Part)
    local character : Model = npc["character"]
	character:PivotTo(CFrame.lookAt(character.PrimaryPart.CFrame.Position, part.CFrame.LookVector))
end ]]

-- Add to purgatory :( 
function EmployeeService.AddToPurgatory(player : Player, npc : NPC)
	if isServer then
		table.insert(_Data[player]["purgatory"], npc)
	else
		NPCEvents.ExecuteOnServer:FireServer("AddToPurgatory", player, npc)
	end
end
-- Give NPC a proximity prompt
function EmployeeService.GivePrompt(npc : NPC)
	if isServer then
		NPCEvents.ExecuteOnClient:FireClient(npc.player, "GivePrompt", npc)
	else
		-- Execute on client
		local prompt = Instance.new("ProximityPrompt")
		prompt.Parent = npc.character
		prompt.Triggered:Connect(function(player)
			local state = npc.state
			local key = PlayerService.GetKey(player)
			local keyState = if key then ToolService.GetState(key) else nil
			-- Check if npc is dropping off and player does not have key
			if state == "dropoff" and not PlayerService.GetKey(player) then
				local tool = ToolService.GiveNewTool(player, "laundrybasket", npc.id)
				local success = PlayerService.AssignKey(tool)
				if success then
					npc.state = "pickup"
					EmployeeService.WalkOut(npc, false)
					EmployeeService.UpdateLine(player, "dropoff")
					prompt:Destroy()
					EmployeeService.AddToPurgatory(player, npc)
				else
					ToolService.Destroy(tool)
				end
			elseif state == "pickup" and key and keyState == "Folded" then
				PlayerService.AddMoney(player)
				PlayerService.ClearKey()
				ToolService.Destroy(key)
				prompt:Destroy()
				EmployeeService.WalkOut(npc, true)
				EmployeeService.UpdateLine(player, "pickup")
				-- TODO: record satsifaction and whatnot... what events happen when they die
			end
		end)
	end
end

-- Walk NPC out
function EmployeeService.WalkOut(npc : NPC, destroy : boolean)
	if isServer then
		local part : Part = PlayerService.GetStartPoint(npc.player)
		EmployeeService.WalkCharacter(npc, part.Position, part.Rotation)
		task.wait(5)
		if destroy then
			npc.character:Destroy()
		else
			npc.character.Parent = ReplicatedStorage
		end
	else
		NPCEvents.ExecuteOnServer:FireServer("WalkOut", npc, destroy)
	end
end

-- Update queue
function EmployeeService.UpdateLine(player : Player, line : string) -- moves up line if event happens
	if isServer then
		local npc : NPC = table.remove(_Data[player][line], 1)
		npc.state = "dontdespawnpls"
		if #_Data[player][line] >= 1 then -- check if queue is not empty
			EmployeeService.GivePrompt(_Data[player][line][1])
		end
		for i, attendant in _Data[player][line] do -- Move all humanoids up in the queue
			local pos = _Data[player]["tycoon"][line].Position + Vector3.new(1, 0, 0) * 2 * (i - 1)
			EmployeeService.WalkCharacter(attendant, pos, _Data[player]["tycoon"][line].Rotation)
		end
	else
		NPCEvents.ExecuteOnServer:FireServer("UpdateLine", player, line)
	end
end

-- Handles server-client communication
if isServer then
	NPCEvents.ExecuteOnServer.OnServerEvent:Connect(function(_player, func, ...)
		EmployeeService[func](...)
	end)
else
	-- Executes proximity prompt creations via client
	NPCEvents.ExecuteOnClient.OnClientEvent:Connect(function(func : string, ...)
    	EmployeeService[func](...)
	end)
end

-- Spawn based on ID
function EmployeeService.SpawnById(player : Player, id : string)
	local npc
	for i, data : NPC in _Data[player]["purgatory"] do
		if data.id == id then
			npc = data
			table.remove(_Data[player]["purgatory"], i)
			break
		end
	end
	if not npc then 
		error("Trying to spawn but id doesn't exist") 
		return
	end

	EmployeeService.SpawnNPC(player, "pickup", npc)
end

return EmployeeService