local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = ReplicatedStorage.Modules
local retry = require(modules.Retry)
local configuration = modules.Configuration
local MorphUIConfiguration = require(configuration.MorphUI)
local highlightElement = require(script.Parent.HighlightElement)

local localPlayer = Players.LocalPlayer
local UI = localPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local credits = background.Credits

local module = {}

function module.Create()
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

function module.OnHover(element, isHovered)
    highlightElement(element, isHovered)
    element.Thumbnail.Visible = not isHovered
    element.Contact.Visible = isHovered
end

return module