
local MAX_NUM_CHAT_LINES = 5000; -- The maximum number of messages we'll display in the chat frame before we stop asking for more history.
local MAX_NUM_CHAT_LINES_PER_REQUEST = 100; -- The maximum number we'll request from history at one time.
local REQUEST_MORE_MESSAGES_THRESHOLD = 30; -- How close to the top of the scroll bar you have to be before we request more messages.

local COMMUNITIES_CHAT_FRAME_EVENTS = {
	"CLUB_MESSAGE_ADDED",
	"CLUB_MESSAGE_UPDATED",
	"CLUB_MESSAGE_HISTORY_RECEIVED",
	"CLUB_UPDATED",
	"CLUB_STREAM_SUBSCRIBED",
};

function GetCommunitiesChatPermissionOptions()
	return {
		{ text = COMMUNITIES_ALL_MEMBERS, value = false },
		{ text = COMMUNITIES_CHAT_PERMISSIONS_LEADERS_AND_MODERATORS, value = true },
	};
end

CommunitiesChatMixin = {}

function CommunitiesChatMixin:OnLoad()
	self.MessageFrame:SetMaxLines(MAX_NUM_CHAT_LINES);
	self.MessageFrame:SetFont(DEFAULT_CHAT_FRAME:GetFont());
	self.pendingMemberInfo = {};
	self.broadcastSent = {};
	self.eventsSent = {};
end

function CommunitiesChatMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_CHAT_FRAME_EVENTS);

	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.OnStreamSelected, self);
	
	self:UpdateChatColor();
	self:DisplayChat();
end

function CommunitiesChatMixin:OnEvent(event, ...)
	if event == "CLUB_MESSAGE_ADDED" then
		local clubId, streamId, messageId = ...;
		if clubId == self:GetCommunitiesFrame():GetSelectedClubId() and streamId == self:GetCommunitiesFrame():GetSelectedStreamId() then
			local message = C_Club.GetMessageInfo(clubId, streamId, messageId);
			self:AddMessage(clubId, streamId, message);
			self:UpdateScrollbar();
		end
	elseif event == "CLUB_MESSAGE_HISTORY_RECEIVED" then
		local clubId, streamId, downloadedRange, contiguousRange = ...;
		if clubId == self:GetCommunitiesFrame():GetSelectedClubId() and streamId == self:GetCommunitiesFrame():GetSelectedStreamId() then
			if self.MessageFrame:GetNumMessages() > 0 then
				self:BackfillMessages(MAX_NUM_CHAT_LINES_PER_REQUEST);
			else
				self:DisplayChat();
			end
		end
		
		self.requestedMoreHistory = false;
	elseif event == "CLUB_MESSAGE_UPDATED" then
		local clubId, streamId, messageIdToUpdate = ...;
		local function DoesMessageMatchId(message, r, g, b, messageClubId, messageStreamId, messageId, messageMemberId, ...)
			return messageClubId == clubId and messageStreamId == streamId and messageId.epoch == messageIdToUpdate.epoch and messageId.position == messageIdToUpdate.position;
		end
		
		self:RefreshMessages(DoesMessageMatchId);
	elseif event == "CLUB_MEMBER_UPDATED" then
		local clubId, memberId = ...;
		if self.pendingMemberInfo[clubId] and tContains(self.pendingMemberInfo[clubId], memberId) then
			local function IsMessageFromMember(message, r, g, b, messageClubId, messageStreamId, messageId, messageMemberId, ...)
				return messageClubId == clubId and messageMemberId == memberId;
			end
			
			self:RefreshMessages(IsMessageFromMember);
			tDeleteItem(self.pendingMemberInfo[clubId], memberId);

			if #self.pendingMemberInfo[clubId] == 0 then
				self.pendingMemberInfo[clubId] = nil;
				
				local allEmpty = true;
				for clubId, memberIds in pairs(self.pendingMemberInfo) do
					allEmpty = false;
					break;
				end
				
				if allEmpty then
					self:UnregisterEvent("CLUB_MEMBER_UPDATED");
				end
			end
		end
	elseif event == "CLUB_UPDATED" then
		local clubId = ...;
		if clubId == self:GetCommunitiesFrame():GetSelectedClubId() then
			self:AddBroadcastMessage(clubId);
		end
	elseif event == "CLUB_STREAM_SUBSCRIBED" then
		local clubId, streamId = ...;
		local communitiesFrame = self:GetCommunitiesFrame();
		if clubId == communitiesFrame:GetSelectedClubId() and streamId == communitiesFrame:GetSelectedStreamId() then
			self:RequestInitialMessages(clubId, streamId);
		end
	end
