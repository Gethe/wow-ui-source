-- Base
ChannelButtonBaseMixin = {};

function ChannelButtonBaseMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function ChannelButtonBaseMixin:OnClick(button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	HideDropDownMenu(1);
end

function ChannelButtonBaseMixin:GetChannelList()
	return self:GetParent():GetParent();
end

function ChannelButtonBaseMixin:Reset(pool)
	FramePool_HideAndClearAnchors(pool, self);
	self:Enable();
end

function ChannelButtonBaseMixin:IsHeader()
	return false;
end

function ChannelButtonBaseMixin:ChannelSupportsVoice()
	return false;
end

function ChannelButtonBaseMixin:ChannelSupportsText()
	return false;
end

function ChannelButtonBaseMixin:ChannelIsCommunity()
	return self.clubId and self.streamId;
end

function ChannelButtonBaseMixin:FuzzyIsMatchingChannel(channelID, channelName)
	return self:GetChannelID() == channelID or self:GetChannelName() == channelName;
end

function ChannelButtonBaseMixin:GetVerticalPadding(previousButton)
	-- NOTE: It's not safe to query mutable state at this point, anchoring is set up before data.
	if previousButton:IsHeader() then
		if self:IsHeader() then
			return 5;
		else
			return 2;
		end
	else
		if self:IsHeader() then
			return 5;
		end
	end

	return 0;
end

function ChannelButtonBaseMixin:IsUserCreatedChannel()
	return not self:IsHeader() and self:GetCategory() == "CHANNEL_CATEGORY_CUSTOM";
end

function ChannelButtonBaseMixin:SetCategory(category)
	self.category = category;
end

function ChannelButtonBaseMixin:GetCategory()
	return self.category;
end

function ChannelButtonBaseMixin:SetVoiceChannel(voiceChannel)
	self.linkedVoiceChannel = voiceChannel;

	if self.linkedVoiceChannel then
		self:SetVoiceActive(self.linkedVoiceChannel.isActive);
	else
		self:SetVoiceActive(false);
	end
end

function ChannelButtonBaseMixin:ClearVoiceChannel()
	self:SetVoiceChannel(nil);
end

function ChannelButtonBaseMixin:SetChannelType(channelType)
	self.channelType = channelType;

	if self:ChannelSupportsText() then
		self:SetVoiceChannel(C_VoiceChat.GetChannelForChannelType(channelType));
	end

	if self.Speaker then
		self.Speaker:SetChannelType(channelType);
	end
end

function ChannelButtonBaseMixin:GetChannelType()
	return self.channelType;
end

function ChannelButtonBaseMixin:SetChannelID(channelID)
	self.channelID = channelID;
end

function ChannelButtonBaseMixin:GetChannelID()
	return self.channelID;
end

function ChannelButtonBaseMixin:GetVoiceChannelID()
	local voiceChannel = self:GetVoiceChannel();
	if voiceChannel then
		return voiceChannel.channelID;
	end

	return nil;
end

function ChannelButtonBaseMixin:GetVoiceChannel()
	return self.linkedVoiceChannel;
end

function ChannelButtonBaseMixin:SetActive(active)
	self.active = active;
end

function ChannelButtonBaseMixin:IsActive()
	return self.active;
end

function ChannelButtonBaseMixin:SetVoiceActive(voiceActive)
	self.voiceActive = voiceActive;
end

function ChannelButtonBaseMixin:IsVoiceActive()
	return not self:IsRemoved() and self.voiceActive;
end

function ChannelButtonBaseMixin:SetRemoved(removed)
	self.removed = removed;
	self:SetEnabled(not removed);
end

function ChannelButtonBaseMixin:IsRemoved()
	return self.removed;
end

function ChannelButtonBaseMixin:GetChannelNumber()
	return self.channelNumber;
end

function ChannelButtonBaseMixin:SetChannelNumber(channelNumber)
	self.channelNumber = channelNumber;
end

function ChannelButtonBaseMixin:GetChannelNumberText()
	local channelNumber = self:GetChannelNumber();
	return channelNumber and ("%u."):format(channelNumber) or "";
end

function ChannelButtonBaseMixin:SetIsSelectedChannel(isSelected)
	if isSelected then
		self:SetHighlightAtlas("voicechat-channellist-row-selected");
		self:LockHighlight();
	else
		self:SetHighlightAtlas("voicechat-channellist-row-highlight");
		self:UnlockHighlight();
	end
end

function ChannelButtonBaseMixin:GetChannelName()
	return self.name;
end

function ChannelButtonBaseMixin:SetChannelName(name)
	self.name = name;

	if self.Speaker then
		self.Speaker:SetChannelName(name);
	end
end

function ChannelButtonBaseMixin:GetMemberCount()
	return self.count or 0;
end

function ChannelButtonBaseMixin:SetMemberCount(count)
	self.count = count;
end

function ChannelButtonBaseMixin:GetMemberCountText()
	local count = self:GetMemberCount();
	local isGroupCategory = self:GetCategory() == "CHANNEL_CATEGORY_GROUP";
	return (count > 0 and isGroupCategory) and ("(%u)"):format(count) or "";
end

function ChannelButtonBaseMixin:Update()
	self:Show();
end

function ChannelButtonBaseMixin:Setup(channelID, name, header, channelNumber, count, active, category)
	self:SetChannelName(name);
	self:SetMemberCount(count);
	self:SetCategory(category);

	self:Update();
end

-- Channels
ChannelButtonMixin = CreateFromMixins(ChannelButtonBaseMixin);

function ChannelButtonMixin:OnLoad()
	ChannelButtonBaseMixin.OnLoad(self);
end

function ChannelButtonMixin:OnClick(button)
	ChannelButtonBaseMixin.OnClick(self, button);

	self:GetChannelList():SetSelectedChannel(self);

	if button == "RightButton" then
		self:GetChannelList():ShowDropdown(self);
	end
end

do
	local function OnClickSpeaker(headsetButton)
		-- If the user clicks this before seeing the tutorial, assume they know how to activate voice channels.
		-- This only applies to headset buttons in the channels frame.
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CHAT_CHANNELS, true);
		ChannelFrame:HideTutorial();
	end

	function ChannelButtonMixin:Update()
		ChannelButtonBaseMixin.Update(self);

		local selectedChannelID, selectedChannelSupportsText = self:GetChannelList():GetSelectedChannelIDAndSupportsText();
		self:SetIsSelectedChannel(self:GetChannelID() == selectedChannelID and self:ChannelSupportsText() == selectedChannelSupportsText);

		self.NormalTexture:SetAlpha(1);

		local hasVoice = self:ChannelSupportsVoice();
		local hasText = self:ChannelSupportsText();

		-- setup name label anchoring
		self.Text:ClearAllPoints();
		self.Text:SetPoint("LEFT", self, "LEFT", 6, 0);

		if hasVoice then
			self.Text:SetPoint("RIGHT", self.Speaker, "LEFT", -2, 0);
		else
			self.Text:SetPoint("RIGHT", self, "RIGHT", -6, 0);
		end

		-- Some text channels have voice, not all voice channels have text...channels with text have setup priority for appearance (also, they're backed by the chat system,
		-- not the voice chat system)
		if hasText then
			local color = self:IsActive() and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
			local text = ("%s %s %s"):format(self:GetChannelNumberText(), self:GetChannelName(), self:GetMemberCountText());
			self.Text:SetText(color:WrapTextInColorCode(text));
			self:SetEnabled(self:IsActive() or hasVoice);
		elseif hasVoice then
			local isAvailable = not self:IsRemoved();
			local color = isAvailable and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
			self.Text:SetText(color:WrapTextInColorCode(self:GetChannelName()));
			self:SetEnabled(isAvailable);
		else
			local color = DISABLED_FONT_COLOR;
			self.Text:SetText(color:WrapTextInColorCode(self:GetChannelName()));
			self:SetEnabled(false);
		end

		self.Speaker:SetOnClickCallback(OnClickSpeaker);
	end
