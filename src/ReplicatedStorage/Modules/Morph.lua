local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
local morphs = require(modules.Configuration.Morphs)
local retry = require(modules.Retry)
local module = {}

function module.GetPlayerRanks(player)
    local groupRanks = {}
    for _, morphList in pairs(morphs) do
        for _, morphInfo in pairs(morphList) do
            for groupId, _ in pairs(morphInfo.Requirements) do
                local status = retry(function()
                    groupRanks[groupId] = player:GetRankInGroup(groupId)
                end)
    
                if status then
                    warn("Problem retreiving group rank for group " .. groupId)
                    print(status)
                end
            end
        end
    end
    return groupRanks
end

function module.CheckIfPlayerMeetsRequirement(requirements, groupRanks)
    -- check if there are no requirements
    if not next(requirements) then
        return true
    end

    for groupId, requiredRanks in pairs(requirements) do
        if table.find(requiredRanks, groupRanks[groupId]) then
            return true
        elseif requiredRanks[#requiredRanks] == "*" and typeof(groupRanks[groupId]) == "number" and groupRanks[groupId] >= requiredRanks[#requiredRanks - 1] then
            return true
        end
    end
end

return module