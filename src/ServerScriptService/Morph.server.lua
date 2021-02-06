local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local morphs = require(ReplicatedStorage.Modules.Configuration.Morphs)
local morph = require(ReplicatedStorage.Modules.Morph)
local morphPlayer = require(ServerStorage.Modules.MorphPlayer)

local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer

local groupRanks = {}

local function giveTools(player, tools)
    for _, tool in pairs(tools) do
        tool:Clone().Parent = player.Backpack
    end
end

Players.PlayerAdded:Connect(function(player)
    groupRanks[player.Name] = morph.GetPlayerRanks(player)
end)

Players.PlayerRemoving:Connect(function(player)
    groupRanks[player.Name] = nil
end)

morphPlayerRemote.OnServerInvoke = function(player, nameOfRequestedMorph)
    local character = player.Character

    for _, morphList in pairs(morphs) do
        for morphName, morphInfo in pairs(morphList) do
            if morphName ~= nameOfRequestedMorph then
                continue
            end

            if not morph.CheckIfPlayerMeetsRequirement(morphInfo.Requirements, groupRanks[player.Name]) then
                continue
            end

            if not character or not morphInfo.Morph then
                continue
            end

            giveTools(player, morphInfo.Tools)
            morphPlayer(character, morphInfo.Morph)
        end
    end
end