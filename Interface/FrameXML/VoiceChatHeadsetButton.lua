VoiceChatDotsMixin = {};

function VoiceChatDotsMixin:OnLoad()
	self:StopAnimation();
end

function VoiceChatDotsMixin:PlayAnimation()
	self.Dot1:SetAlpha(0);
	self.Dot2:SetAlpha(0);
	self.Dot3:SetAlpha(0);
	self.PendingAnim:Play();
end

function VoiceChatDotsMixin:StopAnimation()
	self.PendingAnim:Stop();
	self.Dot1:SetAlpha(0);
	self.Dot2:SetAlpha(0);
	self.Dot3:SetAlpha(0);
end

VoiceChatHeadsetButtonMixin = {};

function VoiceChatHeadsetButtonMixin:OnLoad()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_JOINED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED");
	self:RegisterEvent("VOICE_CHAT_LOGOUT");
	self:RegisterEvent("VOICE_CHAT_PENDING_CHANNEL_JOIN_STATE");
	self:RegisterEvent("VOICE_CHAT_ERROR");
end

function VoiceChatHeadsetButtonMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_JOINED" then
		self:OnVoiceChannelJoined(...);
	elseif event == "VOICE_CHAT_CHANNEL_REMOVED" then
		self:OnVoiceChannelRemoved(...);
	elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" then
		self:OnVoiceChannelActivated(...);
	elseif event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		self:OnVoiceChannelDeactivated(...);
	elseif event == "VOICE_CHAT_LOGOUT" then
		self:ClearPendingState();
	elseif event == "VOICE_CHAT_PENDING_CHANNEL_JOIN_STATE" then
		self:OnVoiceChatPendingChannelJoinState(...);
	elseif event == "VOICE_CHAT_ERROR" then
		self:OnVoiceChatError(...);
	end
end

function VoiceChatHeadsetButtonMixin:VoiceChannelIDMatches(voiceChannelID)
	return voiceChannelID == self:GetVoiceChannelID();
end

function VoiceChatHeadsetButtonMixin:VoiceChannelInfoMatches(channelType, clubId, streamId)
	if channelType ~= self:GetChannelType() then
		return false;
	end

	if clubId and streamId then
		return clubId == self:GetClubID() and streamId == self:GetStreamID();
	end

	return true;
end

function VoiceChatHeadsetButtonMixin:OnVoiceChannelJoined(statusCode, voiceChannelID, channelType, clubId, streamId)
	if statusCode == Enum.VoiceChatStatusCode.Success then
		if self:VoiceChannelIDMatches(voiceChannelID) or self:VoiceChannelInfoMatches(channelType, clubId, streamId) then
			self:SetVoiceChannel(C_VoiceChat.GetChannel(voiceChannelID));
		end
	end
end

function VoiceChatHeadsetButtonMixin:OnVoiceChannelRemoved(voiceChannelID)
	if self:VoiceChannelIDMatches(voiceChannelID) then
		self:ClearVoiceChannel();
	end
end

function VoiceChatHeadsetButtonMixin:OnVoiceChannelActivated(voiceChannelID)
	if self:VoiceChannelIDMatches(voiceChannelID) then
		self:SetVoiceActive(true);
	end
end

function VoiceChatHeadsetButtonMixin:OnVoiceChannelDeactivated(voiceChannelID)
	if self:VoiceChannelIDMatches(voiceChannelID) then
		self:SetVoiceActive(false);
	end
end

function VoiceChatHeadsetButtonMixin:ClearPendingState()
	self:GetParent():SetPendingState(false);
end

function VoiceChatHeadsetButtonMixin:OnVoiceChatPendingChannelJoinState(channelType, clubId, streamId, pendingState)
	if self:VoiceChannelInfoMatches(channelType, clubId, streamId) then
 		self:GetParent():SetPendingState(pendingState);
	elseif channelType == Enum.ChatChannelType.None then
		-- A channelType of None indicates login failed, so clear all pending states in that case
		self:GetParent():SetPendingState(false);
 	end
end

function VoiceChatHeadsetButtonMixin:OnVoiceChatError(platformCode, statusCode)
	if Voice_IsConnectionError(statusCode) then
		self:ClearPendingState();
		self:ClearVoiceChannel();
	end
end

function VoiceChatHeadsetButtonMixin:OnClick()
	local voiceChannel = self:GetVoiceChannel();
	if voiceChannel then
		local isActive = C_VoiceChat.GetActiveChannelID() == voiceChannel.channelID;
		if isActive then
			C_VoiceChat.DeactivateChannel(voiceChannel.channelID);
		else
			C_VoiceChat.ActivateChannel(voiceChannel.channelID);
		end
	elseif self:IsCommunityChannel() then
		ChannelFrame:TryJoinCommunityStreamChannel(self.clubId, self.streamId);
	else
		local activate = true;
		ChannelFrame:TryJoinVoiceChannelByType(self:GetChannelType(), activate);
	end

	if self.onClickFn then
		self:onClickFn();
	end
