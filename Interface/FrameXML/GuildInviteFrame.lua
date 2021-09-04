function GuildInviteFrame_OnEvent(self, event, ...)
	if ( event == "GUILD_INVITE_REQUEST" ) then
		local inviterName, guildName, guildPoints, oldGuildName, isNewGuild = ...;
		local tabardData = { select(6, ...) };
		
		GuildInviteFrame.inviter = inviterName;
		
		GuildInviteFrameInviterName:SetText(inviterName);
		GuildInviteFrameGuildName:SetText(guildName);
		GuildInviteFrame.Points.Text:SetText(guildPoints);
		SetLargeGuildTabardTextures(nil, GuildInviteFrameTabardEmblem, GuildInviteFrameTabardBackground, GuildInviteFrameTabardBorder, tabardData);
		-- check if player has any guild rep beyond Neutral 0 if it's being invited to a new guild
		local name, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo();
		if ( isNewGuild and ( standingID > 4 or barValue > 0 ) ) then
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

		StaticPopupSpecial_Show(GuildInviteFrame);
	elseif ( event == "GUILD_INVITE_CANCEL" ) then
		self:Hide();
	end
end

function GuildInviteFrame_OnEnter()
	if ( GuildInviteFrameInviterName:IsTruncated() ) then
		GameTooltip:SetOwner(GuildInviteFrame, "ANCHOR_CURSOR_RIGHT");
		GameTooltip:SetText(GuildInviteFrame.inviter, 1, 1, 1, 1, true);
	end
end

function GuildInviteFrame_OnLeave()
	GameTooltip:Hide();
end