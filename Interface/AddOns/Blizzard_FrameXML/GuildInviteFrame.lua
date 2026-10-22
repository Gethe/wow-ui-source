function GuildInviteFrame_OnEvent(self, event, ...)
	if ( event == "GUILD_INVITE_REQUEST" ) then
		local inviterName, guildName, guildPoints, oldGuildName, isNewGuild = ...;
		local tabardData = { select(6, ...) };
		
		GuildInviteFrame.inviter = inviterName;
		
		GuildInviteFrameInviterName:SetText(inviterName);
		GuildInviteFrameGuildName:SetText(guildName);

		if C_AchievementInfo.AreGuildAchievementsEnabled() then
			GuildInviteFrame.Points.Text:SetText(guildPoints);
		else
			GuildInviteFrame.Points:SetShown(false);
		end

		SetLargeGuildTabardTextures(nil, GuildInviteFrameTabardEmblem, GuildInviteFrameTabardBackground, GuildInviteFrameTabardBorder, tabardData);
		-- check if player has any guild rep beyond Neutral 0 if it's being invited to a new guild
		local guildFactionData = C_Reputation.GetGuildFactionData();
		if ( isNewGuild and guildFactionData and ( guildFactionData.reaction > 4 or guildFactionData.currentStanding > 0 ) ) then
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

		if InputUtil.IsGamepadUIEnabled() then
			GamepadMode.FrameControlsManager:HandlePopupShown(GuildInviteFrame);
		end
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

function GuildInviteFrame_OnLoad(self)
	self.hideOnEscape = true;
	self:RegisterEvent("GUILD_INVITE_REQUEST");
	self:RegisterEvent("GUILD_INVITE_CANCEL");

	GuildInviteFrame_RegisterForTransitions(self);
end

function GuildInviteFrame_OnHide(self)
	if ( not self.accepted ) then
		DeclineGuild();
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	StaticPopupSpecial_Hide(GuildInviteFrame);

	if InputUtil.IsGamepadUIEnabled() then
		GamepadMode.FrameControlsManager:HandlePopupHide(GuildInviteFrame);
	end
end

function GuildInviteFrame_OnUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed;
	if ( self.elapsed > 60 ) then
		self:Hide();
	end
end

function GuildInviteFrame_RegisterForTransitions(self)
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(GuildInviteFrame_SetupGamepad, self));
end

function GuildInviteFrame_SetupGamepad(self)
	self.useCustomNavigation = true;
	self.skipGamepadAutoFocus = true;
	self.binding = GamepadMode.CreateBindingGroup("GuildInviteBindings");
	self.binding:BlockEverything();
	self.binding:AddFunctionBinding(GAMEPAD_FACE_BOTTOM, function() GuildInviteFrameJoinButton:Click() end);
	self.binding:AddFunctionBinding(GAMEPAD_FACE_RIGHT, function() GuildInviteFrameDeclineButton:Click() end);

	self.joinIcon = GamepadMode.AddGamepadIconToButton(GuildInviteFrameJoinButton, GAMEPAD_FACE_BOTTOM);
	self.declineIcon = GamepadMode.AddGamepadIconToButton(GuildInviteFrameDeclineButton, GAMEPAD_FACE_RIGHT);

	GamepadMode.SetGamepadIconShown(self.joinIcon, false);
	GamepadMode.SetGamepadIconShown(self.declineIcon, false);

	self.FocusGamepad = function()
		GamepadMode.SetGamepadIconShown(self.joinIcon, true);
		GamepadMode.SetGamepadIconShown(self.declineIcon, true);
		GamepadMode.ActivateBindingGroup(self.binding);
	end

	self.UnfocusGamepad = function()
		GamepadMode.DeactivateBindingGroup(self.binding);
		GamepadMode.SetGamepadIconShown(self.joinIcon, false);
		GamepadMode.SetGamepadIconShown(self.declineIcon, false);
	end
end
