local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = ReplicatedStorage.Modules
local newTween = require(modules.NewTween)
local configuration = modules.Configuration
local MorphUIConfiguration = require(configuration.MorphUI)
local highlightElement = require(script.Parent.HighlightElement)

local musicStorage = ReplicatedStorage.Objects.Music

local localPlayer = Players.LocalPlayer
local UI = localPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local settingsFrame = background.Settings

local module = {}

function module.Create(info)
    for settingName, defaultOption in pairs(MorphUIConfiguration.Settings) do
        local newSlot = settingsFrame.UIListLayout.Template:Clone()
        newSlot.Name = settingName
        newSlot.Title.Text = settingName
        newSlot.BubbleFrame.Bubble.BackgroundColor3 = defaultOption and MorphUIConfiguration.ActivatedColor or MorphUIConfiguration.DeactivatedColor
        newSlot.BubbleFrame.Bubble.Position = defaultOption and MorphUIConfiguration.ActivatedPosition or MorphUIConfiguration.DeactivatedPosition
        newSlot.Parent = settingsFrame

        info.SettingsData[settingName] = defaultOption
    end

    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsFrame.UIListLayout.AbsoluteContentSize.Y)
end

function module.OnClick(info, button)
    info.SettingsData[button.Name] = not info.SettingsData[button.Name]
    newTween(button.BubbleFrame.Bubble, MorphUIConfiguration.SwitchTweenInfo, {Position = info.SettingsData[button.Name] and MorphUIConfiguration.ActivatedPosition or MorphUIConfiguration.DeactivatedPosition})
    newTween(button.BubbleFrame.Bubble, MorphUIConfiguration.SwitchTweenInfo, {BackgroundColor3 = info.SettingsData[button.Name] and MorphUIConfiguration.ActivatedColor or MorphUIConfiguration.DeactivatedColor})

    for _,sound in pairs(musicStorage:GetChildren()) do
        sound.Volume = info.SettingsData[button.Name] and MorphUIConfiguration.MusicVolume or 0
    end
end

function module.OnHover(element, isHovered)
    highlightElement(element, isHovered)
end

return module