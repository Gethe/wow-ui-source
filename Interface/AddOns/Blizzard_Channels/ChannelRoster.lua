ChannelRosterMixin = {};

function ChannelRosterMixin:OnLoad()
	self:InitializeScrollBox();
end

function ChannelRosterMixin:OnShow()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED");
	self:RegisterEvent("UNIT_CONNECTION");
end

function ChannelRosterMixin:OnHide()
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED");
	self:UnregisterEvent("UNIT_CONNECTION");
end

function ChannelRosterMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED" then
		self:OnVoiceChannelMemberActiveStateChanged(...);
	elseif event == "UNIT_CONNECTION" then
		self:OnUnitConnection(...);
	end
end

function ChannelRosterMixin:GetChannelFrame()
	return self:GetParent();
end

function ChannelRosterMixin:OnVoiceChannelMemberStateUpdate(methodName, voiceMemberID, voiceChannelID, newStateValue)
	local channel = self:GetChannelFrame():GetList():GetSelectedChannelButton();
	if channel and channel:GetVoiceChannelID() == voiceChannelID and channel:ChannelSupportsVoice() then
		local rosterButton = self:GetRosterButtonForVoiceMemberID(voiceMemberID);
		if rosterButton then
			rosterButton[methodName](rosterButton, newStateValue);
			rosterButton:Update();
		end
	end
end

function ChannelRosterMixin:OnVoiceChannelMemberActiveStateChanged(voiceMemberID, channelID, isActive)
	self:OnVoiceChannelMemberStateUpdate("SetVoiceActive", voiceMemberID, channelID, isActive);
end

function ChannelRosterMixin:OnUnitConnection()
	self:Update();
end

function ChannelRosterMixin:GetRosterButtonForVoiceMemberID(voiceMemberID)
	return self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return frame:GetVoiceMemberID() == voiceMemberID;
	end);
end

function ChannelRosterMixin:Update()
	local channel = self:GetChannelFrame():GetList():GetSelectedChannelButton();
	if channel then
		if channel:ChannelIsCommunity() then
			self:UpdateFromCommunityStream(channel);
		elseif channel:ChannelSupportsText() then
			self:UpdateFromTextChannelID(channel:GetChannelID());
		else
			self:UpdateFromVoiceChannelID(channel:GetVoiceChannelID());
		end
	end
end

function ChannelRosterMixin:ResetScrollPosition()
	self.ScrollBox:ScrollToBegin();
end

function ChannelRosterMixin:GetChannelCountText(count, category)
	if count > 0 and ChannelFrame_IsCategoryGroup(category) then
		return ("(%d)"):format(count);
	end

	return "";
end

function ChannelRosterMixin:GetChannelNameText(count, channel)
	return (count > 0 and channel) and channel or "";
end

function ChannelRosterMixin:UpdateFromOpaqueChannel(opaqueChannel, getChannelInfoFn, updateChannelRosterEntryFn)
	self.opaqueChannel = opaqueChannel;
	self.updateChannelRosterEntryFn = updateChannelRosterEntryFn;

	local channel, header, collapsed, channelNumber, count, enabled, category = getChannelInfoFn(opaqueChannel);
	self.count = count or 0;

	self.ChannelCount:SetText(self:GetChannelCountText(self.count, category));
	self.ChannelName:SetText(self:GetChannelNameText(self.count, channel));

	local dataProvider = CreateIndexRangeDataProvider(self.count);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function ChannelRosterMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();

	local function Initializer(button, rosterIndex)
		self.updateChannelRosterEntryFn(self.opaqueChannel, rosterIndex, self.voiceChannelID, button);
	end
	view:SetElementInitializer("ChannelRosterButtonTemplate", Initializer);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

-- Text channel handling, these can also have members who are active in voice
do
	local function UpdateChatSystemChannelRosterEntry(channelID, rosterIndex, voiceChannelID, rosterEntry)
		local name, owner, moderator, guid = C_ChatInfo.GetChannelRosterInfo(channelID, rosterIndex);

		if not name then
			-- we don't have the roster info yet
			return;
		end

		rosterEntry:SetMemberID(rosterIndex);
		rosterEntry:SetMemberPlayerLocationFromGuid(guid);
		rosterEntry:SetMemberName(name);
		rosterEntry:SetMemberIsOwner(owner);
		rosterEntry:SetMemberIsModerator(moderator);
		rosterEntry:ClearVoiceInfo();
		rosterEntry:SetIsConnected(C_PlayerInfo.IsConnected(rosterEntry:GetMemberPlayerLocation()));

		if voiceChannelID then
			local voiceMemberID = C_VoiceChat.GetMemberID(voiceChannelID, guid);
			local voiceMemberInfo = voiceMemberID and C_VoiceChat.GetMemberInfo(voiceMemberID, voiceChannelID);

			if voiceMemberInfo then
				rosterEntry:SetVoiceEnabled(true);
				rosterEntry:SetVoiceChannelID(voiceChannelID);
				rosterEntry:SetVoiceMemberID(voiceMemberID);
				rosterEntry:SetVoiceActive(voiceMemberInfo.isActive);
				rosterEntry:SetVoiceMuted(voiceMemberInfo.isMutedForMe);
			end
		end

		rosterEntry:Update();
	end

	function ChannelRosterMixin:UpdateFromTextChannelID(channelID)
		-- Link the voice channel id if there is one
		local _, _, _, _, _, _, _, channelType = GetChannelDisplayInfo(channelID);
		local voiceChannel = C_VoiceChat.GetChannelForChannelType(channelType);
		self.voiceChannelID = voiceChannel and voiceChannel.channelID or nil;

		return self:UpdateFromOpaqueChannel(channelID, GetChannelDisplayInfo, UpdateChatSystemChannelRosterEntry);
	end
