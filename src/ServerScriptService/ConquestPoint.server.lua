local UPDATE_DELAY = 1
local TAG = "ConquestPoint"
local MAX_PARTS_IN_REGION = math.huge
local MAX_SECONDS_TO_CAPTURE = 5
local FLASH_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
local FILL_UI_TWEEN_INFO = {Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.5, true}
local NEUTRAL_COLOR = BrickColor.White()

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local modules = ReplicatedStorage.Modules
local collection = require(modules.Collection)
local newTween = require(modules.NewTween)
local newThread = require(modules.NewThread)

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
    local teamsInRegion = {}
    info.NewCapturingTeam = nil

    for _, player in pairs(info.PlayersInRegion) do
        if not teamsInRegion[player.Team.Name] then
            teamsInRegion[player.Team.Name] = 1
        else
            teamsInRegion[player.Team.Name] += 1
        end
    end

    local highestTeamCount = 0
    local highestTeam = nil
    for teamName, teamCount in pairs(teamsInRegion) do
        if teamCount > highestTeamCount then
            highestTeamCount = teamCount
            highestTeam = teamName
        elseif teamCount == highestTeamCount then
            highestTeam = nil
        end
    end

    for teamName, _ in pairs(teamsInRegion) do
        if not info.TeamsCapturing[teamName] then
            info.TeamsCapturing[teamName] = 0
        end
    end

    local areAllTeamsAreNeutral = true
    for teamName, secondsCapturing in pairs(info.TeamsCapturing) do
        if teamName ~= highestTeam and secondsCapturing ~= 0 then
            areAllTeamsAreNeutral = false
            break
        end
    end

    for teamName, secondsCapturing in pairs(info.TeamsCapturing) do
        if teamName == highestTeam then
            if secondsCapturing < MAX_SECONDS_TO_CAPTURE and areAllTeamsAreNeutral then
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
    local largestTeam = nil
    local longestTimeCapturing = 0
    for teamName, timeCapturing in pairs(info.TeamsCapturing) do
        if timeCapturing > longestTimeCapturing then
            largestTeam = teamName
            longestTimeCapturing = timeCapturing
        elseif timeCapturing == longestTimeCapturing then
            largestTeam = nil
        end
    end

    local specificTeam = largestTeam
    if specificTeam then
        local timeCapturing = info.TeamsCapturing[specificTeam]
        local teamColor = Teams[specificTeam].TeamColor
    
        info.FillUI.BackgroundColor3 = teamColor.Color
        info.FillUI:TweenSize(UDim2.fromScale(timeCapturing / MAX_SECONDS_TO_CAPTURE, 1), table.unpack(FILL_UI_TWEEN_INFO))
    
        if timeCapturing == MAX_SECONDS_TO_CAPTURE then
            info.TeamCapturingValue.Value = specificTeam
            info.PointName.TextColor3 = teamColor.Color
            info.ConquestPoint.BrickColor = teamColor
        else
            newThread(function()
                newTween(info.PointName, FLASH_TWEEN_INFO, {TextColor3 = NEUTRAL_COLOR.Color})
                newTween(info.ConquestPoint, FLASH_TWEEN_INFO, {Color = NEUTRAL_COLOR.Color}).Completed:Wait()

                newTween(info.PointName, FLASH_TWEEN_INFO, {TextColor3 = teamColor.Color})
                newTween(info.ConquestPoint, FLASH_TWEEN_INFO, {Color = teamColor.Color})
            end)
        end
    else
        info.TeamCapturingValue.Value = "NEUTRAL"
        info.PointName.TextColor3 = NEUTRAL_COLOR.Color
        info.ConquestPoint.BrickColor = NEUTRAL_COLOR
        info.FillUI:TweenSize(UDim2.fromScale(0, 1), table.unpack(FILL_UI_TWEEN_INFO))
    end
end

local function __main__()
    collection(TAG, function(conquestPoint)
        local info = {
            ConquestPoint = conquestPoint,
            FillUI = conquestPoint.BillboardGui.Background.Fill,
            PointName = conquestPoint.BillboardGui.PointName,
            TeamCapturingValue = conquestPoint.TeamCapturing,
            Region = Region3.new(conquestPoint.Position - conquestPoint.Size / 2, conquestPoint.Position + conquestPoint.Size / 2),

            PartsInRegion = {},
            PlayersInRegion = {},
            TeamsCapturing = {},
            CapturingTeam = nil,

            IGNORE_LIST = {},
        }

        if info.ConquestPoint.SpawningTeam.Value == "" then
            while true do
                info.PartsInRegion = Workspace:FindPartsInRegion3WithIgnoreList(info.Region, info.IGNORE_LIST, MAX_PARTS_IN_REGION)
                addPlayers(info)
                initiateCapturing(info)
                visualize(info)
                wait(UPDATE_DELAY)
            end
        else
            local teamColor = Teams[info.ConquestPoint.SpawningTeam.Value].TeamColor
            info.FillUI.Parent.Visible = false
            info.PointName.TextColor3 = teamColor.Color
            info.ConquestPoint.BrickColor = teamColor
        end
    end)
end

__main__()