end

function CommunitiesChatMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_CHAT_FRAME_EVENTS);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self);
end

function CommunitiesChatMixin:OnStreamSelected(streamID)
	self:DisplayChat();
end

function CommunitiesChatMixin:SendMessage(text)
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
	if (clubId ~= nil and streamId ~= nil and C_Club.IsSubscribedToStream(clubId, streamId)) then
		local streamInfo = C_Club.GetStreamInfo(clubId, streamId);
		if not streamInfo then
			return;
		end
		
		if streamInfo.streamType == Enum.ClubStreamType.Guild and not C_GuildInfo.CanSpeakInGuildChat() then
			self.MessageFrame:AddMessage(ERR_GUILD_PERMISSIONS, YELLOW_FONT_COLOR:GetRGB());
			ChatFrame_DisplaySystemMessageInPrimary(ERR_GUILD_PERMISSIONS);
			return;
		end
		
		C_Club.SendMessage(clubId, streamId, text);
	elseif clubId ~= nil and C_Club.IsAccountMuted(clubId) then
		UIErrorsFrame:AddExternalErrorMessage(ERR_PARENTAL_CONTROLS_CHAT_MUTED);
	end
end

function CommunitiesChatMixin:GetMessagesToDisplay()
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
	if not clubId or not streamId then
		return nil;
	end
	
	local ranges = C_Club.GetMessageRanges(clubId, streamId);
	if not ranges or #ranges == 0 then
		return nil;
	end
	
	local currentRange = ranges[#ranges];
	local oldestMessageId = currentRange.oldestMessageId;
	local newestMessageId = currentRange.newestMessageId;
	if newestMessageId.epoch < oldestMessageId.epoch then
		return nil;
	end
	
	return C_Club.GetMessagesBefore(clubId, streamId, newestMessageId, MAX_NUM_CHAT_LINES_PER_REQUEST);
end

function CommunitiesChatMixin:HasAllMessages(clubId, streamId)
	return self.messageRangeOldest and C_Club.IsBeginningOfStream(clubId, streamId, self.messageRangeOldest);
end

local function RangeIsEmpty(range)
	return range.newestMessageId.epoch < range.oldestMessageId.epoch or (range.newestMessageId.epoch == range.oldestMessageId.epoch and range.newestMessageId.position < range.oldestMessageId.position);
end

function CommunitiesChatMixin:RequestInitialMessages(clubId, streamId)
	local ranges = C_Club.GetMessageRanges(clubId, streamId);
	if (not ranges or #ranges == 0 or RangeIsEmpty(ranges[#ranges])) then
		C_Club.RequestMoreMessagesBefore(clubId, streamId, nil);
		self.requestedMoreHistory = true;
	else
		self.requestedMoreHistory = false;
	end
end

function CommunitiesChatMixin:RequestMoreHistory()
	local communitiesFrame = self:GetCommunitiesFrame();
	local clubId = communitiesFrame:GetSelectedClubId();
	local streamId = communitiesFrame:GetSelectedStreamId();
	if clubId == nil or streamId == nil then
		return;
	end

	if self.requestedMoreHistory or self:HasAllMessages(clubId, streamId) then
		return;
	end
	
	local hasMessages = C_Club.RequestMoreMessagesBefore(clubId, streamId, self.messageRangeOldest, MAX_NUM_CHAT_LINES_PER_REQUEST);
	if hasMessages then
		self:BackfillMessages(MAX_NUM_CHAT_LINES_PER_REQUEST);
	else
		self.requestedMoreHistory = true;
	end
end

local function MessageIsEqual(messageId, compareMessageId)
	return messageId.epoch == compareMessageId.epoch and messageId.position == messageId.position;
end

function CommunitiesChatMixin:BackfillMessages(maxCount)
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
	if not clubId or not streamId then
		return;
	end
	
	local messages = C_Club.GetMessagesBefore(clubId, streamId, self.messageRangeOldest, maxCount);
	if #messages == 0 then
		return;
	end
	
	local lastIndex = #messages - (MessageIsEqual(messages[#messages].messageId, self.messageRangeOldest) and 1 or 0);
	for index = lastIndex, 1, -1 do
		local message = messages[index];
		self:AddMessage(clubId, streamId, message, true);
	end
	
	self.messageRangeOldest = messages[1].messageId;
	
	self:UpdateScrollbar();
end

function CommunitiesChatMixin:DisplayChat()
	self.MessageFrame:Clear();
	local messages = self:GetMessagesToDisplay();
	if not messages then
		return;
	end
	
	if #messages == 0 then
		return;
	end
	
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
	if not clubId or not streamId then
		return;
	end
	
	local streamViewMarker = C_Club.GetStreamViewMarker(clubId, streamId);
	for index, message in ipairs(messages) do
		if streamViewMarker and message.messageId.epoch > streamViewMarker then
			-- TODO:: We also need to add this while backfilling messages.
			self:AddUnreadNotification();
			streamViewMarker = nil;
		end
		
		self:AddMessage(clubId, streamId, message);
	end
	
	self.messageRangeOldest = messages[1].messageId;
	
	self:AddBroadcastMessage(clubId);
	self:AddUpcomingEventMessages(clubId);
	self:AddOngoingEventMessages(clubId);
	
	C_Club.AdvanceStreamViewMarker(clubId, streamId);
	self:UpdateScrollbar();
end

function CommunitiesChatMixin:UpdateScrollbar()
	local numMessages = self.MessageFrame:GetNumMessages();
	local maxValue = math.max(numMessages, 1);
	self.MessageFrame.ScrollBar:SetMinMaxValues(1, maxValue);
	self.MessageFrame.ScrollBar:SetValue(maxValue - self.MessageFrame:GetScrollOffset());
end

function CommunitiesChatMixin:UpdateChatColor()
	local r, g, b = self:GetChatColor();
	if not r then
		return;
	end
	
	local function TransformColor()
		return true, r, g, b;
	end
	self.MessageFrame:AdjustMessageColors(TransformColor);
end

function CommunitiesChatMixin:GetChatColor()
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	if not clubId then
		return nil;
	end
	
	local clubInfo = C_Club.GetClubInfo(clubId);
	if not clubInfo then
		return nil;
	end
	
	local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
	if not streamId then
		return nil;
	end
	
	return Chat_GetCommunitiesChannelColor(clubId, streamId);
end

function CommunitiesChatMixin:FormatMessage(clubId, streamId, message)
	local name = message.author.name or " ";
	local link;
	if message.author.clubType == Enum.ClubType.BattleNet then
		link = GetBNPlayerCommunityLink(name, name, message.author.bnetAccountId, clubId, streamId, message.messageId.epoch, message.messageId.position);
	elseif message.author.clubType == Enum.ClubType.Character or message.author.clubType == Enum.ClubType.Guild then
		local classInfo = message.author.classID and C_CreatureInfo.GetClassInfo(message.author.classID);
		if classInfo then
			local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile];
			link = GetPlayerCommunityLink(name, WrapTextInColorCode(name, classColorInfo.colorStr), clubId, streamId, message.messageId.epoch, message.messageId.position);
		else
			link = GetPlayerCommunityLink(name, name, clubId, streamId, message.messageId.epoch, message.messageId.position);
		end
	end
	
	local content;
	if message.destroyed then
		if message.destroyer and message.destroyer.name then
			content = GRAY_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_CHAT_MESSAGE_DESTROYED_BY:format(message.destroyer.name));
		else
			content = GRAY_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_CHAT_MESSAGE_DESTROYED);
		end
	elseif message.edited then
		content = COMMUNITIES_CHAT_MESSAGE_EDITED_FMT:format(message.content, GRAY_FONT_COLOR:WrapTextInColorCode(COMMUNITIES_CHAT_MESSAGE_EDITED));
	else
		content = message.content;
	end
	
	if CHAT_TIMESTAMP_FORMAT then
		return BetterDate(CHAT_TIMESTAMP_FORMAT, message.messageId.epoch / 1000000)..COMMUNITIES_CHAT_MESSAGE_FORMAT:format(link or name, content);
	else
		return COMMUNITIES_CHAT_MESSAGE_FORMAT:format(link or name, content);
	end
