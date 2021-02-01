local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local stormTrooper = ServerStorage.Objects.Morphs.StormTrooper
local morphPlayer = require(ServerStorage.Modules.MorphPlayer)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAppearanceLoaded:Connect(function(character)
        morphPlayer(character, stormTrooper)
    end)
end)