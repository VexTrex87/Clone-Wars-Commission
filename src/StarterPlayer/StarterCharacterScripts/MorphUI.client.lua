local UNHIGHLIGHTED_COLOR = Color3.fromRGB(150, 150, 150)
local HIGHLIGHTED_COLOR = Color3.fromRGB(255, 255, 255)

local DEACTIVATED_COLOR = Color3.fromRGB(230, 57, 70)
local DEACTIVATED_POSITION = UDim2.new(0, 2, 0.5, 0)
local ACTIVATED_COLOR = Color3.fromRGB(57, 230, 80)
local ACTIVATED_POSITION = UDim2.new(0, 28, 0.5, 0)

local SWITCH_TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
local FLASH_DELAY = 0.2
local SETTINGS = {
    ["Light Mode"] = false
}

local CREDITS = {
    {
        Username = "ROBLOX",
        Role = "Manager",
        Contact = "Twitter: @ROBLOX"
    },
    {
        Username = "VexTrexYT",
        Role = "Scripter, UI Designer",
        Contact = "No Contact Information"
    },
    {
        Username = "AdvanceInnovations",
        Role = "Scripter, UI Designer",
        Contact = "No Contact Information"
    }
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = ReplicatedStorage.Modules
local newTween = require(modules.NewTween)
local retry = require(modules.Retry)

local morphStorage = ReplicatedStorage.Objects.Morphs
local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer

local UI = Players.LocalPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local loading = UI.Loading
local topBar = background.TopBar
local morphSelection = background.MorphSelection
local spawnSelection = background.SpawnSelection
local credits = background.Credits
local settingsFrame = background.Settings

local selectedMorph = nil
local settingsData = {}

local function showHighlighted(element, isHovered)
    local chosenColor = isHovered and HIGHLIGHTED_COLOR or UNHIGHLIGHTED_COLOR

    if element:IsA("TextLabel") or element:IsA("TextButton") then
        element.TextColor3 = chosenColor
    end

    for _, child in pairs(element:GetChildren()) do
        if child.Name == "Outline" then
            child.BackgroundColor3 = chosenColor
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextColor3 = chosenColor
        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") or child:IsA("ViewportFrame") then
            child.ImageColor3 = chosenColor
        end
    end

    if element.Parent == morphSelection then
        element.Title.Outline.BackgroundColor3 = chosenColor
    end

    if element:FindFirstChild("BubbleFrame") then
        element.BubbleFrame.BackgroundColor3 = chosenColor
    end
end

local function onMouseHover(element, isHovered)
    if element:IsA("TextButton") and element.Parent == topBar then
        -- highlight if hovered or if corresponding frame is visible
        showHighlighted(element, isHovered or background:FindFirstChild(element.Name) and background[element.Name].Visible)
    elseif element:IsA("ImageButton") and element.Parent.Name == "Morphs" then
        -- highlight if hovered or if button is selected morph
        showHighlighted(element, isHovered or element.Name == selectedMorph)
    elseif element:IsA("Frame") and element.Parent == morphSelection then
        -- highlight if hovered or if group has selected morph
        showHighlighted(element, isHovered or selectedMorph and element:FindFirstChild(selectedMorph, true))    
    elseif element:IsA("Frame") and element.Parent == credits then
        showHighlighted(element, isHovered)
        element.Thumbnail.Visible = not isHovered
        element.Contact.Visible = isHovered
    elseif element:IsA("ImageButton") and element.Parent == settingsFrame then
        showHighlighted(element, isHovered)
    end
end

local function onButtonClicked(button)
    if button:IsDescendantOf(topBar) then
        if button.Name == "Play" then
            if selectedMorph then
                loading.TextLabel.Text = "Loading character..."
                loading.Visible = true
                background.Visible = false
                morphPlayerRemote:InvokeServer(selectedMorph)
                wait(3)
                loading.Visible = false
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
            -- opens corresponding frame & closes others
            for _, frame in pairs(background:GetChildren()) do
                if topBar:FindFirstChild(frame.Name) then
                    frame.Visible = frame.Name == button.Name
                end
            end

            -- highlight corresponding button & unhighlight other buttons
            for _, topBarButton in pairs(topBar:GetChildren()) do
                if topBarButton:IsA("TextButton") then
                    showHighlighted(topBarButton, topBarButton == button)
                end
            end
        end
    elseif button:IsDescendantOf(morphSelection) then
        if button.Parent.Name == "Morphs" then
            selectedMorph = button.Name

            -- highlight pressed morph & highlight others
            for _, morphButton in pairs(morphSelection:GetDescendants()) do
                if morphButton:IsA("ImageButton") and morphButton.Parent.Name == "Morphs" then
                    showHighlighted(morphButton, morphButton == button)
                end
            end

            -- highlight group of pressed morph, unhighlight others
            for _, morphGroupFrame in pairs(morphSelection:GetChildren()) do
                if morphGroupFrame:IsA("Frame") then
                    showHighlighted(morphGroupFrame.Title, selectedMorph and morphGroupFrame:FindFirstChild(selectedMorph, true))
                end
            end
        end
    elseif button:IsDescendantOf(settingsFrame) then
        settingsData[button.Name] = not settingsData[button.Name]
        newTween(button.BubbleFrame.Bubble, SWITCH_TWEEN_INFO, {Position = settingsData[button.Name] and ACTIVATED_POSITION or DEACTIVATED_POSITION})
        newTween(button.BubbleFrame.Bubble, SWITCH_TWEEN_INFO, {BackgroundColor3 = settingsData[button.Name] and ACTIVATED_COLOR or DEACTIVATED_COLOR})
        
        if button.Name == "LightMode" then
            -- do logic here
        end
    end
end

local function createSettings()
    for settingName, defaultOption in pairs(SETTINGS) do
        local newSlot = settingsFrame.UIListLayout.Template:Clone()
        newSlot.Name = settingName
        newSlot.Title.Text = settingName
        newSlot.BubbleFrame.Bubble.BackgroundColor3 = defaultOption and ACTIVATED_COLOR or DEACTIVATED_COLOR
        newSlot.BubbleFrame.Bubble.Position = defaultOption and ACTIVATED_POSITION or DEACTIVATED_POSITION
        newSlot.Parent = settingsFrame

        settingsData[settingName] = defaultOption
    end

    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsFrame.UIListLayout.AbsoluteContentSize.Y)
