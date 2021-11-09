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

function ChannelRosterButtonMixin:IsChannelPublic()
	local channel = self:GetRoster():GetChannelFrame():GetList():GetSelectedChannelButton();
	return channel and IsPublicVoiceChannel(channel:GetVoiceChannel());
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
	local guid;
	local playerLocation = self:GetMemberPlayerLocation();
	if playerLocation then
		guid = playerLocation:GetGUID();
	end

	if guid then
		return C_AccountInfo.IsGUIDRelatedToLocalAccount(guid);
	else
		local voiceMemberID = self:GetVoiceMemberID();
		local voiceChannelID = self:GetVoiceChannelID();

		if voiceMemberID and voiceChannelID then
			return C_VoiceChat.IsMemberLocalPlayer(voiceMemberID, voiceChannelID);
		end
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

function ChannelRosterButtonMixin:ClearVoiceInfo()
	self:SetVoiceEnabled(false);
	self:SetVoiceChannelID(nil);
	self:SetVoiceMemberID(nil);
	self:SetVoiceActive(nil);
	self:SetVoiceMuted(nil);
end

local function ChannelRosterDropdown_Initialize(dropdown, level, menuList)
	UnitPopup_ShowMenu(dropdown, "CHAT_ROSTER", nil, dropdown.name);
end

function ChannelRosterButtonMixin:OnClick(button)
	if button == "RightButton" then
		HideDropDownMenu(1);

		local channel = ChannelFrame:GetList():GetSelectedChannelButton();
		if not channel then
			return;
		end

		local guid;
		local playerLocation = self:GetMemberPlayerLocation();
		if playerLocation then
			guid = playerLocation:GetGUID();
		end

		local dropdown = self:GetRoster():GetChannelFrame():GetDropdown();
		UIDropDownMenu_SetInitializeFunction(dropdown, ChannelRosterDropdown_Initialize);
		dropdown.displayMode = "MENU";
		dropdown.name = self:GetMemberName();
		dropdown.owner = self:IsMemberOwner();
		dropdown.moderator = self:IsMemberModerator();
		dropdown.channelName = channel:GetChannelName();
		dropdown.category = channel:GetCategory();
		dropdown.channelType = channel:GetChannelType();
		dropdown.guid = guid;
		dropdown.isSelf = self:IsLocalPlayer();
		dropdown.voiceChannel = channel:GetVoiceChannel();
		dropdown.voiceChannelID = channel:GetVoiceChannelID();
		if dropdown.voiceChannelID and guid then
			dropdown.voiceMemberID = C_VoiceChat.GetMemberID(dropdown.voiceChannelID, guid);
		else
			dropdown.voiceMemberID = nil;
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
	-- The following methods are not really an API, should only use the public entry point of Update.
	self:UpdateRankVisibleState();
	self.SelfDeafenButton:UpdateVisibleState();
	self.SelfMuteButton:UpdateVisibleState();
	self.MemberMuteButton:UpdateVisibleState();

	self:UpdateName();
	self:UpdateNameSize();
	self:UpdateRankPosition();
	self:UpdateVoiceActivityNotification();

	self:Show();
end

do
	local function ChannelRosterButton_VoiceActivityNotificationCreatedCallback(self, notification)
		notification:SetParent(self);
		notification:ClearAllPoints();
		notification:SetPoint("RIGHT", self, "RIGHT", 0, 0);
		notification:Show();
	end

	function ChannelRosterButtonMixin:UpdateVoiceActivityNotification()
		if self:IsVoiceEnabled() and self:IsChannelActive() then
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

	-- Check for false here, because nil indicates we don't know if they are online
	if self:IsConnected() == false then
		r, g, b = DISABLED_FONT_COLOR:GetRGB();
	elseif self.playerLocation then
		local _, class = C_PlayerInfo.GetClass(self.playerLocation)
		if class then
			r, g, b = GetClassColor(class);
		end
	end

	if not r then
		r, g, b = FRIENDS_WOW_NAME_COLOR:GetRGB();
	end

	self.Name:SetTextColor(r, g, b);
end

function ChannelRosterButtonMixin:UpdateNameSize()
	-- Adjust the name to be smaller to make room for the voice buttons
	if self.SelfMuteButton:IsShown() then
		self.Name:SetWidth(self.showRank and 98 or 113);
	elseif self.MemberMuteButton:IsShown() then
		self.Name:SetWidth(self.showRank and 113 or 128);
	else
		self.Name:SetWidth(140);
	end
end

function ChannelRosterButtonMixin:UpdateRankVisibleState()
	self.showRank = self:IsMemberLeadership();
	self.Rank:SetShown(self.showRank);

	if self.showRank then
		if self:IsMemberOwner() then
			self.Rank:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
		elseif self:IsMemberModerator() then
			self.Rank:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
		end
	end
end

function ChannelRosterButtonMixin:UpdateRankPosition()
	if self.showRank then
		local nameOffset = self.Name:GetLeft() - self:GetLeft();
		local nameWidth = self.Name:GetWidth();
		local nameStringWidth = self.Name:GetStringWidth();
		local rankOffset = (self.Name:IsTruncated() and nameWidth or (nameStringWidth + 4)) + nameOffset;
		self.Rank:SetPoint("LEFT", self, "LEFT", rankOffset, 0);
	end
end

function ChannelRosterButtonMixin:OnHide()
	self:ClearData();
end

function ChannelRosterButtonMixin:ClearData()
	-- This only clears the main identifying data for the button all member/voice info
	-- some of the other data could remain, but should be updated if the button is shown
	-- again.
	self:SetMemberID(nil);
	self:SetVoiceChannelID(nil);
	self:SetVoiceMemberID(nil);
	self:SetMemberName(nil);
end