local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local morphPlayer = require(ServerStorage.Modules.MorphPlayer)

local morphStorage = ReplicatedStorage.Objects.Morphs
local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer

morphPlayerRemote.OnServerEvent:Connect(function(player, morphName)
    local morph = morphStorage:FindFirstChild(morphName, true)
    local character = player.Character
    if morph and character then
        morphPlayer(character, morph)
    end
end)