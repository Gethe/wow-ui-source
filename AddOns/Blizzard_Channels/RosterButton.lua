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

function RosterToggleButtonMixin:ShouldShow()
	return self:GetVoiceMemberID() ~= nil and self:GetVoiceChannelID() ~= nil;
end

function RosterToggleButtonMixin:ShouldShowLocalPlayerOnly()
	return self:ShouldShow() and self:IsLocalPlayer();
end

RosterDeafenButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterDeafenButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	self:SetVisibilityQueryFunction(self.ShouldShowLocalPlayerOnly);
	self:SetAccessorFunctionThroughSelf(self.IsDeafened);
	self:SetMutatorFunction(C_VoiceChat.SetDeafened);
	self:AddStateAtlas(false, "voicechat-icon-speaker");
	self:AddStateAtlas(true, "voicechat-icon-speaker-mute");
	self:AddStateTooltipString(false, VOICE_TOOLTIP_DEAFEN);
	self:AddStateTooltipString(true, VOICE_TOOLTIP_UNDEAFEN);
	self:RegisterStateUpdateEvent("VOICE_CHAT_DEAFENED_CHANGED");
	self:UpdateVisibleState();
end

function RosterDeafenButtonMixin:IsDeafened()
	return self:IsLocalPlayer() and C_VoiceChat.IsDeafened();
end

RosterMuteButtonMixin = CreateFromMixins(RosterToggleButtonMixin);

function RosterMuteButtonMixin:OnLoad()
	RosterToggleButtonMixin.OnLoad(self);

	-- NOTE: Mutator is custom
	self:SetVisibilityQueryFunction(self.ShouldShow);
	self:SetAccessorFunctionThroughSelf(self.GetState);

	self:AddStateAtlas("player_muted", "voicechat-icon-mic-mute");
	self:AddStateAtlas("player_unmuted", "voicechat-icon-mic");
	self:AddStateAtlas("member_muted", "voicechat-icon-speaker-mute");
	self:AddStateAtlas("member_unmuted", "voicechat-icon-speaker");
	self:AddStateAtlas("member_speaking", "voicechat-icon-speaker"); -- TODO: actually need a single atlas to represent this if multiple volume levels aren't crucial...

	self:AddStateTooltipString("player_muted", VOICE_TOOLTIP_UNMUTE_MIC);
	self:AddStateTooltipString("player_unmuted", VOICE_TOOLTIP_MUTE_MIC);
	self:AddStateTooltipString("member_muted", VOICE_TOOLTIP_UNMUTE_MIC);
	self:AddStateTooltipString("member_unmuted", VOICE_TOOLTIP_MUTE_MIC);
	self:AddStateTooltipString("member_speaking", VOICE_TOOLTIP_MUTE_MIC);

	self:RegisterStateUpdateEvent("VOICE_CHAT_MUTED_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED");
	self:RegisterStateUpdateEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED", self.OnSpeakingStateChanged);
	self:UpdateVisibleState();
end

function RosterMuteButtonMixin:OnSpeakingStateChanged(memberID, channelID, isSpeaking)
	if self:DoesMemberInfoMatch(channelID, memberID) then
		self.isSpeaking = isSpeaking;
		self:UpdateVisibleState();
	end
end

function RosterMuteButtonMixin:DoesMemberInfoMatch(channelID, memberID)
	local rosterButton = self:GetParent();
	return rosterButton:GetVoiceMemberID() == memberID and rosterButton:GetVoiceChannelID() == channelID;
end

-- Use to determine if a player is muted or not
-- Only muted states need to be in here.
local muteStateLookup = {
	player_muted = true,
	member_muted = true,
};

function RosterMuteButtonMixin:GetState()
	if self:IsLocalPlayer() then
		if C_VoiceChat.IsMuted() then
			return "player_muted";
		else
			return "player_unmuted";
		end
	end

	if C_VoiceChat.IsMemberMuted(self:GetVoiceMemberID(), self:GetVoiceChannelID()) then
		return "member_muted";
	else
		if self.isSpeaking then
			return "member_speaking";
		else
			return "member_unmuted";
		end
	end
end

function RosterMuteButtonMixin:ToggleMuteState()
	local currentState = self:GetState();
	local isMuted = muteStateLookup[currentState];

	if self:IsLocalPlayer() then
		C_VoiceChat.SetMuted(not isMuted);
	else
		C_VoiceChat.SetMemberMuted(self:GetVoiceMemberID(), self:GetVoiceChannelID(), not isMuted);
	end
end

ChannelRosterButtonMixin = {};

function ChannelRosterButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function ChannelRosterButtonMixin:GetRoster()
	return self:GetParent():GetParent():GetParent();
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

function ChannelRosterButtonMixin:SetVoiceEnergy(energy)
	self.voiceEnergy = energy;
end

function ChannelRosterButtonMixin:GetVoiceEnergy()
	return self.voiceEnergy;
end

function ChannelRosterButtonMixin:SetVoiceTalking(isTalking)
	self.voiceTalking = isTalking;
end

function ChannelRosterButtonMixin:IsVoiceTalking()
	return self.voiceTalking;
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
		dropdown.isLocalPlayer = nil;
		if dropdown.voiceMemberID then
			dropdown.isLocalPlayer = C_VoiceChat.IsMemberLocalPlayer(dropdown.voiceMemberID, dropdown.voiceChannelID);
		end

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

	self.MuteButton:UpdateVisibleState();
	self.DeafenButton:UpdateVisibleState();

	self:Show();
end

function ChannelRosterButtonMixin:UpdateName()
	self.Name:SetText(self:GetMemberName());

	local r, g, b;

	if not self:IsConnected() then
		r, g, b = DISABLED_FONT_COLOR:GetRGB();
	elseif self:IsVoiceEnabled() then
		local voiceCharacterInfo = C_VoiceChat.GetCharacterInfo(self:GetVoiceMemberID(), self:GetVoiceChannelID());
		if voiceCharacterInfo then
			r, g, b = GetClassColor(voiceCharacterInfo.classFilename);
		end
	end

	if not r then
		r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB();
	end

	self.Name:SetTextColor(r, g, b);
end