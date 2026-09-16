local AddonName = ...;

function ChallengeMode_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ChallengeModeCompleteBanner_OnChallengeModeCompleted(event, ...)
	if ChallengeMode_LoadUI() then
		ChallengeModeCompleteBanner:OnEvent(event, ...);
	end
end

function ShowChallengesKeystoneFrame()
	if ChallengeMode_LoadUI() then
		ChallengesKeystoneFrame:ShowKeystoneFrame();
	end
end
