local AddonName = ...;

function PartyPose_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function IslandsPartyPoseFrame_TryShow(mapID, winner)
	if PartyPose_LoadUI() then
		IslandsPartyPoseFrame:LoadScreenData(mapID, winner);
		ShowUIPanel(IslandsPartyPoseFrame);
	end
end

function WarfrontsPartyPoseFrame_TryShow(mapID, winner)
	if PartyPose_LoadUI() then
		WarfrontsPartyPoseFrame:LoadScreenData(mapID, winner);
		ShowUIPanel(WarfrontsPartyPoseFrame);
	end
end
