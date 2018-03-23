ChannelRosterMixin = {};

function ChannelRosterMixin:OnLoad()
	self:InitializeScrollFrame();
end

function ChannelRosterMixin:OnShow()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ADDED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED");
	self:RegisterEvent("UNIT_CONNECTION");
end

function ChannelRosterMixin:OnHide()
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED");
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ADDED");
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED");
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED");
	self:UnregisterEvent("UNIT_CONNECTION");
end

function ChannelRosterMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_MEMBER_ADDED" then
		self:OnVoiceChannelMemberAdded(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED" then
		self:OnVoiceChannelMemberActiveStateChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED" then
		self:OnVoiceChannelMemberEnergyChanged(...);
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED" then
		self:OnVoiceChannelMemberSpeakingStateChanged(...);
	elseif event == "UNIT_CONNECTION" then
		self:OnUnitConnection(...);
	end
end

function ChannelRosterMixin:GetChannelFrame()
	return self:GetParent();
end

function ChannelRosterMixin:OnVoiceChannelMemberAdded(voiceMemberID, memberName, channelID)
	local channel = self:GetChannelFrame():GetList():GetSelectedChannelButton();
	if channel and channel:IsVoiceChannel() then
		self:Update();
	end
end

function ChannelRosterMixin:OnVoiceChannelMemberStateUpdate(methodName, voiceMemberID, channelID, newStateValue)
	local channel = self:GetChannelFrame():GetList():GetSelectedChannelButton();
	if channel and channel:GetChannelID() == channelID and channel:IsVoiceChannel() then
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

function ChannelRosterMixin:OnVoiceChannelMemberEnergyChanged(voiceMemberID, channelID, speakingEnergy)
	self:OnVoiceChannelMemberStateUpdate("SetVoiceEnergy", voiceMemberID, channelID, speakingEnergy);
end

function ChannelRosterMixin:OnVoiceChannelMemberSpeakingStateChanged(voiceMemberID, channelID, isSpeaking)
	self:OnVoiceChannelMemberStateUpdate("SetVoiceTalking", voiceMemberID, channelID, isSpeaking);
end

function ChannelRosterMixin:OnUnitConnection()
	self:Update();
end

function ChannelRosterMixin:GetRosterButtonForVoiceMemberID(voiceMemberID)
	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);

	for i = 1, #buttons do
		if buttons[i]:GetVoiceMemberID() == voiceMemberID then
			return buttons[i];
		end
	end
end

function ChannelRosterMixin:Update()
	local channel = self:GetChannelFrame():GetList():GetSelectedChannelButton();
	if channel then
		if channel:IsTextChannel() then
			self:UpdateFromTextChannelID(channel:GetChannelID());
		else
			self:UpdateFromVoiceChannelID(channel:GetChannelID());
		end
	end
end

function ChannelRosterMixin:ResetScrollPosition()
	self.ScrollFrame.scrollBar:SetValue(0);
end

function ChannelRosterMixin:GetChannelCountText(count, category)
	if count > 0 and self:GetChannelFrame():IsCategoryGroup(category) then
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

	self:UpdateRosterList();
end

do
	function ChannelRosterMixin:UpdateRosterList()
		local count = self.count or 0;
		local opaqueChannel = self.opaqueChannel;
		local updateChannelRosterEntryFn = self.updateChannelRosterEntryFn;

		if self.opaqueChannel then
			local offset = HybridScrollFrame_GetOffset(self.ScrollFrame);
			local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);

			for i = 1, #buttons do
				local button = buttons[i];
				local rosterIndex = offset + i;
				if rosterIndex <= count  then
					updateChannelRosterEntryFn(self.opaqueChannel, rosterIndex, self.voiceChannelID, button);
				else
					button:Hide();
				end
			end
		end

		local index, firstButton = next(HybridScrollFrame_GetButtons(self.ScrollFrame));
		local totalHeight = firstButton and (count * firstButton:GetHeight()) or 0;

		HybridScrollFrame_Update(self.ScrollFrame, totalHeight, self.ScrollFrame:GetHeight());
	end
end

