-- // Variables \\ --
local point1 = workspace.Part1
local point2 = workspace.Part2

local region = Region3.new(point1.Position,point2.Position)

local ignorelist = {point1, point2}
local partsInRegion = {}
local playerInBounds = {}
local teamCount = {
    red = 0,
    blue = 0
}

local tween = game:GetService("TweenService")

local regionVisual = Instance.new("Part")
regionVisual.Anchored = true
regionVisual.CanCollide = false
regionVisual.Transparency = 1
regionVisual.Material = Enum.Material.ForceField
regionVisual.Size = region.Size
regionVisual.TopSurface = Enum.SurfaceType.Smooth
regionVisual.BottomSurface = Enum.SurfaceType.Smooth
regionVisual.Parent = game.Workspace
regionVisual.CFrame = region.CFrame

-- // Functions \\ --

function GetTeamColors()
    local teamsInRegion = {}
    for _,player in playerInBounds do
        if not table.find(teamsInRegion,player.TeamColor) then
            teamsInRegion[player.TeamColor] = 1
        else
            teamsInRegion[player.TeamColor] += 1
        end
    end
end


function RemovePlayers()
    for i,p in pairs(playerInBounds) do
        local Char = p.Character
        if Char.Humanoid.Health == 0 or not table.find(partsInRegion, Char.HumanoidRootPart) then
            table.remove(playerInBounds, i)
            
        end
    end
end

function AddPlayers()
    for _,part in pairs(partsInRegion or {}) do
        local Char = part.Parent
        local player = game.Players:FindFirstChild(Char.Name)
        if player and Char:FindFirstChild("HumanoidRootPart") and not table.find(playerInBounds, player) and Char.Humanoid.Health > 0 then
            table.insert(playerInBounds, player)
            
        end
    end
end

function PulseRed()
    regionVisual.Transparency = 0
    regionVisual.Color = Color3.new(1,0,0)
    local redPulse = tween:Create(regionVisual,TweenInfo.new(1),{Transparency = 1})
    redPulse:Play()

end

function PulseBlue()
    regionVisual.Transparency = 0
    regionVisual.Color = Color3.new(0.015686, 0, 1)
    local bluePulse = tween:Create(regionVisual,TweenInfo.new(1),{Transparency = 1})
    bluePulse:Play()
end

function AddPoints()
    if teamCount.red > teamCount.blue then
        PulseRed()
    elseif teamCount.blue > teamCount.red then
        PulseBlue()
    elseif teamCount.red < 0 and teamCount.blue < 0 then
        regionVisual.Color = Color3.new(255,255,255)
    end
end

-- // Main \\ --

while wait(1) do
    partsInRegion = workspace:FindPartsInRegion3WithIgnoreList(region,ignorelist,math.huge)
    RemovePlayers()
    AddPlayers()
    AddPoints()
    print(teamCount.red)
    print(teamCount.blue)
end


