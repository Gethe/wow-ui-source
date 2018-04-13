
local MAX_NUM_CHAT_LINES = 1000;
local REQUEST_MORE_MESSAGES_THRESHOLD = 30;

local COMMUNITIES_CHAT_FRAME_EVENTS = {
	"CLUB_MESSAGE_ADDED",
	"CLUB_MESSAGE_HISTORY_RECEIVED",
};

function GetCommunitiesChatPermissionOptions()
	return {
		{ text = COMMUNITIES_ALL_MEMBERS, value = false },
		{ text = COMMUNITIES_CHAT_PERMISSIONS_LEADERS_AND_MODERATORS, value = true },
	};
end

function CommunitiesChatPermissionsDropDownMenu_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.func = function(button, value, text)
		self:SetValue(value, text);
	end
	
	for _, permission in ipairs(GetCommunitiesChatPermissionOptions()) do
		info.text = permission.text;
		info.arg1 = permission.value;
		info.arg2 = permission.text;
		info.checked = self:GetValue() == permission.value;
		if info.checked then
			UIDropDownMenu_SetText(self, permission.text);
		end
		
		UIDropDownMenu_AddButton(info);
	end
end

CommunitiesChatMixin = {}

function CommunitiesChatMixin:OnLoad()
	self.MessageFrame:SetMaxLines(MAX_NUM_CHAT_LINES);
end

function CommunitiesChatMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_CHAT_FRAME_EVENTS);

	local function StreamSelectedCallback(event, streamId)
		self:DisplayChat();
	end

	self.streamSelectedCallback = StreamSelectedCallback;
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.streamSelectedCallback);
	
	self:UpdateChatColor();
end

function CommunitiesChatMixin:OnEvent(event, ...)
	if event == "CLUB_MESSAGE_ADDED" then
		local clubId, streamId, messageId = ...;
		if clubId == self:GetCommunitiesFrame():GetSelectedClubId() and streamId == self:GetCommunitiesFrame():GetSelectedStreamId() then
			local message = C_Club.GetMessageInfo(clubId, streamId, messageId);
			self:AddMessage(message);
		end
	elseif event == "CLUB_MESSAGE_HISTORY_RECEIVED" then
		local clubId, streamId, downloadedRange, contiguousRange = ...;
		if clubId == self:GetCommunitiesFrame():GetSelectedClubId() and streamId == self:GetCommunitiesFrame():GetSelectedStreamId() then
			if self.MessageFrame:GetNumMessages() > 0 then
				self:BackfillMessages(contiguousRange.oldestMessageId);
			else
				self:DisplayChat();
			end
		end
	end
end

function CommunitiesChatMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_CHAT_FRAME_EVENTS);
	if self.streamSelectedCallback then
		self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.streamSelectedCallback);
		self.streamSelectedCallback = nil;
	end
end

function CommunitiesChatMixin:SendMessage(text)
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
	if (clubId ~= nil and streamId ~= nil and C_Club.IsSubscribedToStream(clubId, streamId)) then
		C_Club.SendMessage(clubId, streamId, text);
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

	local newestMessageId = ranges[#ranges].newestMessageId;
	self.messageRangeOldest = ranges[#ranges].oldestMessageId;
	
	return C_Club.GetMessagesInRange(clubId, streamId, self.messageRangeOldest, newestMessageId);
end

function CommunitiesChatMixin:BackfillMessages(newOldestMessage)
	if newOldestMessage == self.messageRangeOldest then
		return;
	end
	
	local clubId = self:GetCommunitiesFrame():GetSelectedClubId();
	local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
	if not clubId or not streamId then
		return;
	end
	
	local messages = C_Club.GetMessagesInRange(clubId, streamId, newOldestMessage, self.messageRangeOldest);
	for index = #messages - 1, 1, -1 do
		local message = messages[index];
		self:BackFillMessage(message);
	end
	
	self.messageRangeOldest = newOldestMessage;
	
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
			-- TODO:: This is temporary. Jeff is going to mock up a better display.
			self.MessageFrame:AddMessage("--------------- Unread ---------------");
			streamViewMarker = nil;
		end
		
		self:AddMessage(message);
	end
	
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
	
	if clubInfo.clubType == Enum.ClubType.BattleNet then
		return BATTLENET_FONT_COLOR:GetRGB();
	else
		local streamId = self:GetCommunitiesFrame():GetSelectedStreamId();
		if not streamId then
			return nil;
		end
		
		return Chat_GetCommunitiesChannelColor(clubId, streamId);
	end
end

function CommunitiesChatMixin:FormatMessage(message)
	if message.author.classID then
		local classInfo = C_CreatureInfo.GetClassInfo(message.author.classID);
		if classInfo then
			local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile];
			return COMMUNITIES_CHAT_MESSAGE_FORMAT_CHARACTER:format(classColorInfo.colorStr, message.author.name, message.content);
		end
	end
	
	return COMMUNITIES_CHAT_MESSAGE_FORMAT:format(message.author.name, message.content);
end

function CommunitiesChatMixin:BackfillMessage(message)
	local r, g, b = self:GetChatColor();
	if not r then
		r, g, b = DEFAULT_CHAT_CHANNEL_COLOR:GetRGB();
	end
	
	self.MessageFrame:BackFillMessage(self:FormatMessage(message), r, g, b);
end

function CommunitiesChatMixin:AddMessage(message)
	local r, g, b = self:GetChatColor();
	if not r then
		r, g, b = DEFAULT_CHAT_CHANNEL_COLOR:GetRGB();
	end

	self.MessageFrame:AddMessage(self:FormatMessage(message), r, g, b);
end

function CommunitiesChatMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesChatEditBox_OnEnterPressed(self)
	local message = self:GetText();
	if message ~= "" then
		self:GetParent().Chat:SendMessage(message);
		self:SetText("");
	else
		-- If you hit enter on a blank line, deselect this edit box.
		self:ClearFocus();
	end
end

CommunitiesChatPermissionsDropDownMenuMixin = {};

function CommunitiesChatPermissionsDropDownMenuMixin:SetValue(newValue, newText)
	self.value = newValue;
	UIDropDownMenu_SetText(self, newText);
end

function CommunitiesChatPermissionsDropDownMenuMixin:GetValue()
	return self.value;
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
		local min, max = self:GetMinMaxValues();
		self:GetParent():SetScrollOffset(max - value);
	end
	
	local communitiesChatFrame = self:GetParent():GetParent();
	-- If we don't have many messages left, request more from the server.
	-- TODO:: We should support for viewing more messages beyond what we can display at one time.
	-- This will require support for requesting more messages as we scroll back down to the most recent messages.
	if value <= REQUEST_MORE_MESSAGES_THRESHOLD and communitiesChatFrame.MessageFrame:GetNumMessages() < MAX_NUM_CHAT_LINES then
		local communitiesFrame = communitiesChatFrame:GetCommunitiesFrame();
		local clubId = communitiesFrame:GetSelectedClubId();
		local streamId = communitiesFrame:GetSelectedStreamId();
		if clubId ~= nil and streamId ~= nil then
			C_Club.RequestMoreMessagesBefore(clubId, streamId, nil);
		end
	end
end

function CommunitiesJumpToUnreadButton_OnClick(self)
end