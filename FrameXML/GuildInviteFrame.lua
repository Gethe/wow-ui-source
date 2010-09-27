function GuildInviteFrame_OnEvent(self, event, ...)
	if ( event == "GUILD_INVITE_REQUEST" ) then
		local inviter = select(1, ...);
		local guildName = select(2, ...);
		local guildLevel = select(3, ...);
		local oldGuildName = select(4, ...);
		local emblem = { select(5, ...) };

		GuildInviteFrameInviteText:SetFormattedText(GUILD_INVITATION, inviter);
		GuildInviteFrameGuildName:SetText(guildName);
		GuildInviteFrameLevelNumber:SetText(guildLevel);
		SetLargeGuildTabardTextures(nil, GuildInviteFrameTabardEmblem, GuildInviteFrameTabardBackground, GuildInviteFrameTabardBorder, emblem);
		-- check if player has any guild rep beyond Neutral 0
		local name, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
		if ( standingID > 4 or barValue > 0 ) then
			-- display the old guild name if we have one, otherwise use generic message
			if ( oldGuildName and oldGuildName ~= "" ) then
				GuildInviteFrameWarningText:SetFormattedText(GUILD_REPUTATION_WARNING, oldGuildName);
			else
				GuildInviteFrameWarningText:SetText(GUILD_REPUTATION_WARNING_GENERIC);
			end
			GuildInviteFrame:SetHeight(220);
		else
			GuildInviteFrameWarningText:SetText("");
			GuildInviteFrame:SetHeight(188);
		end
		GuildInviteFrame.accepted = nil;
		GuildInviteFrame.elapsed = 0;

		if ( GetGuildLevelEnabled() ) then
			GuildInviteFrameLevel:Show();
		else
			GuildInviteFrameLevel:Hide();
		end

		StaticPopupSpecial_Show(GuildInviteFrame);
	elseif ( event == "GUILD_INVITE_CANCEL" ) then
		self:Hide();
	end
end