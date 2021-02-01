local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local morphPlayer = require(ServerStorage.Modules.MorphPlayer)

local morphStorage = ServerStorage.Objects.Morphs
local getMorphsRemote = ReplicatedStorage.Objects.Remotes.GetMorphs
local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer

getMorphsRemote.OnServerInvoke = function()
    local morphTable = {}
    
    for _, morphGroup in pairs(morphStorage:GetChildren()) do
        morphTable[morphGroup.Name] = {}
        for __, morph in pairs(morphGroup:GetChildren()) do
            table.insert(morphTable[morphGroup.Name], morph.Name)
        end
    end

    return morphTable
end

morphPlayerRemote.OnServerEvent:Connect(function(player, morphName)
    local morph = morphStorage:FindFirstChild(morphName, true)
    local character = player.Character
    if morph and character then
        morphPlayer(character, morph)
    end
end)