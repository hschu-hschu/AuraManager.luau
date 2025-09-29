local Animator = script.Parent.Parent:WaitForChild("Humanoid"):WaitForChild("Animator") :: Animator

local function ResetPlayingTracks()
	for _, AnimationTrack: AnimationTrack in Animator:GetPlayingAnimationTracks() do
		AnimationTrack:Stop()
		AnimationTrack:Destroy()
	end
end

ResetPlayingTracks()
script.Parent:GetAttributeChangedSignal("Reboot"):Connect(ResetPlayingTracks)