local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MorphsConfiguration = require(ReplicatedStorage.Modules.Configuration.Morphs)
local morphPlayer = require(ServerStorage.Modules.MorphPlayer)

local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer

local groupRanks = {}

local function giveTools(player, tools)
    for _, tool in pairs(tools) do
        tool:Clone().Parent = player.Backpack
    end
end

Players.PlayerAdded:Connect(function(player)
    groupRanks[player.Name] = MorphsConfiguration.GetPlayerRanks(player)
end)

Players.PlayerRemoving:Connect(function(player)
    groupRanks[player.Name] = nil
end)

morphPlayerRemote.OnServerInvoke = function(player, morphName)
    local character = player.Character
    local morphInfo = nil

    for _, morphList in pairs(MorphsConfiguration.Data) do
        for morphNameInList, morphInfoInList in pairs(morphList) do
            if morphNameInList == morphName then
                morphInfo = morphInfoInList
                break
            end
        end
    end

    if morphInfo and MorphsConfiguration.CheckIfPlayerMeetsRequirement(morphInfo.Requirements, groupRanks[player.Name]) then
        if character and morphInfo.Morph then
            giveTools(player, morphInfo.Tools)
            morphPlayer(character, morphInfo.Morph)
        end
    end
end