local UPDATE_DELAY = 1
local TAG = "ConquestPoint"
local MAX_PARTS_IN_REGION = math.huge
local MAX_SECONDS_TO_CAPTURE = 5
local FLASH_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
local NEUTRAL_COLOR = BrickColor.White()

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local modules = ReplicatedStorage.Modules
local collection = require(modules.Collection)
local newTween = require(modules.NewTween)

local function addPlayers(info)
    table.clear(info.PlayersInRegion)
    for _, part in pairs(info.PartsInRegion) do
        local player = Players:GetPlayerFromCharacter(part.Parent)
        if player and not table.find(info.PlayersInRegion, player) then
            table.insert(info.PlayersInRegion, player)
        end
    end
end

local function initiateCapturing(info)
    table.clear(info.TeamsInRegion)
    info.NewCapturingTeam = nil

    for _, player in pairs(info.PlayersInRegion) do
        if not info.TeamsInRegion[player.Team.Name] then
            info.TeamsInRegion[player.Team.Name] = 1
        else
            info.TeamsInRegion[player.Team.Name] += 1
        end
    end

    local highestTeamCount = 0
    local highestTeam = nil
    for teamName, teamCount in pairs(info.TeamsInRegion) do
        if teamCount > highestTeamCount then
            highestTeamCount = teamCount
            highestTeam = teamName
        elseif teamCount == highestTeamCount then
            highestTeam = nil
        end
    end

    for teamName, _ in pairs(info.TeamsInRegion) do
        if not info.TeamsCapturing[teamName] then
            info.TeamsCapturing[teamName] = 0
        end
    end

    for teamName, secondsCapturing in pairs(info.TeamsCapturing) do
        if teamName == highestTeam then
            if secondsCapturing < MAX_SECONDS_TO_CAPTURE then
                info.TeamsCapturing[teamName] += 1
                if info.TeamsCapturing[teamName] == MAX_SECONDS_TO_CAPTURE then
                    info.CapturingTeam = teamName
                end
            end
        elseif highestTeam and info.TeamsCapturing[teamName] > 0 then
            info.TeamsCapturing[teamName] -= 1
        end
    end
end

local function visualize(info)
    if info.CapturingTeam then
        local timeCapturing = info.TeamsCapturing[info.CapturingTeam]
        local teamColor = Teams[info.CapturingTeam].TeamColor
        if timeCapturing == MAX_SECONDS_TO_CAPTURE then
            info.ConquestPoint.BrickColor = teamColor
        else
            newTween(info.ConquestPoint, FLASH_TWEEN_INFO, {Color = NEUTRAL_COLOR.Color}).Completed:Wait()
            newTween(info.ConquestPoint, FLASH_TWEEN_INFO, {Color = teamColor.Color}).Completed:Wait()
        end
    else
        info.ConquestPoint.BrickColor = NEUTRAL_COLOR
    end
end

local function __main__()
    collection(TAG, function(conquestPoint)
        local info = {
            ConquestPoint = conquestPoint,
            Region = Region3.new(conquestPoint.Position - conquestPoint.Size / 2, conquestPoint.Position + conquestPoint.Size / 2),

            PartsInRegion = {},
            PlayersInRegion = {},
            TeamsInRegion = {},
            TeamsCapturing = {},
            CapturingTeam = nil,

            IGNORE_LIST = {},
        }

        while true do
            info.PartsInRegion = Workspace:FindPartsInRegion3WithIgnoreList(info.Region, info.IGNORE_LIST, MAX_PARTS_IN_REGION)
            addPlayers(info)
            initiateCapturing(info)
            visualize(info)
            wait(UPDATE_DELAY)
        end
    end)
end

__main__()