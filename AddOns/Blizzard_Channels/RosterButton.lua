RosterToggleButtonMixin = CreateFromMixins(VoiceToggleButtonMixin);

function RosterToggleButtonMixin:IsLocalPlayer()
	return self:GetParent():IsLocalPlayer();
end

function RosterToggleButtonMixin:GetVoiceMemberID()
	return self:GetParent():GetVoiceMemberID();
end

function RosterToggleButtonMixin:GetVoiceChannelID()
	return self:GetParent():GetVoiceChannelID();
end

function RosterToggleButtonMixin:GetMemberPlayerLocation()
	return self:GetParent():GetMemberPlayerLocation();
end

function RosterToggleButtonMixin:ShouldShowVoiceActiveOnly()
	return self:GetParent():IsChannelActive() and self:GetParent():IsVoiceActive();
end

function RosterToggleButtonMixin:ShouldShow()
	return self:ShouldShowVoiceActiveOnly() and self:GetVoiceMemberID() ~= nil and self:GetVoiceChannelID() ~= nil;
end

function RosterToggleButtonMixin:ShouldShowLocalPlayerOnly()
	return self:ShouldShow() and self:IsLocalPlayer();
end

function RosterToggleButtonMixin:ShouldShowRemotePlayerOnly()
	return self:ShouldShow() and not self:IsLocalPlayer();
end

RosterSelfDeafenButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterSelfDeafenButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	self:SetVisibilityQueryFunction(self.ShouldShowLocalPlayerOnly);
	self:SetAccessorFunction(C_VoiceChat.IsDeafened);
	self:SetMutatorFunction(C_VoiceChat.SetDeafened);

	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:SetUseIconAsHighlight(true);

	self:AddStateTooltipString(false, VOICE_TOOLTIP_DEAFEN);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNDEAFEN);

	self:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
	self:UpdateVisibleState();
end

function RosterSelfDeafenButtonMixin:IsDeafened()
	return self:IsLocalPlayer() and C_VoiceChat.IsDeafened();
end

RosterSelfMuteButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterSelfMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	self:SetVisibilityQueryFunction(self.ShouldShowLocalPlayerOnly);
	self:SetAccessorFunctionThroughSelf(self.IsMuted);
	self:SetMutatorFunction(C_VoiceChat.SetMuted);

	self:AddStateAtlas(true, "voicechat-icon-mic-mute");
	self:AddStateAtlas(false, "voicechat-icon-mic");
	self:SetUseIconAsHighlight(true);

	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNMUTE_MIC);
	self:AddStateTooltipString(false, VOICE_TOOLTIP_MUTE_MIC);

	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:UpdateVisibleState();
end

function RosterSelfMuteButtonMixin:IsMuted()
	return self:IsLocalPlayer() and C_VoiceChat.IsMuted();
end

RosterMemberMuteButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterMemberMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	self:SetVisibilityQueryFunction(self.ShouldShowRemotePlayerOnly);
	self:SetAccessorFunctionThroughSelf(self.IsMuted);
	self:SetMutatorFunctionThroughSelf(self.SetMuted);

	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:SetUseIconAsHighlight(true);

	self:AddStateTooltipString(true, UNMUTE);
	self:AddStateTooltipString(false, MUTE);

	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
	self:UpdateVisibleState();
end

function RosterMemberMuteButtonMixin:IsMuted()
	return C_VoiceChat.IsMemberMuted(self:GetMemberPlayerLocation());
end

function RosterMemberMuteButtonMixin:SetMuted(mute)
	return C_VoiceChat.SetMemberMuted(self:GetMemberPlayerLocation(), mute);
end

ChannelRosterButtonMixin = {};

function ChannelRosterButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function ChannelRosterButtonMixin:GetRoster()
	return self:GetParent():GetParent():GetParent();
end

function ChannelRosterButtonMixin:IsChannelActive()
	local channel = self:GetRoster():GetChannelFrame():GetList():GetSelectedChannelButton();
	return channel and channel:IsVoiceActive()
end

function ChannelRosterButtonMixin:GetMemberPlayerLocation()
	return self.playerLocation;
end

function ChannelRosterButtonMixin:SetMemberPlayerLocationFromGuid(memberGuid)
	if memberGuid then
		if not self.playerLocation then
			self.playerLocation = PlayerLocation:CreateFromGUID(memberGuid);
		else
			self.playerLocation:SetGUID(memberGuid);
		end
	else
		self.playerLocation = nil
	end
end

function ChannelRosterButtonMixin:GetMemberID()
	return self.memberID;
end

function ChannelRosterButtonMixin:SetMemberID(memberID)
	self.memberID = memberID;
end

function ChannelRosterButtonMixin:GetVoiceMemberID()
	return self.voiceMemberID;
end

function ChannelRosterButtonMixin:SetVoiceMemberID(memberID)
	self.voiceMemberID = memberID;
end

function ChannelRosterButtonMixin:GetVoiceChannelID()
	return self.voiceChannelID;
end

function ChannelRosterButtonMixin:SetVoiceChannelID(channelID)
	self.voiceChannelID = channelID;
end

function ChannelRosterButtonMixin:IsLocalPlayer()
	local voiceMemberID = self:GetVoiceMemberID();
	local voiceChannelID = self:GetVoiceChannelID();

	if voiceMemberID and voiceChannelID then
		return C_VoiceChat.IsMemberLocalPlayer(voiceMemberID, voiceChannelID);
	end

	-- Text-only channels don't support a way to know if the user is the local player,
	-- but that can be added if necessary.
end

function ChannelRosterButtonMixin:GetMemberName()
	return self.memberName;
end

function ChannelRosterButtonMixin:SetMemberName(memberName)
	self.memberName = memberName;
end