function ChannelRosterMixin:UpdateRosterWidth()
	local rosterLeftEdge = self:GetChannelFrame().LeftInset:GetRight();
	local rosterRightEdge = self.ScrollFrame.scrollBar:GetLeft();

	if self:GetChannelFrame():GetList().ScrollBar:IsShown() then
		rosterLeftEdge = self:GetChannelFrame():GetList().ScrollBar:GetRight();
	end

	-- Add some padding for the inset and scrollbar textures.
	local rosterWidth = rosterRightEdge - rosterLeftEdge;
	self:SetWidth(rosterWidth);
	self.ScrollFrame.scrollChild:SetWidth(rosterWidth - 9); -- Sizing hack, pull the edge of the scroll child inside the right scrollbar.
end

function ChannelRosterMixin:InitializeScrollFrame()
	self.ScrollFrame.update = function() self:UpdateRosterList(); end;
	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);
	HybridScrollFrame_CreateButtons(self.ScrollFrame, "ChannelRosterButtonTemplate", 0, 0);

	-- Set up additional anchors on the buttons so that the width of the roster can be changed, and the
	-- buttons will size automatically.
	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	if buttons then
		for index, button in ipairs(buttons) do
			if index > 1 then
				button:SetPoint("TOPRIGHT", buttons[index - 1], "BOTTOMRIGHT", 0, 0);
			else
				button:SetPoint("TOPRIGHT", self.ScrollFrame.scrollChild, "TOPRIGHT", 0, 0);
			end
		end
	end

	self:UpdateRosterWidth();
end

-- Text channel handling, these can also have members who are active in voice
do
	local function UpdateChatSystemChannelRosterEntry(channelID, rosterIndex, voiceChannelID, rosterEntry)
		local name, owner, moderator, guid = C_ChatInfo.GetChannelRosterInfo(channelID, rosterIndex);

		rosterEntry:SetMemberID(rosterIndex);
		rosterEntry:SetMemberName(name);
		rosterEntry:SetMemberIsOwner(owner);
		rosterEntry:SetMemberIsModerator(moderator);
		rosterEntry:SetVoiceEnabled(false);

		if voiceChannelID then
			voiceMemberID = C_VoiceChat.GetMemberID(voiceChannelID, guid);
			local voiceMemberInfo = voiceMemberID and C_VoiceChat.GetMemberInfo(voiceMemberID, voiceChannelID);
			
			if voiceMemberInfo then
				rosterEntry:SetVoiceEnabled(true);
				rosterEntry:SetVoiceChannelID(voiceChannelID);
				rosterEntry:SetVoiceMemberID(voiceMemberID);
				rosterEntry:SetVoiceActive(voiceMemberInfo.isActive);
				rosterEntry:SetVoiceMuted(voiceMemberInfo.isMutedForMe);
				rosterEntry:SetIsConnected(C_VoiceChat.IsMemberConnected(voiceMemberID, voiceChannelID));
			end
		end

		if not rosterEntry:IsVoiceEnabled() then
			rosterEntry:SetVoiceChannelID(nil);
			rosterEntry:SetVoiceMemberID(nil);
			rosterEntry:SetVoiceActive(nil);
			rosterEntry:SetVoiceMuted(nil);
			rosterEntry:SetIsConnected(true);
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
			rosterEntry:SetMemberName(member.name);
			rosterEntry:SetMemberIsOwner(false);
			rosterEntry:SetMemberIsModerator(false);
			rosterEntry:SetVoiceEnabled(true);
			rosterEntry:SetVoiceActive(member.isActive);
			rosterEntry:SetVoiceMuted(member.isMutedForMe);
			rosterEntry:SetIsConnected(C_VoiceChat.IsMemberConnected(member.memberID, voiceChannelID));

			rosterEntry:Update();
		end
	end

	function ChannelRosterMixin:UpdateFromVoiceChannelID(channelID)
		self.voiceChannelID = channelID;

		return self:UpdateFromOpaqueChannel(C_VoiceChat.GetChannel(channelID), GetVoiceChannelInfo, UpdateVoiceChannelRosterEntry);
	end
end