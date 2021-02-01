--[[

> Welds sub body parts to body parts

local Selection = game:GetService("Selection")
local morph = Selection:Get()[1]

for _,v in pairs(morph:GetChildren()) do
    for __, x in pairs(v:getChildren()) do
        if x.Name ~= "Middle" then
            local weld = Instance.new("Weld")
            weld.Part0 = v.Middle
            weld.Part1 = x
            weld.Parent = v.Middle
        end
    end
end

]]

local Players = game:GetService('Players')
local visible = false
local recol = ''

function morph(plr, part, location, model, test)
	if plr ~= nil then
		if test == 'Morph' then
			if plr:FindFirstChild('Morph') == nil then
				local Folder = Instance.new('Folder')
				Folder.Name = 'Morph'
				Folder.Parent = plr
			end
		elseif test == 'Coat' then -- The "Coat" and "Pauld" statements can be completely ignored or removed without harming the script.
			if plr:FindFirstChild('Coat') == nil then
				local Folder = Instance.new('Folder')
				Folder.Name = 'Coat'
				Folder.Parent = plr
			end
		elseif test == 'Add' then
			if plr:FindFirstChild('Add') == nil then
				local Folder = Instance.new('Folder')
				Folder.Name = 'Add'
				Folder.Parent = plr
			end
		elseif test == 'Pauld' then
			if plr:FindFirstChild('Pauld') == nil then
				local Folder = Instance.new('Folder')
				Folder.Name = 'Pauld'
				Folder.Parent = plr
			end
		end
		local Folder = (test == 'Morph' and plr:FindFirstChild('Morph')
			 or test == 'Coat' and plr:FindFirstChild('Coat')
			 or test == 'Add' and plr:FindFirstChild('Add')
			 or test == 'Pauld' and plr:FindFirstChild('Pauld'))
		if Folder:FindFirstChild(model) == nil then
			local g = location[model]:Clone()
			g.Parent = Folder
			for i, v in ipairs(g:GetChildren()) do
				if v:IsA("BasePart") then
					local W = Instance.new("Weld")
					W.Part0 = g.Middle
					W.Part1 = v
					local CJ = CFrame.new(g.Middle.Position)
					local C0 = g.Middle.CFrame:inverse() * CJ
					local C1 = v.CFrame:inverse() * CJ
					W.C0 = C0
					W.C1 = C1
					W.Parent = g.Middle
				end
				local Y = Instance.new("Weld")
				Y.Part0 = plr:FindFirstChild(part)
				Y.Part1 = g.Middle
				Y.C0 = CFrame.new(0, 0, 0)
				Y.Parent = Y.Part0
			end
			local h = g:GetChildren()
			for i = 1, # h do
				if h[i].className == "Part" or  h[i].className == "UnionOperation" or  h[i].className == "MeshPart" or  h[i].className == "WedgePart" then  
					h[i].Anchored = false
					h[i].CanCollide = false
				end
			end
		end
	end
end
local function RunThings(char,Model, test)
	pcall(function()
		if Model:findFirstChild("Head") then
			morph(char, 'Head', Model, "Head",test)
			
		end
		if Model:findFirstChild("UpperTorso") then -- Looks for the body part models placed inside of the named folder you made.
			morph(char, 'UpperTorso', Model, "UpperTorso",test)
		end
		if Model:findFirstChild("LowerTorso") then
			morph(char, 'LowerTorso', Model, "LowerTorso",test)
		end
		if Model:findFirstChild("LeftUpperArm") then
			morph(char, 'LeftUpperArm', Model, "LeftUpperArm",test)
		end
		if Model:findFirstChild("RightUpperArm") then
			morph(char, 'RightUpperArm', Model, "RightUpperArm",test)
		end
		if Model:findFirstChild("LeftLowerArm") then
			morph(char, 'LeftLowerArm', Model, "LeftLowerArm",test)
		end
		if Model:findFirstChild("RightLowerArm") then
			morph(char, 'RightLowerArm', Model, "RightLowerArm",test)
		end
		if Model:findFirstChild("LeftHand") then
			morph(char, 'LeftHand', Model, "LeftHand",test)
		end
		if Model:findFirstChild("RightHand") then
			morph(char, 'RightHand', Model, "RightHand",test)
		end
		if Model:findFirstChild("LeftUpperLeg") then
			morph(char, 'LeftUpperLeg', Model, "LeftUpperLeg",test)
		end
		if Model:findFirstChild("RightUpperLeg") then
			morph(char, 'RightUpperLeg', Model, "RightUpperLeg",test)
		end
		if Model:findFirstChild("LeftLowerLeg") then
			morph(char, 'LeftLowerLeg', Model, "LeftLowerLeg",test)
		end
		if Model:findFirstChild("RightLowerLeg") then
			morph(char, 'RightLowerLeg', Model, "RightLowerLeg",test)
		end
		if Model:findFirstChild("LeftFoot") then
			morph(char, 'LeftFoot', Model, "LeftFoot",test)
		end
		if Model:findFirstChild("RightFoot") then
			morph(char, 'RightFoot', Model, "RightFoot",test)
		end
	end)
end

local function MorphUser(character, morph)
	local Model = morph:Clone()
	RunThings(character,Model,"Morph")
end
local function Body(depth,height,width,Char)
	for _,v in pairs(Char.Humanoid:GetChildren()) do
		if v.ClassName == 'NumberValue' then
			if v.Name == 'BodyDepthScale' then -- Looks for any changes made to the depth, height and width variables.
				v.Value = depth
			elseif v.Name == 'BodyHeightScale' then
				v.Value = height
			elseif v.Name == 'BodyWidthScale' then					
				v.Value = width
			end
		end
	end
end
local function Finale(Char)
	for i,v in pairs(Char:GetChildren()) do
		if v:IsA('Accessory') or v:IsA('Hat') then
			v:Destroy()
		end
	end
end
local function Finale0(Char)
	for i,v in pairs(Char:GetChildren()) do
		if v.ClassName == 'MeshPart' or v.ClassName == 'n/a' then
			v.Transparency = 1
			if v:FindFirstChild('n/a') then
			    v.face:remove()
			end
		end
	end
end
local function Finale1(Char)
	for i,v in pairs(Char:GetChildren()) do
		if v.ClassName == 'MeshPart' or v.ClassName == 'Part' then
			v.Transparency = 1
			if v:FindFirstChild('face') then
			    v.face:remove()
			end
		end
	end
end
local function Finale2(Char)
	for i,v in pairs(Char:GetChildren()) do
		if v.ClassName == 'MeshPart' or v.ClassName == 'Part' and v.Name ~= 'Head' or v.Name ~= 'LeftHand' or v.Name ~= 'RightHand' then
			v.Transparency = 1
		end
	end
end
local function Head(head,Char)
    for _,v in pairs(Char.Humanoid:GetChildren()) do
        if v.ClassName == 'NumberValue' then
            if v.Name == 'HeadScale' then
                v.Value = head
            end
        end
    end
end

return function(character, morph)
	wait(2)
	visible = false

	Body(1,1,1,character)
	MorphUser(character,morph)
	Finale(character)
	Finale1(character)
end