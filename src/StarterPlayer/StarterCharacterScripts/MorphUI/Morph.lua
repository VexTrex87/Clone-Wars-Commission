local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")

local modules = ReplicatedStorage.Modules
local Morph = require(modules.Morph)
local retry = require(modules.Retry)
local configuration = modules.Configuration
local MorphsConfiguration = require(configuration.Morphs)
local MorphUIConfiguration = require(configuration.MorphUI)
local highlightElement = require(script.Parent.HighlightElement)

local localPlayer = Players.LocalPlayer
local UI = localPlayer.PlayerGui:WaitForChild("MorphUI")
local background = UI.Background
local morphSelection = background.MorphSelection

local module = {}

function module.Create()
    for groupName, morphList in pairs(MorphsConfiguration) do
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

                for roleIndex, groupRole in ipairs(groupRoles) do
                    local rankName = groupRole == "*"
                    for _, groupRoleInfo in ipairs(groupInfo.Roles) do
                        if groupRoleInfo.Rank == groupRole then
                            rankName = groupRoleInfo.Name
                            break
                        elseif groupRole == "*" and roleIndex == #groupRoles then
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

function module.OnClick(info, button)
    if button.Parent.Name == "Morphs" then
        local morphInfo = MorphsConfiguration[button.Parent.Parent.Name] and MorphsConfiguration[button.Parent.Parent.Name][button.Name]
        if morphInfo then
            local meetsRequirement = Morph.CheckIfPlayerMeetsRequirement(morphInfo.Requirements, info.GroupRanks)
            if meetsRequirement then
                info.SelectedMorph = button.Name

                -- highlight pressed morph & highlight others
                for _, morphButton in ipairs(morphSelection:GetDescendants()) do
                    if morphButton:IsA("ImageButton") and morphButton.Parent.Name == "Morphs" then
                        highlightElement(morphButton, morphButton == button)
                    end
                end
    
                -- highlight group of pressed morph, unhighlight others
                for _, morphGroupFrame in ipairs(morphSelection:GetChildren()) do
                    if morphGroupFrame:IsA("Frame") then
                        highlightElement(morphGroupFrame.Title, info.SelectedMorph and morphGroupFrame:FindFirstChild(info.SelectedMorph, true))
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
end

function module.OnHover(info, element, isHovered)
    if element:IsA("ImageButton") and element.Parent.Name == "Morphs" then
        local morphInfo = MorphsConfiguration[element.Parent.Parent.Name] and MorphsConfiguration[element.Parent.Parent.Name][element.Name]
        if morphInfo then
            local meetsRequirement = Morph.CheckIfPlayerMeetsRequirement(morphInfo.Requirements, info.GroupRanks)
            if meetsRequirement then
                highlightElement(element, isHovered or element.Name == info.SelectedMorph)
            elseif #element.Requirements:GetChildren() > 2 then
                element.ViewportFrame.Visible = not isHovered
                element.Requirements.Visible = isHovered
            end
        end
    elseif element:IsA("Frame") and element.Parent == morphSelection then
        -- highlight if hovered or if group has selected morph
        highlightElement(element, isHovered or info.SelectedMorph and element:FindFirstChild(info.SelectedMorph, true))
    end
end

return module