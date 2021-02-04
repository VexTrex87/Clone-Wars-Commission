local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local morphPlayer = require(ServerStorage.Modules.MorphPlayer)

local morphStorage = ReplicatedStorage.Objects.Morphs
local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer

morphPlayerRemote.OnServerInvoke = function(player, morphName)
    local character = player.Character
    local morph = morphStorage:FindFirstChild(morphName, true)
    if character and morph then
        morphPlayer(character, morph)
    end
end