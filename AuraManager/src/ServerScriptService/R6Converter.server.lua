local Players = game.Players

Players.CharacterAutoLoads = false

local function LoadCharacter(Player)
	local Main = game.Players:GetHumanoidDescriptionFromUserId(Player.CharacterAppearanceId)
	local morph =game.Players:CreateHumanoidModelFromDescription(Main,Enum.HumanoidRigType.R6)
	morph:MoveTo(workspace.SpawnLocation.Position)
	morph.Name = Player.Name
	Player.Character = morph
	morph.Parent = workspace
	local Humanoid = morph:FindFirstChildOfClass("Humanoid")
	Humanoid.Died:Connect(function()
		task.wait(Players.RespawnTime)
		LoadCharacter(Player)
	end)
	return morph
end

Players.PlayerAdded:Connect(function(Player)
	LoadCharacter(Player)
end)