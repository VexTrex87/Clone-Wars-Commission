local UNHIGHLIGHTED_COLOR = Color3.fromRGB(150, 150, 150)
local HIGHLIGHTED_COLOR = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local UI = player.PlayerGui:WaitForChild("MorphUI")
local getMorphsRemote = ReplicatedStorage.Objects.Remotes.GetMorphs
local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer
local morphTable = getMorphsRemote:InvokeServer()

local selectedMorph = nil

local function main()
    UI.Frame.Visible = true

    for morphGroup, morphNamesInGroup in pairs(morphTable) do
        local newGroupTemplate = UI.Frame.UIListLayout.MorphGroupTemplate:Clone()
        newGroupTemplate.Name = morphGroup
        newGroupTemplate.Title.Text = morphGroup
        newGroupTemplate.Parent = UI.Frame

        newGroupTemplate.Title.MouseButton1Click:Connect(function()
            newGroupTemplate.Morphs.Visible = not newGroupTemplate.Morphs.Visible
            newGroupTemplate.Size = UDim2.new(1, 0, 0, newGroupTemplate.UIListLayout.AbsoluteContentSize.Y + 5)
        end)

        for _, morphName in pairs(morphNamesInGroup) do
            local newMorphTemplate = newGroupTemplate.Morphs.UIListLayout.MorphTemplate:Clone()
            newMorphTemplate.Name = morphName
            newMorphTemplate.Text = morphName
            newMorphTemplate.Parent = newGroupTemplate.Morphs

            newMorphTemplate.MouseButton1Click:Connect(function()
                if selectedMorph then
                    local previousSelectedMorph = UI.Frame:FindFirstChild(selectedMorph, true)
                    previousSelectedMorph.TextColor3 = UNHIGHLIGHTED_COLOR
                end

                selectedMorph = newMorphTemplate.Name
                newMorphTemplate.TextColor3 = HIGHLIGHTED_COLOR
                UI.Frame.Spawn.Text = "Spawn as " .. selectedMorph
            end)
        end

        newGroupTemplate.Size = UDim2.new(1, 0, 0, newGroupTemplate.UIListLayout.AbsoluteContentSize.Y + 5)
    end

    UI.Frame.CanvasSize = UDim2.new(0, 0, 0, UI.Frame.UIListLayout.AbsoluteContentSize.Y)

    UI.Frame.Spawn.MouseButton1Click:Connect(function()
        UI.Frame.Visible = false
        morphPlayerRemote:FireServer(selectedMorph)
    end)

end

main()