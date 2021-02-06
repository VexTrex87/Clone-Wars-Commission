local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local modules = ReplicatedStorage.Modules
local MorphUIConfiguration = require(modules.Configuration.MorphUI)
local Morph = require(modules.Morph)
local highlightElement = require(script:WaitForChild("HighlightElement"))
local TopBarHandler = require(script:WaitForChild("TopBar"))
local MorphHandler = require(script:WaitForChild("Morph"))
local CreditsHandler = require(script:WaitForChild("Credits"))
local SettingsHandler = require(script:WaitForChild("Settings"))

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

local info = {
    SelectedMorph = nil,
    SettingsData = {},
    GroupRanks = {}
}

local function playMusic()
    while true do
        for _,sound in ipairs(musicStorage:GetChildren()) do
            sound.Volume = info.SettingsData.Music and MorphUIConfiguration.MusicVolume or 0
            sound:Play()
            sound.Stopped:Wait()
            wait(math.random(MorphUIConfiguration.MinMusicDelay, MorphUIConfiguration.MaxMusicDelay))
        end
    end
end

local function onMouseHover(element, isHovered)
    if element:IsA("TextButton") and element.Parent == topBar then
        TopBarHandler.OnHover(element, isHovered)    
    elseif element:IsDescendantOf(morphSelection) then
        MorphHandler.OnHover(info, element, isHovered)
    elseif element:IsA("Frame") and element.Parent == credits then
        CreditsHandler.OnHover(element, isHovered)
    elseif element:IsA("ImageButton") and element.Parent == settingsFrame then
        SettingsHandler.OnHover(element, isHovered)
    end
end

local function onButtonClicked(button)
    clickSound:Play()
    if button:IsDescendantOf(topBar) then
        TopBarHandler.OnClicked(info, button)
    elseif button:IsDescendantOf(morphSelection) then
        MorphHandler.OnClick(info, button)
    elseif button:IsDescendantOf(settingsFrame) then
        SettingsHandler.OnClick(info, button)
    end
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

    info.GroupRanks = Morph.GetPlayerRanks(localPlayer)

    highlightElement(topBar.MorphSelection, true)
    MorphHandler.Create()
    CreditsHandler.Create()
    SettingsHandler.Create(info)

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
        repeat
            wait(1)
        until game:IsLoaded()
    end

    ContentProvider:PreloadAsync(UI:GetDescendants())

    loading.TextLabel.Text = "Loaded"
    wait(1)
    background.Visible = true
    loading.Visible = false

    playMusic()
end

__main__()