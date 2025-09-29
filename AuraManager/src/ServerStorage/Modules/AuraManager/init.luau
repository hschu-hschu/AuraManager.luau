local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packets = ReplicatedStorage:WaitForChild("Packets")
local Assets = ServerStorage:WaitForChild("Assets")
local Tiers = Assets:WaitForChild("Tiers")

local Aura = require(script:WaitForChild("Aura"))
local AuraPacket = require(Packets:WaitForChild("Aura"))
local AuraDB = require(ServerStorage.Storage.RarityDB)
local Animate = StarterPlayer:WaitForChild("StarterCharacterScripts"):WaitForChild("Animate")

local module = {}

module.ConstraintPath = {
	--Model = {"PrimaryPart"},
	JointInstance = {"Part0","Part1"},
	WeldConstraint = {"Part0","Part1"},
	Beam = {"Attachment0","Attachment1"},
	Trail = {"Attachment0","Attachment1"},
	Wire = {"SourceInstance","TargetInstance"},
} :: {[string]:{string}}
module.AnimsOrigins = {}
module.AuraConstraintInstances = {}

local function SetCharacterHipHeight(Character:Model?,HipHeight:number)
	local RootPart = Character and Character:WaitForChild("HumanoidRootPart")
	if not RootPart then return end
	for _,v in RootPart:GetJoints() do
		if v:IsA('WeldConstraint') then continue end
		if v:HasTag("AuraInstance") then
			v.C0 += Vector3.new(0,HipHeight,0)
		elseif v.Name == "RootJoint" then
			v.C0 = CFrame.Angles(math.pi/2,-math.pi,0)+Vector3.new(0,HipHeight,0)
		end
	end
end

function module.EquipAura(Character: Model?, AuraName: string)
	if not Character then return end
	local AuraInfo = Tiers:FindFirstChild(AuraName)
	module.UnequipAura(Character)
	if not AuraName then return end
	AuraName = Tiers:FindFirstChild(AuraName) and AuraName
	local player = Players:GetPlayerFromCharacter(Character)
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	local AuraInstancePath = {} ::{[Instance]:Instance}
	local AuraInstances = {}
	
	local function SetupAuraBGM(Sound)
		Sound:Play()
	end
	
	local function SaveInstance(original,new)
		AuraInstancePath[original] = new
		table.insert(AuraInstances,new)
		new:AddTag("AuraInstance")
	end
	
	local function CloneInstance(original)
		local newAuraInstance = Instance.fromExisting(original)
		if newAuraInstance:IsA("Sound") and newAuraInstance:HasTag("AuraBGM") then
			SetupAuraBGM(newAuraInstance)
		end
		SaveInstance(original,newAuraInstance)
		return newAuraInstance
	end
	
	local function CloneChildren(parent:Instance,newParent:Instance?)
		for _,original in parent:GetChildren() do
			local new = CloneInstance(original)
			new.Parent = newParent
			CloneChildren(original,new)
		end
	end
	
	for i,auraInfoPart in AuraInfo:GetChildren() do
		local characterPart = Character:FindFirstChild(auraInfoPart.Name)
		if characterPart and auraInfoPart:IsA("BasePart") then
			SaveInstance(auraInfoPart,characterPart)
			CloneChildren(auraInfoPart,characterPart)
		end
	end
	
	for _, ConstraintInfo in module.AuraConstraintInstances[AuraName] do
		local original = ConstraintInfo.Instance
		local new = AuraInstancePath[original]
		for _, proputyName in module.ConstraintPath[ConstraintInfo.ClassName] do
			if not original[proputyName] and original.ClassName ~= "Model" then
				warn(`You didn't set the {proputyName} of {original:GetFullName()}`)
			end
			local successed, errorData = pcall(function()
				new[proputyName] = AuraInstancePath[original[proputyName]]
			end)
			if not successed then
				warn(errorData)
			end
		end
	end
	
	local Humanoid = Character:FindFirstChildOfClass("Humanoid") 
	if Humanoid then
		local Name, skinName = table.unpack(AuraName:split("_"))
		if AuraDB[Name] then
				local HipHeight = AuraDB[AuraName].HipHeight or 0
				SetCharacterHipHeight(Character,HipHeight)
		end
	end
	
	if player then
		player:SetAttribute("AuraName",AuraName)
		for _, Asset in Character:GetDescendants() do
			if Asset:IsA("Sound") and Asset:HasTag("AuraBGM") then
				Asset:SetAttribute("Volume", Asset.Volume)
				Asset:SetAttribute("Player", player.Name)
				Asset:AddTag("OthersAuraSounds")
			end
		end
	end
	
	SetAnimation(Character,AuraInfo)
	
	Aura.setup(Character,AuraName, AuraInstances)
end

function SetAnimation(Character:Model?, AuraInfo:Model)
	local Animations = AuraInfo:FindFirstChild("Animations")
	if not Character then return end
	local AnimationScript = Character:WaitForChild("Animate")
	if not AnimationScript then return end
	if Animations then
		for _,animation in Animations:GetChildren() do
			local characterAnimation = AnimationScript:FindFirstChild(animation.Name,true)
			if not characterAnimation then
				warn(`The aura {AuraInfo.Name} contains an invalid animation name: {animation.Name}. Please replace it.`)
				continue
			end
			characterAnimation.AnimationId = animation.AnimationId
		end
		Animate:SetAttribute("HasAnim", true)
	end
	AnimationScript:SetAttribute("Reboot", math.random())
end

function module.UnequipAura(Character:Model?)
	local AnimationScript = Character and Character:FindFirstChild("Animate")
	if AnimationScript then
		AnimationScript:SetAttribute("HasAnim", false)
		for _, Animation in ipairs(AnimationScript:GetDescendants()) do
			if Animation:IsA("Animation") then
				Animation.AnimationId = module.AnimsOrigins[Animation.Name]
			end
		end
		AnimationScript:SetAttribute("HasAnim", false)
		AnimationScript:SetAttribute("Reboot", math.random())
	end
	
	Aura.cleanup(Character)
	
	local Player = Players:GetPlayerFromCharacter(Character)

	if Player then
		Player:SetAttribute("AuraName",nil)
		
	end
	SetCharacterHipHeight(Character,0)
end

function module.GetAuraFromPlayer(player:Player)
	return Aura.GetAuraFromPlayer(player)
end

function module.GetAuraDataFromCharacter(character:Model)
	return Aura.GetAuraDataFromCharacter(character)
end

function InitAuraConstraintInstances()
	table.clear(module.AuraConstraintInstances)
	for _,v in Tiers:GetChildren() do
		local ConstraintInstances = FindConstraints(v)
		module.AuraConstraintInstances[v.Name] = ConstraintInstances
	end
end

function FindConstraints(parent:Instance)
	local ConstraintInstances = {} ::{{Instance:Instance,ClassName:string}}
	for _,original in parent:GetDescendants() do
		local find:string?
		for className, _ in module.ConstraintPath do
			if not original:IsA(className) then continue end
			find = className
		end
		if find then
			table.insert(ConstraintInstances,{Instance=original,ClassName=find})
		end
	end
	
	return ConstraintInstances
end

InitAuraConstraintInstances()

for _, Animation in ipairs(Animate:GetDescendants()) do
	if Animation:IsA("Animation") then
		module.AnimsOrigins[Animation.Name] = Animation.AnimationId
	end
end

return module