end

function CommunitiesChatMixin:AddDateNotification(calendarTime, backfill)
	local notification = nil;
	local today = C_DateAndTime.GetCurrentCalendarTime();
	local yesterday = C_DateAndTime.AdjustTimeByDays(today, -1);
	if CalendarUtil.AreDatesEqual(today, calendarTime) then
		notification = COMMUNITIES_CHAT_FRAME_TODAY_NOTIFICATION;
	elseif CalendarUtil.AreDatesEqual(yesterday, calendarTime) then
		notification = COMMUNITIES_CHAT_FRAME_YESTERDAY_NOTIFICATION;
	else
		notification = CalendarUtil.FormatCalendarTimeWeekday(calendarTime);
	end
	
	self:AddNotification(notification, "communities-chat-date-line", 0.4, 0.4, 0.4, backfill);
end

function CommunitiesChatMixin:AddUnreadNotification(backfill)
	local r, g, b = ORANGE_FONT_COLOR:GetRGB();
	self:AddNotification(COMMUNITIES_CHAT_FRAME_UNREAD_MESSAGES_NOTIFICATION, "communities-chat-date-line-orange", r, g, b, backfill);
end

local NOTIFICATION_LINE_TEXTURE_SIZE_Y = 8;
local NOTIFICATION_LINE_TEXTURE_SIZE_X = 165;
function CommunitiesChatMixin:AddNotification(notification, atlas, r, g, b, backfill)
	local textureMarkup = CreateAtlasMarkup(atlas, NOTIFICATION_LINE_TEXTURE_SIZE_X, NOTIFICATION_LINE_TEXTURE_SIZE_Y, 0, 3);
	if backfill then
		self.MessageFrame:BackFillMessage(textureMarkup, 1, 1, 1);
		self.MessageFrame:BackFillMessage(notification, r, g, b);
		self.MessageFrame:BackFillMessage(" ");
		self.MessageFrame:BackFillMessage(" ");
	else
		self.MessageFrame:AddMessage(" ");
		self.MessageFrame:AddMessage(" ");
		self.MessageFrame:AddMessage(notification, r, g, b);
		self.MessageFrame:AddMessage(textureMarkup, 1, 1, 1);
	end
