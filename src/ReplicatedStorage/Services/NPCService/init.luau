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
local RatingService = require(ReplicatedStorage.Services.RatingService)

-- Data
local NPCData = require(ReplicatedStorage.Data.NPCData)
local OutfitData = require(ReplicatedStorage.Data.OutfitData)

-- UI
--local Billboard = require(ReplicatedStorage.UI.Billboard)

-- Events
local MovementEvents = ReplicatedStorage.Events.MovementEvents
local NPCEvents = ReplicatedStorage.Events.NPCEvents

-- Types
type NPC = NPCData.NPC
type NPCState = NPCData.NPC

-- Variables
local isServer = RunService:IsServer()
local NPCService = {}
local _Data = {}

-- Takes tycoon active state and spawns NPCs
function NPCService.Init(player : Player, active : boolean)
	if not _Data[player] then
		_Data[player] = {}

        Players.PlayerRemoving:Connect(function(plr)
            if player == plr then
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
		NPCService.DestroyAll(_Data["pickup"])
		NPCService.DestroyAll(_Data["dropoff"])
		NPCService.DestroyAll(_Data["purgatory"])
	end

	while _Data[player]["active"] do -- increase step by 1 while player is active
		if _Data[player]["step"] % PlayerService.GetSpawnRate(player) == 0 then
			NPCService.SpawnNPC(player, "dropoff")
		end
		_Data[player]["step"] += 1
		task.wait(1)
	end
end

-- Spawn NPC and add to queue
function NPCService.SpawnNPC(player : Player, line : string, npc : NPC?)
	if isServer then
		local endPart : Part = _Data[player]["tycoon"][line]
		local npc2 = NPCService.SpawnNewCharacter(player, _Data[player]["tycoon"].Entry.CFrame, npc)
		npc = npc2
		if line == "pickup" then -- If npc picking up, change to pickup status
			npc2.state = "pickup"
			NPCEvents.PickupSpawned:FireClient(player, npc2)
		else
			NPCEvents.DropoffSpawned:FireClient(player, npc2)
			local leave = coroutine.create(function()-- todo: this will cause issues later in the tutorial
				task.wait(60)
				-- NPC got tired of waiting and walked out
				if npc2.state == "dropoff" then
					npc2.state = "leaving"
					NPCService.WalkOut(npc2, true)
					NPCService.UpdateLine(player, "dropoff")
				end
			end)
			coroutine.resume(leave)
		end
		-- Add to appropriate queue
		table.insert(_Data[player][line], npc2)

		-- Walk to line position
		local vector = if npc2.character.PrimaryPart.CFrame.Position.X > endPart.Position.X then 1 else -1
		local pos = endPart.Position + Vector3.new(vector, 0, 0) * 2 * (#_Data[player][line]-1)
		NPCService.WalkCharacter(npc2, pos, endPart.Rotation)
		if #_Data[player][line] == 1 then
			NPCService.GivePrompt(npc2)
		end
	else
		NPCEvents.ExecuteOnServer:InvokeServer("SpawnNPC", player, line, npc)
	end
end

-- Spawns character in world and creates if necessary
function NPCService.SpawnNewCharacter(player : Player, point : CFrameValue, data : NPC?) : NPC
	data = data or table.clone(NPCData)
	if data and not data.character then
		data.character = ModelService.GetModelFromStorage("NPC", "NPC")
		local character = data.character
		local humanoid = character.Humanoid or character:WaitForChild("Humanoid")
		local humDesc = humanoid:GetAppliedDescription()
		data.character = character

		humDesc.Face = OutfitData.GetRandomFromCategory("face")
		humDesc.Shirt = OutfitData.GetRandomFromCategory("shirt")
		humDesc.Pants = OutfitData.GetRandomFromCategory("pants")
		humDesc.HairAccessory = OutfitData.GetRandomFromCategory("hair")
		humanoid:ApplyDescription(humDesc)
	end
	
	assert(data, "Data does not exist.")
	assert(data.character, "Character does not exist")
	assert(data.character:FindFirstChild("HumanoidRootPart"), "Humanoid root part does not exist.")
	data.character.Parent = workspace
	data.character:FindFirstChild("HumanoidRootPart").CFrame = point -- todo: fix this error lol
	data.player = player
	data.id = if data.id then data.id else HttpService:GenerateGUID(false)
	data.spawntime = if not data.spawntime then os.time() else data.spawntime
	return data
end

-- Walks character to point
function NPCService.WalkCharacter(data : NPC, point : Vector3, rotation : Vector3)
    if not data.character then return end
	local character : Model = data.character
	if not character then
		error("Character not given.")
		return
	end

	local connect -- connection signal
	connect = MovementEvents.MovementComplete.Event:Connect(function(char)
		if char == character then
			if not character.PrimaryPart then return end
			character.PrimaryPart.Rotation = rotation
			connect:Disconnect()
		end
	end)

	MovementService.Move(character, point) -- run movement code
end

-- Destroy all NPCs in a table
function NPCService.DestroyAll(npcs : {NPC}) : ()
	if not npcs then return end
	for _, npc in npcs do
		npc.character:Destroy()
	end
end

-- Add to purgatory :( 
function NPCService.AddToPurgatory(player : Player, npc : NPC): ()
	if isServer then
		table.insert(_Data[player]["purgatory"], npc)
	else
		NPCEvents.ExecuteOnServer:InvokeServer("AddToPurgatory", player, npc)
	end
end

-- Give NPC a proximity prompt
function NPCService.GivePrompt(npc : NPC): ()
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
				local tool = ToolService.GiveNewTool(player, "laundrybasket", npc.id :: string)
				local success = PlayerService.AssignKey(tool)
				if success then
					npc.state = "pickup"
					NPCService.WalkOut(npc, false)
					NPCService.UpdateLine(player, "dropoff")
					prompt:Destroy()
					NPCService.AddToPurgatory(player, npc)
				else
					ToolService.Destroy(tool)
				end
			elseif state == "pickup" and key and keyState == "Folded" then
				PlayerService.AddMoney(player)
				PlayerService.ClearKey()
				ToolService.Destroy(key)
				prompt:Destroy()
				NPCService.WalkOut(npc, true)
				NPCService.UpdateLine(player, "pickup")
				-- TODO: record satsifaction and whatnot... what events happen when they die
			end
		end)
	end
end

-- Walk NPC out
function NPCService.WalkOut(npc : NPC, destroy : boolean): ()
	if isServer then
		local part : Part = PlayerService.GetStartPoint(npc.player :: Player) :: Part
		NPCService.WalkCharacter(npc, part.Position, part.Rotation)
		task.wait(5)
		if npc.character then
			if destroy then
				npc.character:Destroy()
				--local time = if npc.state == "pickup" then os.time() - npc.spawn_rate else 60
				local time = 60
				if npc.player then
					RatingService.AddTime(npc.player, time)
				end
		else
				npc.character.Parent = ReplicatedStorage
			end
		else 
			warn("Trying to walk out character but character does not exist.")
		end
	else
		NPCEvents.ExecuteOnServer:InvokeServer("WalkOut", npc, destroy)
	end
end

-- Update queue
function NPCService.UpdateLine(player : Player, line : string) -- moves up line if event happens
	if isServer then
		local npc : NPC = table.remove(_Data[player][line], 1) :: NPC
		npc.state = "leaving" 
		if #_Data[player][line] >= 1 then -- check if queue is not empty
			NPCService.GivePrompt(_Data[player][line][1])
		end
		for i, attendant in _Data[player][line] do -- Move all humanoids up in the queue
			local pos = _Data[player]["tycoon"][line].Position + Vector3.new(1, 0, 0) * 2 * (i - 1)
			NPCService.WalkCharacter(attendant, pos, _Data[player]["tycoon"][line].Rotation)
		end
	else
		NPCEvents.ExecuteOnServer:InvokeServer("UpdateLine", player, line)
	end
end

-- Handles server-client communication
if isServer then
	NPCEvents.ExecuteOnServer.OnServerInvoke = function(_player, func, ...)
		return NPCService[func](...)
	end
else
	-- Executes proximity prompt creations via client
	NPCEvents.ExecuteOnClient.OnClientEvent:Connect(function(func : string, ...)
    	NPCService[func](...)
	end)
end

-- Spawn based on ID
function NPCService.SpawnById(player : Player, id : string)
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

	NPCService.SpawnNPC(player, "pickup", npc)
end

function NPCService.GetFirstNPC(player : Player)
	if isServer then
		return _Data[player]["dropoff"][1]
	else
		return NPCEvents.ExecuteOnServer:InvokeServer("GetFirstNPC", Players.LocalPlayer)
	end
end

function NPCService.GetPickupNPC(player : Player)
	if isServer then
		return _Data[player]["pickup"][1]
	else
		return NPCEvents.ExecuteOnServer:InvokeServer("GetPickupNPC", Players.LocalPlayer)
	end
end

-- Create beam attatchment pointing toward NPC
function NPCService.CreateBeam(player : Player) : Beam?
	local Tutorial = require(ReplicatedStorage.UI.Tutorial)
	local first = NPCService.GetFirstNPC(player)
	local npc : NPC = if first then first else NPCEvents.DropoffSpawned.OnClientEvent:Wait()
	local char : Model = npc.character :: Model
	local root = char:FindFirstChild("HumanoidRootPart") :: Part
	local attatchment = root:FindFirstChild("RootAttachment") :: Attachment
	return Tutorial.CreateBeam(player, attatchment)
end

function NPCService.GetPrompt(player : Player) : ProximityPrompt
	local npc : NPC = NPCService.GetFirstNPC(player) or NPCEvents.DropoffSpawned.OnClientEvent:Wait()
	local character = npc.character :: Model
	return character:WaitForChild("ProximityPrompt")
end

function NPCService.GetPickup(player : Player) : ProximityPrompt
	local npc : NPC = NPCService.GetPickupNPC(player) or NPCEvents.PickupSpawned.OnClientEvent:Wait()
	local character = npc.character :: Model
	return character:WaitForChild("ProximityPrompt")
end

return NPCService