end

local function createCredits()
    for _, info in pairs(CREDITS) do
        local newSlot = credits.UIListLayout.Template:Clone()
        newSlot.Name = info.Username
        newSlot.Username.Text = info.Username
        newSlot.Role.Text = info.Role
        newSlot.Contact.Text = info.Contact

        local image = nil
        local status = retry(function()
            local userID = Players:GetUserIdFromNameAsync(info.Username)
            image = Players:GetUserThumbnailAsync(userID, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size352x352)
        end)

        if status and image then
            warn("Error occured while retreiving thumbnail for " .. info.Username)
            print(status)
        else
            newSlot.Thumbnail.Image = image
        end

        newSlot.Parent = credits
    end

    credits.CanvasSize = UDim2.new(0, credits.UIListLayout.AbsoluteContentSize.X, 0, 0)
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

            local viewPortFrame = newMorph.ViewportFrame
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
    loading.Visible = true
    loading.TextLabel.Text = "Loading..."

    background.Visible = false
    topBar.Visible = true
    morphSelection.Visible = true
    spawnSelection.Visible = false
    credits.Visible = false
    settingsFrame.Visible = false

    showHighlighted(topBar.MorphSelection, true)
    createMorphs()
    createCredits()
    createSettings()

    for _, element in pairs(UI:GetDescendants()) do
        if element:IsA("TextButton") or element:IsA("ImageButton") then
            element.MouseButton1Click:Connect(function()
                onButtonClicked(element)
            end)
        end
    
        if 
            element:IsA("TextButton") and element.Parent == topBar or
            element:IsA("ImageButton") and element.Parent.Name == "Morphs" or
            element:IsA("Frame") and element.Parent == morphSelection or
            element:IsA("Frame") and element.Parent == credits or
            element:IsA("ImageButton") and element.Parent == settingsFrame
        then
            element.MouseEnter:Connect(function()
                onMouseHover(element, true)
            end)

            element.MouseLeave:Connect(function()
                onMouseHover(element, false)
            end)
        end

    end

    loading.TextLabel.Text = "Loaded"
    wait(1)
    background.Visible = true
    loading.Visible = false
end

__main__()