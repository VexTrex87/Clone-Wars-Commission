local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = ReplicatedStorage.Modules
local configuration = modules.Configuration
local MorphUIConfiguration = require(configuration.MorphUI)

local localPlayer = Players.LocalPlayer
local UI = localPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local morphSelection = background.MorphSelection

return function(element, isHovered)
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