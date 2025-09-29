--!nocheck
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packets = ReplicatedStorage:WaitForChild("Packets")
local AuraPacket
if RunService:IsRunning() then
	AuraPacket = require(Packets:WaitForChild("Aura"))
end

local Assets = ReplicatedStorage.Assets
local AuraScripts = Assets.AuraScripts

local module = {}
module.auraScripts = {}
module.Auras = {}

function module.setup(character: Model, AuraName, AuraInstances)
	local auraServer = module.auraScripts.Server[AuraName]
	local auraServerModule = table.clone(require(auraServer or script.Server.Defualt))
	
	if not AuraScripts:FindFirstChild(AuraName) then
		local auraClient = module.auraScripts.Client[AuraName] and module.auraScripts.Client[AuraName]:Clone()

		if auraClient then
			auraClient.Parent = AuraScripts
		end
	end
	
	local IsDummy = character:FindFirstAncestor("Miscs")
	
	if AuraPacket then
		if IsDummy then
			local Player = Players:FindFirstChild(character.Parent.Name)
			AuraPacket.Equipped.sendTo({Name=AuraName, Character=character},Player)
		else
			AuraPacket.Equipped.sendToAll({Name=AuraName, Character=character})
		end
	end

	module.Auras[character] = auraServerModule
	auraServerModule.Name = AuraName
	auraServerModule.Character = character
	auraServerModule.AuraInstances = AuraInstances
	auraServerModule.ModuleScript = auraServer

	if auraServerModule.equip then
		auraServerModule.equip(character)
	end
	
	auraServerModule.setup(character)
	auraServerModule.LoopEvent = RunService.Heartbeat:Connect(function(deltaTime)
		if not (auraServerModule.Character and module.Auras[auraServerModule.Character]) then
			auraServerModule.LoopEvent:Disconnect()
			return
		end
		module.loop(character, deltaTime)
		auraServerModule.loop(deltaTime)
	end)
end

function module.loop(character, deltaTime: number)
	
end

function module.cleanup(Character: Model?)
	local Aura = module.Auras[Character]
	if not (Character and Aura) then return end
	Aura.LoopEvent:Disconnect()
	Aura.cleanup(Character)

	for _, v: Instance in Aura.AuraInstances do
		if not (v and v:FindFirstAncestorOfClass("Workspace")) then continue end
		if v.Parent == Character then continue end
		v:Destroy()
	end

	if AuraPacket then
		AuraPacket.Unequipped.sendToAll({Name=Aura.Name, Character=Character})
	end
	module.Auras[Character] = nil
end

function module.GetAuraFromPlayer(player: Player): string?
	return module.Auras[player.Character] and module.Auras[player.Character].Name
end

function module.GetAuraFromCharacter(character: Model): string?
	return module.Auras[character] and module.Auras[character].Name
end

function module.GetAuraDataFromCharacter(character: Model)
	return module.Auras[character]
end

function module.FindFirstAura(AuraName)
	for _,aura in module.Auras do
		if aura.Name == AuraName then
			return aura
		end
	end
end

function SaveAuraModules()
	module.auraScripts = {Server = {}, Client = {}}
	for _, auraScript in script.Server:GetChildren() do
		module.auraScripts.Server[auraScript.Name] = auraScript
	end
	for _, auraScript in script.Client:GetChildren() do
		module.auraScripts.Client[auraScript.Name] = auraScript
	end
end

SaveAuraModules()

return module