local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")
local ContentProvider = game:GetService("ContentProvider")

local modules = ReplicatedStorage.Modules
local newTween = require(modules.NewTween)
local retry = require(modules.Retry)
local configuration = modules.Configuration
local MorphUIConfiguration = require(configuration.MorphUI)
local MorphsConfiguration = require(configuration.Morphs)

local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer
local musicStorage = ReplicatedStorage.Objects.Music
local clickSound = ReplicatedStorage.Objects.Sounds.Click

local localPlayer = Players.LocalPlayer
local UI = localPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local loading = UI.Loading
local topBar = background.TopBar
local morphSelection = background.MorphSelection
local spawnSelection = background.SpawnSelection
local credits = background.Credits
local settingsFrame = background.Settings

local selectedMorph = nil
local settingsData = {}
local groupRanks = MorphsConfiguration.GetPlayerRanks(localPlayer)

local function showHighlighted(element, isHovered)
    local chosenColor = isHovered and MorphUIConfiguration.HighlightedColor or MorphUIConfiguration.UnhighlightedColor

    if element:IsA("TextLabel") or element:IsA("TextButton") then
        element.TextColor3 = chosenColor
    end

    for _, child in ipairs(element:GetChildren()) do
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

local function playMusic()
    while true do
        for _,sound in ipairs(musicStorage:GetChildren()) do
            sound.Volume = settingsData.Music and MorphUIConfiguration.MusicVolume or 0
            sound:Play()
            sound.Stopped:Wait()
            wait(math.random(MorphUIConfiguration.MinMusicDelay, MorphUIConfiguration.MaxMusicDelay))
        end
    end
end

local function onMouseHover(element, isHovered)
    if element:IsA("TextButton") and element.Parent == topBar then
        -- highlight if hovered or if corresponding frame is visible
        showHighlighted(element, isHovered or background:FindFirstChild(element.Name) and background[element.Name].Visible)
    elseif element:IsA("ImageButton") and element.Parent.Name == "Morphs" then
        local morphInfo = MorphsConfiguration.Data[element.Parent.Parent.Name] and MorphsConfiguration.Data[element.Parent.Parent.Name][element.Name]
        if morphInfo then
            local meetsRequirement = MorphsConfiguration.CheckIfPlayerMeetsRequirement(morphInfo.Requirements, groupRanks)
            if meetsRequirement then
                showHighlighted(element, isHovered or element.Name == selectedMorph)
            elseif #element.Requirements:GetChildren() > 2 then
                element.ViewportFrame.Visible = not isHovered
                element.Requirements.Visible = isHovered
            end
        end
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
    clickSound:Play()

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
                for _ = 1, 3 do
                    topBar.Play.Text = "NO MORPH SELECTED"
                    wait(MorphUIConfiguration.FlashDelay)
                    topBar.Play.Text = ""
                    wait(MorphUIConfiguration.FlashDelay)
                end

                topBar.Play.Text = "PLAY"
            end
        else
            -- opens corresponding frame & closes others
            for _, frame in ipairs(background:GetChildren()) do
                if topBar:FindFirstChild(frame.Name) then
                    frame.Visible = frame.Name == button.Name
                end
            end

            -- highlight corresponding button & unhighlight other buttons
            for _, topBarButton in ipairs(topBar:GetChildren()) do
                if topBarButton:IsA("TextButton") then
                    showHighlighted(topBarButton, topBarButton == button)
                end
            end
        end
    elseif button:IsDescendantOf(morphSelection) then
        if button.Parent.Name == "Morphs" then
            local morphInfo = MorphsConfiguration.Data[button.Parent.Parent.Name] and MorphsConfiguration.Data[button.Parent.Parent.Name][button.Name]
            if morphInfo then
                local meetsRequirement = MorphsConfiguration.CheckIfPlayerMeetsRequirement(morphInfo.Requirements, groupRanks)
                if meetsRequirement then
                    selectedMorph = button.Name

                    -- highlight pressed morph & highlight others
                    for _, morphButton in ipairs(morphSelection:GetDescendants()) do
                        if morphButton:IsA("ImageButton") and morphButton.Parent.Name == "Morphs" then
                            showHighlighted(morphButton, morphButton == button)
                        end
                    end
        
                    -- highlight group of pressed morph, unhighlight others
                    for _, morphGroupFrame in ipairs(morphSelection:GetChildren()) do
                        if morphGroupFrame:IsA("Frame") then
                            showHighlighted(morphGroupFrame.Title, selectedMorph and morphGroupFrame:FindFirstChild(selectedMorph, true))
                        end
                    end
                else
                    for _ = 1, 3 do
                        button.MorphName.Text = "REQUIREMENTS NOT MET"
                        wait(MorphUIConfiguration.FlashDelay)
                        button.MorphName.Text = ""
                        wait(MorphUIConfiguration.FlashDelay)
                    end
    
                    button.MorphName.Text = button.Name
                end
            end
        end
    elseif button:IsDescendantOf(settingsFrame) then
        settingsData[button.Name] = not settingsData[button.Name]
        newTween(button.BubbleFrame.Bubble, MorphUIConfiguration.SwitchTweenInfo, {Position = settingsData[button.Name] and MorphUIConfiguration.ActivatedPosition or MorphUIConfiguration.DeactivatedPosition})
        newTween(button.BubbleFrame.Bubble, MorphUIConfiguration.SwitchTweenInfo, {BackgroundColor3 = settingsData[button.Name] and MorphUIConfiguration.ActivatedColor or MorphUIConfiguration.DeactivatedColor})

        for _,sound in pairs(musicStorage:GetChildren()) do
            sound.Volume = settingsData[button.Name] and MorphUIConfiguration.MusicVolume or 0
        end
    end
