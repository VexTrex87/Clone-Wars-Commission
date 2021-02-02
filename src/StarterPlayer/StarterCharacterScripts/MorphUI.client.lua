local UNHIGHLIGHTED_COLOR = Color3.fromRGB(150, 150, 150)
local HIGHLIGHTED_COLOR = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local getMorphsRemote = ReplicatedStorage.Objects.Remotes.GetMorphs
local UI = Players.LocalPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local topBar = background.TopBar
local morphSelection = background.MorphSelection

local function showHighlighted(element, isHighlighted)
    local chosenColor = isHighlighted and HIGHLIGHTED_COLOR or UNHIGHLIGHTED_COLOR

    element.TextColor3 = chosenColor
    for _, outline in pairs(element:GetChildren()) do
        if table.find({"Top", "Bottom", "Left", "Right"}, outline.Name) then
            outline.BackgroundColor3 = chosenColor
        end
    end
end

local function onMouseHover(button, isHovered)
    if button:IsDescendantOf(topBar) then
        showHighlighted(button, isHovered or background:FindFirstChild(button.Name) and background[button.Name].Visible)
    end
end

local function onButtonClicked(button)
    if button:IsDescendantOf(topBar) then
        if button.Name == "Play" then
            -- insert play logic here
        else
            for _, frame in pairs(background:GetChildren()) do
                if topBar:FindFirstChild(frame.Name) then -- checks if the frame has a corresponding button
                    frame.Visible = frame.Name == button.Name
                end
            end

            for _, topBarButton in pairs(topBar:GetChildren()) do
                if topBarButton:IsA("TextButton") then
                    showHighlighted(topBarButton, topBarButton == button)
                end
            end
        end
    end
end

local function createMorphs()
    local morphsAndGroupsTable = getMorphsRemote:InvokeServer()
    
    for groupName, morphsTable in pairs(morphsAndGroupsTable) do
        local newGroup = morphSelection.UIListLayout.GroupTemplate:Clone()
        newGroup.Name = groupName
        newGroup.Title.Text = string.upper(groupName)
        newGroup.Parent = morphSelection

        newGroup.MouseEnter:Connect(function()
            showHighlighted(newGroup.Title, true)
        end)

        newGroup.MouseLeave:Connect(function()
            showHighlighted(newGroup.Title, false)
        end)

        for _, morphName in pairs(morphsTable) do
            local newMorph = newGroup.Morphs.UIListLayout.MorphTemplate:Clone()
            newMorph.Name = morphName
            newMorph.Text = string.upper(morphName)
            newMorph.Parent = newGroup.Morphs

            newMorph.MouseButton1Click:Connect(function()
                for _, morphButton in pairs(morphSelection:GetDescendants()) do
                    if morphButton:IsA("TextButton") and morphButton.Name ~= "Title" then
                        showHighlighted(morphButton, morphButton == newMorph)
                    end
                end
            end)

            newMorph.MouseEnter:Connect(function()
                showHighlighted(newMorph, true)
            end)
    
            newMorph.MouseLeave:Connect(function()
                showHighlighted(newMorph, false)
            end)
        end

        newGroup.Size = UDim2.new(0, newGroup.Morphs.UIListLayout.AbsoluteContentSize.X, 1, 0)
    end

    morphSelection.CanvasSize = UDim2.new(0, morphSelection.UIListLayout.AbsoluteContentSize.X, 0, morphSelection.UIListLayout.AbsoluteContentSize.Y)
end

local function __main__()
    background.Visible = true    
    morphSelection.Visible = true
    showHighlighted(topBar.MorphSelection, true)
    createMorphs()

    for _, button in pairs(UI:GetDescendants()) do
        if button:IsA("TextButton") then
            button.MouseButton1Click:Connect(function()
                onButtonClicked(button)
            end)

            button.MouseEnter:Connect(function()
                onMouseHover(button, true)
            end)

            button.MouseLeave:Connect(function()
                onMouseHover(button, false)
            end)
        end
    end
end

__main__()