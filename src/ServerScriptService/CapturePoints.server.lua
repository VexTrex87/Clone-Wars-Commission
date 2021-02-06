-- // Variables \\ --
local point1 = workspace.Part1
local point2 = workspace.Part2

local region = Region3.new(point1.Position,point2.Position)

local ignorelist = {point1, point2}
local partsInRegion = {}
local playerInBounds = {}
local teamsInRegion = {}

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

local function NewThread(func,...)
    local a = coroutine.wrap(func)
    a(...)
end

function GetTeamColors()
    teamsInRegion = {}
    for _,player in pairs (playerInBounds) do
        if not table.find(teamsInRegion,player.TeamColor) then
            teamsInRegion[tostring(player.TeamColor)] = 1
        else
            teamsInRegion[tostring(player.TeamColor)] += 1
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
    playerInBounds = {}
    for _,part in pairs(partsInRegion or {}) do
        local Char = part.Parent
        local player = game.Players:FindFirstChild(Char.Name)
        if player and Char:FindFirstChild("HumanoidRootPart") and not table.find(playerInBounds, player) and Char.Humanoid.Health > 0 then
            table.insert(playerInBounds, player)
            
        end
    end
end

function AddPoints()
    local highestTeam = nil
    local highestTeamCount = 0

    for teams,count in pairs(teamsInRegion) do
        if count > highestTeamCount then
            highestTeamCount = count
            highestTeam = teams
            
        end
    end
end

-- // Main \\ --

while wait(1) do
    partsInRegion = workspace:FindPartsInRegion3WithIgnoreList(region,ignorelist,math.huge)
    RemovePlayers()
    AddPlayers()
    AddPoints()
    GetTeamColors()
end


