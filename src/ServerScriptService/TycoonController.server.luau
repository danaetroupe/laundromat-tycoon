local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TycoonService = require(ReplicatedStorage.Services.TycoonService)

local Tycoons = {}
local PlayerTycoons = {}

local function Init() : nil -- Initalize service
    Tycoons = TycoonService.Init()
    for _, tycoon in Tycoons do
        local claimPart = TycoonService.GetClaim(tycoon)
        claimPart.Touched:Connect(function(touch)
            print('touched')
            local character = touch.Parent
            local player = Players:GetPlayerFromCharacter(character)

            if player and not PlayerTycoons[player] then -- assign tycoon to player
                PlayerTycoons[player] = tycoon
                Players.PlayerRemoving:Connect(function(plr)
                    if player == plr then
                        PlayerTycoons[player] = nil
                    end
                end)
            end
        end)
    end   
end

Init()