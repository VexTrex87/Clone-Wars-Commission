local ReplicatedStorage = game:GetService("ReplicatedStorage")

local retry = require(ReplicatedStorage.Modules.Retry)

local morphStorage = ReplicatedStorage.Objects.Morphs
local toolStorage = ReplicatedStorage.Objects.Tools

local module = {}

module.Data = {
    ["Colored Warriors"] = {
        ["Chocolate Clone Trooper"] = {
            Morph = morphStorage["Colored Warriors"]["Chocolate Clone Trooper"],
            Tools = {
                toolStorage.Shotgun
            },
            Requirements = {
                [543792] = {1} -- random group, specific rank
            },
        },
        ["Clay Clone Trooper"] = {
            Morph = morphStorage["Colored Warriors"]["Clay Clone Trooper"],
            Tools = {
                toolStorage.Shotgun
            },
            Requirements = {},
        },
        ["Gold Clone Trooper"] = {
            Morph = morphStorage["Colored Warriors"]["Gold Clone Trooper"],
            Tools = {
                toolStorage.Shotgun
            },
            Requirements = {},
        },
        ["Green Clone Trooper"] = {
            Morph = morphStorage["Colored Warriors"]["Green Clone Trooper"],
            Tools = {
                toolStorage.Shotgun
            },
            Requirements = {},
        },
        ["Red Clone Trooper"] = {
            Morph = morphStorage["Colored Warriors"]["Red Clone Trooper"],
            Tools = {
                toolStorage.Shotgun
            },
            Requirements = {},
        },
        ["Water Clone Trooper"] = {
            Morph = morphStorage["Colored Warriors"]["Water Clone Trooper"],
            Tools = {
                toolStorage.Shotgun
            },
            Requirements = {},
        },
        ["Yellow Clone Trooper"] = {
            Morph = morphStorage["Colored Warriors"]["Yellow Clone Trooper"],
            Tools = {
                toolStorage.Shotgun
            },
            Requirements = {},
        },
    },
    ["Galactic Republic"] = {
        ["Clone Trooper"] = {
            Morph = morphStorage["Galactic Republic"]["Clone Trooper"],
            Tools = {
                toolStorage["Assult Rifle"]
            },
            Requirements = {
                [6458408] = {200, "*"} -- neo systems, minimum rank
            },
        },
    }
}

function module.GetPlayerRanks(player)
    local groupRanks = {}
    for _, morphList in pairs(module.Data) do
        for morphName, morphInfo in pairs(morphList) do
            for groupId, groupRoles in pairs(morphInfo.Requirements) do
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