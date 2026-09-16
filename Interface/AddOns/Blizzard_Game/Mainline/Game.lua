function ToggleGuildFrame()
	if DISALLOW_FRAME_TOGGLING then
		return;
	end

	local factionGroup = UnitFactionGroup("player");
	if factionGroup == "Neutral" then
		return;
	end

	if IsCommunitiesUIDisabledByTrialAccount() then
		UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
		return;
	elseif C_Club.IsEnabled() then
		if not BNConnected() then
			UIErrorsFrame:AddMessage(ERR_GUILD_AND_COMMUNITIES_UNAVAILABLE, 1.0, 0.1, 0.1, 1.0);
			return;
		elseif C_Club.IsRestricted() ~= Enum.ClubRestrictionReason.None then
			return;
		end

		ToggleCommunitiesFrame();
	else
		ToggleGuildFinder();
	end
end

RegisterGameMenuEscHandler(GameMenuEscPriority.World, function()
	return not C_SpectatingUI.IsSpectating() and ClearTarget() and not UnitIsCharmed("player");
end);
