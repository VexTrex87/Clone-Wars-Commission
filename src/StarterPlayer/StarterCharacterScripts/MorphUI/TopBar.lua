local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = ReplicatedStorage.Modules
local configuration = modules.Configuration
local MorphUIConfiguration = require(configuration.MorphUI)
local highlightElement = require(script.Parent.HighlightElement)

local morphPlayerRemote = ReplicatedStorage.Objects.Remotes.MorphPlayer
local localPlayer = Players.LocalPlayer
local UI = localPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local loading = UI.Loading
local topBar = background.TopBar

local module = {}

function module.OnClicked(info, button)
    if button.Name == "Play" then
        if info.SelectedMorph then
            loading.TextLabel.Text = "Loading character..."
            loading.Visible = true
            background.Visible = false
            morphPlayerRemote:InvokeServer(info.SelectedMorph)
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
                highlightElement(topBarButton, topBarButton == button)
            end
        end
    end
end

function module.OnHover(element, isHovered)
    -- highlight if hovered or if corresponding frame is visible
    highlightElement(element, isHovered or background:FindFirstChild(element.Name) and background[element.Name].Visible)
end

return module