end

function ChannelButtonMixin:Setup(channelID, name, header, channelNumber, count, active, category, channelType)
	self:SetChannelNumber(channelNumber);
	self:SetActive(active);
	self:SetChannelType(channelType);
	self:SetRemoved(false);
	self:SetChannelID(channelID);

	ChannelButtonBaseMixin.Setup(self, channelID, name, header, channelNumber, count, active, category);
end

-- Text channel button
ChannelButtonTextMixin = CreateFromMixins(ChannelButtonMixin);

function ChannelButtonTextMixin:ChannelSupportsText()
	return true;
end

function ChannelButtonTextMixin:ChannelSupportsVoice()
	return C_ChatInfo.IsPartyChannelType(self:GetChannelType());
end

-- Voice channel button
ChannelButtonVoiceMixin = CreateFromMixins(ChannelButtonMixin);

function ChannelButtonVoiceMixin:Setup(channelID, category)
	local channel = C_VoiceChat.GetChannel(channelID);
	local isHeader = false;
	local channelNumber = nil;

	self:SetVoiceActive(channel.isActive);

	ChannelButtonMixin.Setup(self, channelID, ChannelFrame_GetIdealChannelName(channel), header, channelNumber, #channel.members, channel.isActive, category, channel.channelType);
end

function ChannelButtonVoiceMixin:ChannelSupportsVoice()
	return true;
end

function ChannelButtonVoiceMixin:IsUserCreatedChannel()
	return self:GetChannelType() == Enum.ChatChannelType.Custom;
end

-- Community channel button
ChannelButtonCommunityMixin = CreateFromMixins(ChannelButtonMixin);

function ChannelButtonCommunityMixin:OnClick(button)
	C_Club.SetClubPresenceSubscription(self.clubId);
	ChannelButtonMixin.OnClick(self, button);
end

function ChannelButtonCommunityMixin:Setup(channelID, clubId, streamInfo)
	local isHeader = false;
	local channelNumber = nil;
	local count = 0;
	local isActive = true;
	local category = clubId;	-- use the clubId as the category since this will allow all of a club's streams to be under the same header

	self:SetCommunityInfo(clubId, streamInfo);

	ChannelButtonMixin.Setup(self, channelID, streamInfo.name, isHeader, channelNumber, count, isActive, category, Enum.ChatChannelType.Communities);
end

function ChannelButtonCommunityMixin:SetCommunityInfo(clubId, streamInfo)
	self.clubId = clubId;
	self.streamId = streamInfo.streamId;
	self.streamInfo = streamInfo;

	self.Speaker:SetCommunityInfo(clubId, streamInfo);

	self:SetVoiceChannel(C_VoiceChat.GetChannelForCommunityStream(clubId, streamInfo.streamId));
end

-- Always return true because all community channels support voice (the channel isn't actually joined until the player clicks the activate button)
function ChannelButtonCommunityMixin:ChannelSupportsVoice()
	return true;
end

-- Headers
ChannelButtonHeaderMixin = CreateFromMixins(ChannelButtonBaseMixin);

function ChannelButtonHeaderMixin:Reset(pool)
	ChannelButtonBaseMixin.Reset(self, pool);
	self.Collapsed:Hide();
end

function ChannelButtonHeaderMixin:OnClick(button)
	ChannelButtonBaseMixin.OnClick(self, button);

	if button == "LeftButton" then
		self:SetCollapsed(not self:IsCollapsed());
		self:GetChannelList():Update();
	end
end

function ChannelButtonHeaderMixin:IsHeader()
	return true;
end

function ChannelButtonHeaderMixin:IsCollapsed()
	return self:GetChannelList():IsCollapsed(self:GetCategory());
end

function ChannelButtonHeaderMixin:SetCollapsed(collapsed)
	self:GetChannelList():SetCollapsed(self:GetCategory(), collapsed);
end

function ChannelButtonHeaderMixin:Update()
	ChannelButtonBaseMixin.Update(self);
	self.Text:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(self:GetChannelName()));

	if self:IsCollapsed() then
		self.Collapsed:SetAtlas("voicechat-channellist-category-plus");
	else
		self.Collapsed:SetAtlas("voicechat-channellist-category-minus");
	end

	local count = self:GetMemberCount(); -- Not ideal, this is actually the number of sub channels (TODO: At least ensure this includes voice channels soon)
	self.Collapsed:SetShown(count > 0);
	self:SetEnabled(count > 0);

	self.NormalTexture:SetAlpha(1);
end