end

local function createSettings()
    for settingName, defaultOption in pairs(MorphUIConfiguration.Settings) do
        local newSlot = settingsFrame.UIListLayout.Template:Clone()
        newSlot.Name = settingName
        newSlot.Title.Text = settingName
        newSlot.BubbleFrame.Bubble.BackgroundColor3 = defaultOption and MorphUIConfiguration.ActivatedColor or MorphUIConfiguration.DeactivatedColor
        newSlot.BubbleFrame.Bubble.Position = defaultOption and MorphUIConfiguration.ActivatedPosition or MorphUIConfiguration.DeactivatedPosition
        newSlot.Parent = settingsFrame

        settingsData[settingName] = defaultOption
    end

    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsFrame.UIListLayout.AbsoluteContentSize.Y)
end

local function createCredits()
    for _, info in ipairs(MorphUIConfiguration.Credits) do
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
            continue
        elseif not image then
            continue
        else
            newSlot.Thumbnail.Image = image
        end

        newSlot.Parent = credits
    end

    credits.CanvasSize = UDim2.new(0, credits.UIListLayout.AbsoluteContentSize.X, 0, 0)
end

local function createMorphs()
    for groupName, morphList in pairs(MorphsConfiguration.Data) do
        local newGroup = morphSelection.UIListLayout.GroupTemplate:Clone()
        newGroup.Name = groupName
        newGroup.Title.Text = string.upper(groupName)
        newGroup.Parent = morphSelection

        for morphName, info in pairs(morphList) do
            local newMorphSlot = newGroup.Morphs.UIListLayout.MorphTemplate:Clone()
            newMorphSlot.Name = morphName
            newMorphSlot.Parent = newGroup.Morphs

            newMorphSlot.MorphName.Text = string.upper(morphName)

            local viewPortFrame = newMorphSlot.ViewportFrame
            local morphClone = info.Morph:Clone()
            morphClone.Parent = viewPortFrame

            local viewportCamera = Instance.new("Camera")
            viewportCamera.CameraType = Enum.CameraType.Attach
            viewportCamera.CameraSubject = morphClone.UpperTorso.Middle
            viewportCamera.Parent = viewPortFrame
            viewportCamera.CFrame = morphClone.UpperTorso.Middle.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, math.rad(180), 0)

            viewPortFrame.CurrentCamera = viewportCamera

            for groupId, groupRoles in pairs(info.Requirements) do
                -- create requirements
                local groupInfo = nil
                local status = retry(function()
                    groupInfo = GroupService:GetGroupInfoAsync(groupId)
                end)
    
                if status then
                    warn("Problem retreiving group info for group " .. groupId)
                    print(status)
                    continue
                elseif not groupInfo then
                    continue 
                end

                local newGroupSlot = newMorphSlot.Requirements.UIListLayout.GroupTemplate:Clone()
                newGroupSlot.Name = groupInfo.Name
                newGroupSlot.GroupName.Text = groupInfo.Name
                newGroupSlot.Parent = newMorphSlot.Requirements

                for i, groupRole in ipairs(groupRoles) do
                    local rankName = groupRole == "*"
                    for _, groupRoleInfo in ipairs(groupInfo.Roles) do
                        if groupRoleInfo.Rank == groupRole then
                            rankName = groupRoleInfo.Name
                            break
                        elseif groupRole == "*" and i == #groupRoles then
                            rankName = groupRoleInfo.Name .. "+"
                            break
                        end
                    end

                    if rankName then
                        local newRankSlot = newGroupSlot.UIListLayout.GroupRank:Clone()
                        newRankSlot.Text = rankName
                        newRankSlot.Parent = newGroupSlot
                    end
                end
            end
        end

        newGroup.Size = UDim2.new(0, newGroup.Morphs.UIListLayout.AbsoluteContentSize.X, 1, -20)
    end

    morphSelection.CanvasSize = UDim2.new(0, morphSelection.UIListLayout.AbsoluteContentSize.X, 0, 0)
end

local function __main__()
    UI.Enabled = true
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

    for _, element in ipairs(UI:GetDescendants()) do
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

    if not game:IsLoaded() then
        game.IsLoaded:Wait()
    end

    ContentProvider:PreloadAsync(UI:GetDescendants())

    loading.TextLabel.Text = "Loaded"
    wait(1)
    background.Visible = true
    loading.Visible = false

    playMusic()
end

__main__()