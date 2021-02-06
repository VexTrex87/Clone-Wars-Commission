local ReplicatedStorage = game:GetService("ReplicatedStorage")
local morphStorage = ReplicatedStorage.Objects.Morphs
local toolStorage = ReplicatedStorage.Objects.Tools

return {
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