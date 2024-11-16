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
type Employee = NPCData.Employee

-- Events
local isServer = RunService:IsServer()
local EmployeeService = {}
local _Data = {}

-- Takes tycoon active state and spawns NPCs
function EmployeeService.Init(player : Player)
	if not _Data[player] then
		_Data[player] = {}

        Players.PlayerRemoving:Connect(function(plr)
            if player == plr then
				for _, _employee : Employee in _Data[player] do
					-- todo: cleanup employee
					continue
				end
                _Data[player] = nil
            end
        end)
	end
end

function EmployeeService.CreateEmployee()
	
end



return EmployeeService