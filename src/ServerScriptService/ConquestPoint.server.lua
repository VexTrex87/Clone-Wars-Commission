local UPDATE_DELAY = 1
local TAG = "ConquestPoint"
local MAX_PARTS_IN_REGION = math.huge
local MAX_SECONDS_TO_CAPTURE = 10
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

local function findCapturingTeam(info)
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
    for teamName, teamCount in pairs(info.TeamsInRegion) do
        if teamCount > highestTeamCount then
            highestTeamCount = teamCount
            info.NewCapturingTeam = teamName
        elseif teamCount == highestTeamCount then
            info.NewCapturingTeam = nil
        end
    end
end

local function initiateCapturing(info)
    print(info.CapturingTeam, info.NewCapturingTeam)

    if not info.CapturingTeam and info.NewCapturingTeam or info.NewCapturingTeam and info.CapturingTeam == info.NewCapturingTeam then
        if info.TimeCapturing < MAX_SECONDS_TO_CAPTURE then
            info.TimeCapturing += 1
        end
    elseif info.NewCapturingTeam and info.CapturingTeam ~= info.NewCapturingTeam and info.TimeCapturing > 0 then
        info.TimeCapturing -= 1
    elseif not info.CapturingTeam and not info.NewCapturingTeam and info.TimeCapturing > 0 then
        info.TimeCapturing -= 1
    end

    if info.TimeCapturing == MAX_SECONDS_TO_CAPTURE and info.NewCapturingTeam and info.CapturingTeam ~= info.NewCapturingTeam then
        info.CapturingTeam = info.NewCapturingTeam
    elseif info.TimeCapturing == 0 then
        info.CapturingTeam = nil
    end

    print(info.TimeCapturing)
end

local function visualize(info)
    local pointColor = not info.CapturingTeam and NEUTRAL_COLOR or Teams[info.CapturingTeam].TeamColor
    if info.TimeCapturing == MAX_SECONDS_TO_CAPTURE or info.TimeCapturing == 0 then
        info.ConquestPoint.BrickColor = pointColor
    elseif info.TimeCapturing > 0 then
        newTween(info.ConquestPoint, FLASH_TWEEN_INFO, {Color = pointColor.Color}).Completed:Wait()
        newTween(info.ConquestPoint, FLASH_TWEEN_INFO, {Color = NEUTRAL_COLOR.Color}).Completed:Wait()
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

            CapturingTeam = nil,
            NewCapturingTeam = nil,
            TimeCapturing = 0,

            IGNORE_LIST = {},
        }

        while true do
            info.PartsInRegion = Workspace:FindPartsInRegion3WithIgnoreList(info.Region, info.IGNORE_LIST, MAX_PARTS_IN_REGION)
            addPlayers(info)
            findCapturingTeam(info)
            initiateCapturing(info)
            visualize(info)
            wait(UPDATE_DELAY)
            
            warn("----------------------")
        end
    end)
end

__main__()