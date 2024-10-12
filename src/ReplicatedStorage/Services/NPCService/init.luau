-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local NPCData = require(ReplicatedStorage.Data.NPCData)
local OutfitData = require(ReplicatedStorage.Data.OutfitData)
local MovementService = require(ReplicatedStorage.Util.MovementService)

-- Constants
local Model = ServerStorage.NPC.model

-- Events
local NPCService = {}

-- Spawns character in world and creates if necessary
function NPCService.SpawnNewCharacter(type : string, point : CFrameValue) : table
    local data = NPCData.Get(type)
    local character : Model = data["character"]
    if character then
        character.Parent = workspace
    else
        character = Model:Clone() -- Create new character
        character.Parent = workspace 

        local humanoid = character.Humanoid or character:WaitForChild("Humanoid")
        local humDesc = humanoid:GetAppliedDescription()

        humDesc.Face = OutfitData.GetRandomFromCategory("face")
        humDesc.Shirt = OutfitData.GetRandomFromCategory("shirt")
        humDesc.Pants = OutfitData.GetRandomFromCategory("pants")
        humDesc.HairAccessory = OutfitData.GetRandomFromCategory("hair")
        humanoid:ApplyDescription(humDesc)
    end

    character.HumanoidRootPart.CFrame = point -- Set to point
    data["character"] = character
    return data
end

-- Walks character to point
function NPCService.WalkCharacter(data : table, point : Vector3)
    local character : Model = data["character"]
    if not character then
        error("Character not given.")
        return
    end

    MovementService.Move(character, point)
end

function NPCService.GetStatus(data : table) : string
    return data["status"]
end

function NPCService.DestroyAll(npcs : table) : nil
    for _, npc in npcs do
        npc["character"]:Destroy()
    end
end

return NPCService