local UNHIGHLIGHTED_COLOR = Color3.fromRGB(150, 150, 150)
local HIGHLIGHTED_COLOR = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local morphStorage = ReplicatedStorage.Objects.Morphs
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

local function onMouseHover(element, isHovered)
    if element:IsDescendantOf(topBar) then
        showHighlighted(element, isHovered or background:FindFirstChild(element.Name) and background[element.Name].Visible)
    elseif element.Parent == morphSelection then
        showHighlighted(element.Title, isHovered)
    elseif element.Parent.Name == "Morphs" then
        showHighlighted(element, isHovered)
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
    elseif button:IsDescendantOf(morphSelection) then
        if button.Parent.Name == "Title" then
            for _, morphButton in pairs(morphSelection:GetDescendants()) do
                if morphButton:IsA("TextButton") and morphButton.Name ~= "Title" then
                    showHighlighted(morphButton, morphButton == button)
                end
            end
        end
    end
end

local function createMorphs()
    for _, group in pairs(morphStorage:GetChildren()) do
        local newGroup = morphSelection.UIListLayout.GroupTemplate:Clone()
        newGroup.Name = group.Name
        newGroup.Title.Text = string.upper(group.Name)
        newGroup.Parent = morphSelection

        for _, morph in pairs(group:GetChildren()) do
            local newMorph = newGroup.Morphs.UIListLayout.MorphTemplate:Clone()
            newMorph.Name = morph.Name
            newMorph.Text = string.upper(morph.Name)
            newMorph.Parent = newGroup.Morphs
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

    for _, element in pairs(UI:GetDescendants()) do
        if element:IsA("TextButton") then
            element.MouseButton1Click:Connect(function()
                onButtonClicked(element)
            end)
        end
    
        if element:IsA("TextButton") or element:IsA("Frame") and element:FindFirstChild("Title") then
            element.MouseEnter:Connect(function()
                onMouseHover(element, true)
            end)

            element.MouseLeave:Connect(function()
                onMouseHover(element, false)
            end)
        end
    end
end

__main__()