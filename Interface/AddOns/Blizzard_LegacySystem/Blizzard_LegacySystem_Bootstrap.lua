local AddonName = ...;

function LegacySystemFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleLegacySystemUI()
	if (C_MajorFactions.GetCurrentRenownLevel(Constants.LegacyConsts.LEGACY_REWARD_TRACK_FACTION_ID) <= 0) then
		return;
	end

	if not LegacySystemFrame then
		if not LegacySystemFrame_LoadUI() then
			return;
		end
	end

	if LegacySystemFrame then
		ToggleFrame(LegacySystemFrame);
	end
end
