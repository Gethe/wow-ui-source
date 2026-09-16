local AddonName = ...;

function PartyPose_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function IslandsPartyPoseFrame_TryShow(mapID, winner)
	if IslandsPartyPose_LoadUI() then
		IslandsPartyPoseFrame:LoadScreen(mapID, winner);
		ShowUIPanel(IslandsPartyPoseFrame);
	end
end

function WarfrontsPartyPoseFrame_TryShow(mapID, winner)
	if WarfrontsPartyPose_LoadUI() then
		WarfrontsPartyPoseFrame:LoadScreen(mapID, winner);
		ShowUIPanel(WarfrontsPartyPoseFrame);
	end
end
