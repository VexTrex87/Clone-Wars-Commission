-- TO DO

local function makeBodyTransparent(character)
	for _, bodyPart in ipairs(character:GetChildren()) do
		if bodyPart:IsA("BasePart") then
			bodyPart.Transparency = 1
			if bodyPart:FindFirstChild("face") then
				bodyPart.face:remove()
			end
		end
	end
end

local function destroyAccessories(character)
	for _, accessory in ipairs(character:GetChildren()) do
		if accessory:IsA("Accessory") or accessory:IsA("Hat") then
			accessory:Destroy()
		end
	end
end

local function replaceBodyPart(character, bodyPart)
	-- bodyPart = bodyPart:Clone()
	bodyPart.Parent = character.Morph

	for _, subBodyPart in ipairs(bodyPart:GetChildren()) do
		if subBodyPart:IsA("BasePart") then
			local weld = Instance.new("Weld")
			weld.Part0 = bodyPart.Middle
			weld.Part1 = subBodyPart

			local CJ = CFrame.new(bodyPart.Middle.Position)
			weld.C0 = bodyPart.Middle.CFrame:inverse() * CJ
			weld.C1 = subBodyPart.CFrame:inverse() * CJ
			weld.Parent = bodyPart.Middle
		end

		local weld = Instance.new("Weld")
		weld.Part0 = character:FindFirstChild(bodyPart.Name)
		weld.Part1 = bodyPart.Middle
		weld.C0 = CFrame.new(0, 0, 0)
		weld.Parent = weld.Part0
	end

	for _, subBodyPart in ipairs(bodyPart:GetChildren()) do
		if subBodyPart:IsA("BasePart") then  
			subBodyPart.Anchored = false
			subBodyPart.CanCollide = false
		end
	end
end

local function morphCharacter(character, morph)
	morph = morph:Clone()

	local morphFolder = Instance.new("Folder")
	morphFolder.Name = "Morph"
	morphFolder.Parent = character

	for _, bodyPart in ipairs(morph:GetChildren()) do
		replaceBodyPart(character, bodyPart)
	end

	morph:Destroy()
end

local function setSize(character, depth, height, width)
	for _, scaleValue in ipairs(character.Humanoid:GetChildren()) do
		if scaleValue:IsA("NumberValue") then
			-- Looks for any changes made to the depth, height and width variables.
			if scaleValue.Name == "setSizeDepthScale" then
				scaleValue.Value = depth
			elseif scaleValue.Name == "setSizeHeightScale" then
				scaleValue.Value = height
			elseif scaleValue.Name == "setSizeWidthScale" then				
				scaleValue.Value = width
			end
		end
	end
end

return function(character, morph)
	setSize(character, 1, 1, 1)
	morphCharacter(character, morph)
	destroyAccessories(character)
	makeBodyTransparent(character)
end