end

function VoiceChatHeadsetButtonMixin:SetOnClickCallback(fn)
	self.onClickFn = fn;
end

function VoiceChatHeadsetButtonMixin:SetVoiceChannel(voiceChannel)
	self.linkedVoiceChannel = voiceChannel;

	if self.linkedVoiceChannel then
		self:SetVoiceActive(self.linkedVoiceChannel.isActive);
	else
		self:SetVoiceActive(false);
	end
end

function VoiceChatHeadsetButtonMixin:ClearVoiceChannel()
	self:SetVoiceChannel(nil);
end

function VoiceChatHeadsetButtonMixin:GetVoiceChannel()
	return self.linkedVoiceChannel;
end

function VoiceChatHeadsetButtonMixin:GetVoiceChannelID()
	if self.linkedVoiceChannel then
		return self.linkedVoiceChannel.channelID;
	end

	return nil;
end

function VoiceChatHeadsetButtonMixin:SetChannelType(channelType)
	self.channelType = channelType;

	if channelType ~= Enum.ChatChannelType.Communities then
		self:SetVoiceChannel(C_VoiceChat.GetChannelForChannelType(channelType));
		self:GetParent():SetPendingState(C_VoiceChat.IsChannelJoinPending(channelType));
	end
end

function VoiceChatHeadsetButtonMixin:GetChannelType()
	return self.channelType;
end

function VoiceChatHeadsetButtonMixin:GetClubID()
	return self.clubId;
end

function VoiceChatHeadsetButtonMixin:GetStreamID()
	return self.streamId;
end

function VoiceChatHeadsetButtonMixin:SetCommunityInfo(clubId, streamInfo)
	self.clubId = clubId;
	self.streamId = streamInfo.streamId;
	self:SetChannelName(streamInfo.name);
	self:SetChannelType(Enum.ChatChannelType.Communities);
	self:SetVoiceChannel(C_VoiceChat.GetChannelForCommunityStream(clubId, streamInfo.streamId));
	self:GetParent():SetPendingState(C_VoiceChat.IsChannelJoinPending(Enum.ChatChannelType.Communities, self.clubId, self.streamId));
end

function VoiceChatHeadsetButtonMixin:IsCommunityChannel()
	return self.clubId and self.streamId;
end

function VoiceChatHeadsetButtonMixin:SetVoiceActive(voiceActive)
	self.voiceActive = voiceActive;
	self:Update();
end

function VoiceChatHeadsetButtonMixin:IsVoiceActive()
	return self.voiceActive;
end

function VoiceChatHeadsetButtonMixin:GetChannelName()
	return self.name or "";
end

function VoiceChatHeadsetButtonMixin:SetChannelName(name)
	self.name = name;
end

function VoiceChatHeadsetButtonMixin:OnEnter()
	self:ShowTooltip();
end

function VoiceChatHeadsetButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function VoiceChatHeadsetButtonMixin:ShowTooltip()
	local isActive = self:IsVoiceActive();
	local message = isActive and VOICE_CHAT_LEAVE or VOICE_CHAT_JOIN;

	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(tooltip, message);
	tooltip:Show();
end

function VoiceChatHeadsetButtonMixin:ShouldEnable()
	if self:GetVoiceChannel() or (self:IsCommunityChannel() and C_VoiceChat.CanPlayerUseVoiceChat()) then
		return true;
	end

	local channelType = self:GetChannelType();
	if channelType then
		return C_ChatInfo.IsPartyChannelType(channelType);
	end

	return false;
end

function VoiceChatHeadsetButtonMixin:Update()
	if self:ShouldEnable() then
		self:SetShown(true);

		local isActive = self:IsVoiceActive();
		local atlas = isActive and "voicechat-channellist-icon-headphone-on" or "voicechat-channellist-icon-headphone-off";
		self:SetNormalAtlas(atlas);
		self:SetHighlightAtlas(atlas);

		if GameTooltip:GetOwner() == self then
			self:ShowTooltip();
		end
	else
		self:SetShown(false);

		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide();
		end
	end
end

VoiceChatHeadsetMixin = {};

function VoiceChatHeadsetMixin:SetCommunityInfo(...)
	self.Button:SetCommunityInfo(...);
end

function VoiceChatHeadsetMixin:SetChannelType(...)
	self.Button:SetChannelType(...);
end

function VoiceChatHeadsetMixin:SetChannelName(...)
	self.Button:SetChannelName(...);
end

function VoiceChatHeadsetMixin:SetOnClickCallback(fn)
	self.Button:SetOnClickCallback(fn);
end

function VoiceChatHeadsetMixin:SetPendingState(pending)
	if pending then
		self.PendingDots:PlayAnimation();
	else
		self.PendingDots:StopAnimation();
	end
end