end

function CommunitiesChatMixin:AddBroadcastMessage(clubId)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo and clubInfo.broadcast ~= "" then
		if self.broadcastSent[clubId] == clubInfo.broadcast then
			return;
		end
		
		self.MessageFrame:AddMessage(" ");
		self.MessageFrame:AddMessage(COMMUNITIES_MESSAGE_OF_THE_DAY_FORMAT:format(clubInfo.broadcast), YELLOW_FONT_COLOR:GetRGB());
		self.broadcastSent[clubId] = clubInfo.broadcast;
	end
end

local DEFAULT_NUM_DAYS_TO_PREVIEW_IN_CHAT = 4;
function CommunitiesChatMixin:AddUpcomingEventMessages(clubId)
	if not self.eventsSent[clubId] then
		self.eventsSent[clubId] = {};
	end

	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
	
	-- Only include events that are happening in the future. Ongoing events will be broadcast separately.
	currentCalendarTime.minute = currentCalendarTime.minute + 1;
	
	local events = C_Calendar.GetClubCalendarEvents(clubId, currentCalendarTime, C_DateAndTime.AdjustTimeByDays(currentCalendarTime, DEFAULT_NUM_DAYS_TO_PREVIEW_IN_CHAT));
	for i, event in ipairs(events) do
		local eventBroadcast = CalendarUtil.GetEventBroadcastText(event);
		if self.eventsSent[clubId][event.eventID] ~= eventBroadcast then
			self.MessageFrame:AddMessage(eventBroadcast);
			self.eventsSent[clubId][event.eventID] = eventBroadcast;
		end
	end
end

local NUM_MINUTES_TO_DISPLAY_ONGOING = 30;
function CommunitiesChatMixin:AddOngoingEventMessages(clubId)
	if not self.eventsSent[clubId] then
		self.eventsSent[clubId] = {};
	end

	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
	local events = C_Calendar.GetClubCalendarEvents(clubId, C_DateAndTime.AdjustTimeByMinutes(currentCalendarTime, -NUM_MINUTES_TO_DISPLAY_ONGOING), currentCalendarTime);
	for i, event in ipairs(events) do
		local eventBroadcast = CalendarUtil.GetOngoingEventBroadcastText(event);
		if self.eventsSent[clubId][event.eventID] ~= eventBroadcast then
			self.MessageFrame:AddMessage(eventBroadcast);
			self.eventsSent[clubId][event.eventID] = eventBroadcast;
		end
	end
