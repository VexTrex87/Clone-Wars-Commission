local UNHIGHLIGHTED_COLOR = Color3.fromRGB(150, 150, 150)
local HIGHLIGHTED_COLOR = Color3.fromRGB(255, 255, 255)
local FLASH_DELAY = 0.2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local morphStorage = ReplicatedStorage.Objects.Morphs
local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer

local UI = Players.LocalPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local topBar = background.TopBar
local morphSelection = background.MorphSelection

local selectedMorph = nil

local function showHighlighted(element, isHighlighted)
    local chosenColor = isHighlighted and HIGHLIGHTED_COLOR or UNHIGHLIGHTED_COLOR

    if element:IsA("TextButton") then
        element.TextColor3 = chosenColor
    end
    
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
        local chosenColor = isHovered and HIGHLIGHTED_COLOR or element.Name == selectedMorph and HIGHLIGHTED_COLOR or UNHIGHLIGHTED_COLOR

        element.MorphName.TextColor3 = chosenColor
        for _, outline in pairs(element:GetChildren()) do
            if table.find({"Top", "Bottom", "Left", "Right"}, outline.Name) then
                outline.BackgroundColor3 = chosenColor
            end
        end
    end
end

local function onButtonClicked(button)
    if button:IsDescendantOf(topBar) then
        if button.Name == "Play" then
            if selectedMorph then
                background.Visible = false
                morphPlayerRemote:FireServer(selectedMorph)
            else
                for x = 1, 3 do
                    topBar.Play.Text = "NO MORPH SELECTED"
                    wait(FLASH_DELAY)
                    topBar.Play.Text = ""
                    wait(FLASH_DELAY)
                end

                topBar.Play.Text = "PLAY"
            end
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
        elseif button.Parent.Name == "Morphs" then
            showHighlighted(button, true)
            selectedMorph = button.Name

            for _, morphButton in pairs(morphSelection:GetDescendants()) do
                if morphButton:IsA("ImageButton") and morphButton.Parent.Name == "Morphs" then
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
            newMorph.Parent = newGroup.Morphs

            newMorph.MorphName.Text = string.upper(morph.Name)

            local viewPortFrame = newMorph.ViewPortFrame

            local morphClone = morph:Clone()
            morphClone.Parent = viewPortFrame

            local viewportCamera = Instance.new("Camera")
            viewportCamera.CameraType = Enum.CameraType.Attach
            viewportCamera.CameraSubject = morphClone.UpperTorso.Middle
            viewportCamera.Parent = viewPortFrame
            viewportCamera.CFrame = morphClone.UpperTorso.Middle.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, math.rad(180), 0)

            viewPortFrame.CurrentCamera = viewportCamera
        end

        newGroup.Size = UDim2.new(0, newGroup.Morphs.UIListLayout.AbsoluteContentSize.X, 1, -20)
    end

    morphSelection.CanvasSize = UDim2.new(0, morphSelection.UIListLayout.AbsoluteContentSize.X, 0, 0)
end

local function __main__()
    background.Visible = true    
    morphSelection.Visible = true
    showHighlighted(topBar.MorphSelection, true)
    createMorphs()

    for _, element in pairs(UI:GetDescendants()) do
        if element:IsA("TextButton") or element:IsA("ImageButton") then
            element.MouseButton1Click:Connect(function()
                onButtonClicked(element)
            end)
        end
    
		if 
            element:IsA("TextButton") or 
            element:IsA("ImageButton") or
			element:IsA("Frame") and element:FindFirstChild("Title")
		then
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