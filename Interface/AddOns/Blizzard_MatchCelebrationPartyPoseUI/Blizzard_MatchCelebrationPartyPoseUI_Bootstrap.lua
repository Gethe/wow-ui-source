local AddonName = ...;

function MatchCelebrationPartyPose_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowMatchCelebrationPartyPoseFrame(partyPoseID, won)
	if MatchCelebrationPartyPose_LoadUI() then
		MatchCelebrationPartyPoseFrame:LoadScreenByPartyPoseID(partyPoseID, won);
		ShowUIPanel(MatchCelebrationPartyPoseFrame);
	end
end