end

-- Voice-only channels
do
	local function GetVoiceChannelInfo(voiceChannel)
		if voiceChannel then
			-- channel, header, collapsed, channelNumber, count, enabled, category
			return ChannelFrame_GetIdealChannelName(voiceChannel), false, false, voiceChannel.channelID, #voiceChannel.members, true, "CHANNEL_CATEGORY_CUSTOM";
		end
	end

	local function UpdateVoiceChannelRosterEntry(voiceChannel, rosterIndex, voiceChannelID, rosterEntry)
		if voiceChannel and rosterIndex <= #voiceChannel.members then
			local member = voiceChannel.members[rosterIndex];

			rosterEntry:SetMemberID(rosterIndex);
			rosterEntry:SetVoiceChannelID(voiceChannelID);
			rosterEntry:SetVoiceMemberID(member.memberID);
			rosterEntry:SetMemberPlayerLocationFromGuid(C_VoiceChat.GetMemberGUID(member.memberID, voiceChannelID));
			rosterEntry:SetMemberName(member.name);
			rosterEntry:SetMemberIsOwner(false);
			rosterEntry:SetMemberIsModerator(false);
			rosterEntry:SetVoiceEnabled(true);
			rosterEntry:SetVoiceActive(member.isActive);
			rosterEntry:SetVoiceMuted(member.isMutedForMe);
			rosterEntry:SetIsConnected(C_PlayerInfo.IsConnected(rosterEntry:GetMemberPlayerLocation()));

			rosterEntry:Update();
		end
	end

	function ChannelRosterMixin:UpdateFromVoiceChannelID(channelID)
		self.voiceChannelID = channelID;

		return self:UpdateFromOpaqueChannel(C_VoiceChat.GetChannel(channelID), GetVoiceChannelInfo, UpdateVoiceChannelRosterEntry);
	end
end

-- Community channels
do
	local function UpdateCommunityStreamChannelRosterEntry(communityStreamInfo, rosterIndex, voiceChannelID, rosterEntry)
		local memberInfo = communityStreamInfo.members[rosterIndex];

		rosterEntry:SetMemberID(memberInfo.memberId);
		rosterEntry:SetMemberPlayerLocationFromGuid(memberInfo.guid);
		rosterEntry:SetMemberName(memberInfo.name);
		rosterEntry:SetMemberIsOwner(memberInfo.role == Enum.ClubRoleIdentifier.Owner or memberInfo.role == Enum.ClubRoleIdentifier.Leader);
		rosterEntry:SetMemberIsModerator(memberInfo.role == Enum.ClubRoleIdentifier.Moderator);
		rosterEntry:ClearVoiceInfo();
		rosterEntry:SetIsConnected(memberInfo.presence ~= Enum.ClubMemberPresence.Offline);

		if voiceChannelID and memberInfo.guid then
			local voiceMemberID = C_VoiceChat.GetMemberID(voiceChannelID, memberInfo.guid);
			local voiceMemberInfo = voiceMemberID and C_VoiceChat.GetMemberInfo(voiceMemberID, voiceChannelID);

			if voiceMemberInfo then
				rosterEntry:SetVoiceEnabled(true);
				rosterEntry:SetVoiceChannelID(voiceChannelID);
				rosterEntry:SetVoiceMemberID(voiceMemberID);
				rosterEntry:SetVoiceActive(voiceMemberInfo.isActive);
				rosterEntry:SetVoiceMuted(voiceMemberInfo.isMutedForMe);
			end
		end

		rosterEntry:Update();
	end

	local function GetCommunityStreamRosterInfo(communityStreamInfo)
		if communityStreamInfo then
			local isHeader = false;
			local isCollapsed = false;
			local isEnabled = true;
			local channelNumber = 0;

			return communityStreamInfo.name, isHeader, isCollapsed, channelNumber, #communityStreamInfo.members, isEnabled, "CHANNEL_CATEGORY_CUSTOM";
		end
	end

	function ChannelRosterMixin:UpdateFromCommunityStream(channelButton)
		-- Link the voice channel id if there is one
		local voiceChannel = C_VoiceChat.GetChannelForCommunityStream(channelButton.clubId, channelButton.streamId);
		self.voiceChannelID = voiceChannel and voiceChannel.channelID or nil;

		local communityStreamInfo = {clubId = channelButton.clubId, streamId = channelButton.streamId, name = channelButton.streamInfo.name};
		communityStreamInfo.members = CommunitiesUtil.GetAndSortMemberInfo(channelButton.clubId, channelButton.streamId);

		return self:UpdateFromOpaqueChannel(communityStreamInfo, GetCommunityStreamRosterInfo, UpdateCommunityStreamChannelRosterEntry);
	end
end