end

function CommunitiesChatMixin:AddMessage(clubId, streamId, message, backfill)
	local r, g, b = self:GetChatColor();
	if not r then
		r, g, b = DEFAULT_CHAT_CHANNEL_COLOR:GetRGB();
	end
	
	if not message.author.name then
		self:RegisterForMemberUpdate(clubId, message.author.memberId);
	end
	
	local messageDate = C_DateAndTime.GetCalendarTimeFromEpoch(message.messageId.epoch);
	local previousMessageId = select(7, self.MessageFrame:GetMessageInfo(backfill and 1 or self.MessageFrame:GetNumMessages()));
	local previousMessageDate = previousMessageId and C_DateAndTime.GetCalendarTimeFromEpoch(previousMessageId.epoch);
	if previousMessageDate and (messageDate.monthDay ~= previousMessageDate.monthDay or messageDate.month ~= previousMessageDate.month) then
		self:AddDateNotification(backfill and previousMessageDate or messageDate, backfill);
	end
	
	if backfill then
		self.MessageFrame:BackFillMessage(self:FormatMessage(clubId, streamId, message), r, g, b, clubId, streamId, message.messageId, message.author.memberId);
	else
		self.MessageFrame:AddMessage(self:FormatMessage(clubId, streamId, message), r, g, b, clubId, streamId, message.messageId, message.author.memberId);
	end
end

function CommunitiesChatMixin:RegisterForMemberUpdate(clubId, memberId)
	if self.pendingMemberInfo[clubId] ~= nil and tContains(self.pendingMemberInfo[clubId], memberId) then
		return;
	end
	
	if not self:IsEventRegistered("CLUB_MEMBER_UPDATED") then
		self:RegisterEvent("CLUB_MEMBER_UPDATED");
	end
	
	self.pendingMemberInfo[clubId] = self.pendingMemberInfo[clubId] or {};
	table.insert(self.pendingMemberInfo[clubId], memberId);
end

function CommunitiesChatMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesChatMixin:RefreshMessages(predicate)
	local function RefreshMessage(message, r, g, b, messageClubId, messageStreamId, messageId, messageMemberId, ...)
		local messageInfo = C_Club.GetMessageInfo(messageClubId, messageStreamId, messageId);
		return self:FormatMessage(messageClubId, messageStreamId, messageInfo), r, g, b, messageClubId, messageStreamId, messageId, messageMemberId, ...;
	end

	self.MessageFrame:TransformMessages(predicate, RefreshMessage);
end

function CommunitiesChatEditBox_OnFocusGained(self)
	EditBox_HighlightText(self);
	ChatFrame_SetChatFocusOverride(self);
end

function CommunitiesChatEditBox_OnEnterPressed(self)
	local message = self:GetText();
	if message ~= "" then
		self:GetParent().Chat:SendMessage(message);
		self:SetText("");
	end
	
	self:ClearFocus();
end

function CommunitiesChatEditBox_OnHide(self)
	if ChatFrame_GetChatFocusOverride() == self then
		ChatFrame_ClearChatFocusOverride();
	end
end

function CommunitiesChatFrameScrollBar_OnValueChanged(self, value, userInput)
	self.ScrollUp:Enable();
	self.ScrollDown:Enable();

	local minVal, maxVal = self:GetMinMaxValues();
	if value >= maxVal then
		self.thumbTexture:Show();
		self.ScrollDown:Disable()
	end
	if value <= minVal then
		self.thumbTexture:Show();
		self.ScrollUp:Disable();
	end
	
	if userInput then
		self:GetParent():SetScrollOffset(maxVal - value);
	end
	
	local communitiesChatFrame = self:GetParent():GetParent();
	-- If we don't have many messages left, request more from the server.
	-- TODO:: We should support for viewing more messages beyond what we can display at one time.
	-- This will require support for requesting more messages as we scroll back down to the most recent messages.
	if value <= REQUEST_MORE_MESSAGES_THRESHOLD and communitiesChatFrame.MessageFrame:GetNumMessages() < MAX_NUM_CHAT_LINES then
		communitiesChatFrame:RequestMoreHistory();
	end
end

function CommunitiesJumpToUnreadButton_OnClick(self)
end