function ChannelRosterButtonMixin:SetMemberIsOwner(isOwner)
	self.isOwner = isOwner;
end

function ChannelRosterButtonMixin:IsMemberOwner()
	return self.isOwner;
end

function ChannelRosterButtonMixin:SetMemberIsModerator(isModerator)
	self.isModerator = isModerator;
end

function ChannelRosterButtonMixin:IsMemberModerator()
	return self.isModerator;
end

function ChannelRosterButtonMixin:IsMemberLeadership()
	return self:IsMemberOwner() or self:IsMemberModerator();
end

function ChannelRosterButtonMixin:SetVoiceEnabled(voiceEnabled)
	self.voiceEnabled = voiceEnabled;
end

function ChannelRosterButtonMixin:IsVoiceEnabled()
	return self.voiceEnabled;
end

function ChannelRosterButtonMixin:SetVoiceActive(voiceActive)
	self.voiceActive = voiceActive;
end

function ChannelRosterButtonMixin:IsVoiceActive()
	return self.voiceActive;
end

function ChannelRosterButtonMixin:ShouldShowTalkingIndicator()
	return self:IsVoiceTalking(); -- TODO: Use energy as well?
end

function ChannelRosterButtonMixin:SetVoiceMuted(muted)
	self.voiceMuted = muted;
end

function ChannelRosterButtonMixin:IsVoiceMuted()
	return self.voiceMuted;
end

function ChannelRosterButtonMixin:SetIsConnected(isConnected)
	self.isConnected = isConnected;
end

function ChannelRosterButtonMixin:IsConnected()
	return self.isConnected;
end

local function ChannelRosterDropdown_Initialize(dropdown, level, menuList)
	UnitPopup_ShowMenu(dropdown, "CHAT_ROSTER", nil, dropdown.name, { guid = dropdown.guid });
end

function ChannelRosterButtonMixin:OnClick(button)
	if button == "RightButton" then
		HideDropDownMenu(1);

		local channel = ChannelFrame:GetList():GetSelectedChannelButton();
		if not channel then
			return;
		end

		local channelName, isHeader, isCollapsed, channelNumber, count, active, category, channelType = GetChannelDisplayInfo(channel:GetChannelID());
		local name, owner, moderator, guid = C_ChatInfo.GetChannelRosterInfo(channel:GetChannelID(), self:GetMemberID());

		local dropdown = self:GetRoster():GetChannelFrame():GetDropdown();
		UIDropDownMenu_SetInitializeFunction(dropdown, ChannelRosterDropdown_Initialize);
		dropdown.displayMode = "MENU";
		dropdown.name = name;
		dropdown.owner = owner;
		dropdown.moderator = moderator;
		dropdown.channelName = channelName;
		dropdown.category = category;
		dropdown.channelType = channelType;
		dropdown.guid = guid;
		dropdown.voiceChannelID = channel:GetVoiceChannelID();
		dropdown.voiceMemberID = C_VoiceChat.GetMemberID(dropdown.voiceChannelID, guid);

		ToggleDropDownMenu(1, nil, dropdown, "cursor");
	end
end

function ChannelRosterButtonMixin:OnEnter()
	if self.Name:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local memberName = self:GetMemberName() or VOICE_CHAT_AWAITING_MEMBER_NAME;
		GameTooltip:SetText(memberName, HIGHLIGHT_FONT_COLOR:GetRGB());
		GameTooltip:Show();
	end
end

function ChannelRosterButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function ChannelRosterButtonMixin:Update()
	self:UpdateName();

	local showRank = self:IsMemberLeadership();
	self.Rank:SetShown(showRank);

	if showRank then
		local nameOffset = self.Name:GetLeft() - self:GetLeft();
		local rankOffset = self.Name:GetStringWidth() + nameOffset + 2; -- add some padding after the name
		self.Rank:SetPoint("LEFT", self, "LEFT", rankOffset, 0);
	end

	if self:IsMemberOwner() then
		self.Rank:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
	elseif self:IsMemberModerator() then
		self.Rank:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
	end

	self.SelfDeafenButton:UpdateVisibleState();
	self.SelfMuteButton:UpdateVisibleState();
	self.MemberMuteButton:UpdateVisibleState();

	self:UpdateVoiceActivityNotification();

	self:Show();
end

do
	function ChannelRosterButton_VoiceActivityNotificationCreatedCallback(self, notification)
		notification:SetParent(self);
		notification:ClearAllPoints();
		notification:SetPoint("RIGHT", self, "RIGHT", 0, 0);
		notification:Show();
	end

	function ChannelRosterButtonMixin:UpdateVoiceActivityNotification()
		if self:IsVoiceEnabled() then
			local guid = self.playerLocation and self.playerLocation:GetGUID();
			if guid ~= self.registeredGuid then
				if self.registeredGuid then
					VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
				end

				if guid then
					VoiceActivityManager:RegisterFrameForVoiceActivityNotifications(self, guid, self:GetVoiceChannelID(), "VoiceActivityNotificationRosterTemplate", "Button", ChannelRosterButton_VoiceActivityNotificationCreatedCallback);
				end

				self.registeredGuid = guid;
			end
		else
			if self.registeredGuid then
				VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
				self.registeredGuid = nil;
			end
		end
	end
end

function ChannelRosterButtonMixin:UpdateName()
	self.Name:SetText(self:GetMemberName());

	local r, g, b;

	if not self:IsConnected() then
		r, g, b = DISABLED_FONT_COLOR:GetRGB();
	elseif self.playerLocation then
		local _, class= UnitClassByPlayerLocation(self.playerLocation);
		if class then
			r, g, b = GetClassColor(class);
		end
	end

	if not r then
		r, g, b = FRIENDS_WOW_NAME_COLOR:GetRGB();
	end

	self.Name:SetTextColor(r, g, b);
end