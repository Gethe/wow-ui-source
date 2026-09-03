
local HARDCORE_DEATHS_COLOR = CreateColor(1.0, 0.2, 0.2);

-- Of these text configuration parameters only maxTextHeight is exposed as an XML KeyValue for now.
-- The others can be exposed as needed.
local FADE_IN_TIME = 0.2;
local FADE_OUT_TIME = 3.0;
local MIN_TEXT_HEIGHT = 20;
local DEFAULT_MAX_TEXT_HEIGHT = 30;
local TEXT_SCALE_UP_TIME = 0.2;
local TEXT_SCALE_DOWN_TIME = 0.4;
local DEFAULT_HOLD_TIME = 10.0;

-- We limit the total number of messages. Overridable via XML KeyValues.
local DEFAULT_MAX_MESSAGE_SLOTS = 4;

-- We reserve some slots for each type. Overridable via XML KeyValues.
local DEFAULT_MIN_RESERVED_SLOTS = 2;

-- We want to show at most 5 text lines to avoid covering the screen.
-- MAX_TOTAL_LINES should be bigger than message slots so we always have
-- at least 2 lines of text for the latest message.
-- Overridable via XML KeyValues.
local DEFAULT_MAX_TOTAL_LINES = 5;

local function GetHoldTime(displayTime)
	if not displayTime or displayTime == 0 then
		return DEFAULT_HOLD_TIME;
	end

	return math.max(displayTime - FADE_OUT_TIME, 1.0);
end

RaidWarningFrameMixin = {};

local function ResetString(_pool, fontString)
	FadingFrame_StopTextScaling(fontString);
	fontString:Hide();
	fontString:ClearAllPoints();
	fontString:SetMaxLines(0);
	fontString.messageType = nil;
	fontString.messageOrder = nil;
end

function RaidWarningFrameMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function RaidWarningFrameMixin:UpdateShownState(skipLayoutUpdated)
	local wasShown = self:IsShown();
	local hasMessage = (self.fontStringPool:GetNumActive() > 0);
	self:SetShown(self.isInEditMode or hasMessage);

	if not skipLayoutUpdated and (wasShown ~= self:IsShown()) then
		self:OnLayoutUpdated();
	end
end

function RaidWarningFrameMixin:OnLoad()
	self.fontStringPool = CreateFontStringPool(self, "ARTWORK", 0, "GameFontNormalHuge", ResetString);
	self.messageCounter = 0;

	self.maxMessageSlots = self.maxMessageSlots or DEFAULT_MAX_MESSAGE_SLOTS;
	self.minReservedSlots = self.minReservedSlots or DEFAULT_MIN_RESERVED_SLOTS;
	self.maxTotalLines = self.maxTotalLines or DEFAULT_MAX_TOTAL_LINES;
	self.maxTextHeight = self.maxTextHeight or DEFAULT_MAX_TEXT_HEIGHT;
	self:SetHeight(MIN_TEXT_HEIGHT * self.maxTotalLines);

	self.messageTypes = self.messageTypes or RaidWarningUtil.MessageTypes.Standard;

	local numIncludedTypes = #self.messageTypes;
	assertsafe(self.maxTotalLines >= self.maxMessageSlots, "maxTotalLines (%d) must be >= maxMessageSlots (%d).", self.maxTotalLines, self.maxMessageSlots);
	assertsafe(self.maxMessageSlots >= (self.minReservedSlots * numIncludedTypes), "maxMessageSlots (%d) must be >= minReservedSlots (%d) * numIncludedTypes (%d).", self.maxMessageSlots, self.minReservedSlots, numIncludedTypes);

	self:RegisterMessageEvents();
end

-- Note: all event cases are defined here but only the relevant events should be
-- registered based on self.messageTypes.
function RaidWarningFrameMixin:OnEvent(event, ...)
	if event == "CHAT_MSG_RAID_WARNING" then
		local message = ...;
		message = C_ChatInfo.ReplaceIconAndGroupExpressions(message);
		self:AddMessage(message, ChatTypeInfo["RAID_WARNING"]);
		PlaySound(SOUNDKIT.RAID_WARNING);
	elseif event == "HARDCORE_DEATHS" then
		-- Note: This event should only fire on hardcore realms where it's relevant.
		local message = ...;
		self:AddMessage(message, HARDCORE_DEATHS_COLOR);
	elseif event == "RAID_BOSS_EMOTE" or event == "RAID_BOSS_WHISPER" then
		local message, playerName, displayTime, playSound = ...;

		local body = format(message, playerName, playerName);
		local info = ChatTypeInfo[event];
		self:AddMessage(body, info, displayTime, RaidWarningUtil.MessageType.BossEmote);

		if playSound then
			if event == "RAID_BOSS_WHISPER" then
				PlaySound(SOUNDKIT.UI_RAID_BOSS_WHISPER_WARNING);
			else
				PlaySound(SOUNDKIT.RAID_BOSS_EMOTE_WARNING);
			end
		end
	elseif event == "CLEAR_BOSS_EMOTES" then
		self:ClearMessages(RaidWarningUtil.MessageType.BossEmote);
	elseif event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" or event == "CHAT_MSG_BG_SYSTEM_HORDE" then
		local message = ...;
		local info = ChatTypeInfo["BG_SYSTEM_NEUTRAL"];
		if event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" then
			info = ChatTypeInfo["BG_SYSTEM_ALLIANCE"];
		elseif event == "CHAT_MSG_BG_SYSTEM_HORDE" then
			info = ChatTypeInfo["BG_SYSTEM_HORDE"];
		end
		self:AddMessage(message, info, self.defaultDisplayTime, RaidWarningUtil.MessageType.BGSystem);
	end
end

function RaidWarningFrameMixin:OnUpdate(elapsed)
	local needsLayout = false;
	local toRelease = {};

	for fontString in self.fontStringPool:EnumerateActive() do
		FadingFrame_UpdateTextScaling(fontString, elapsed);
		FadingFrame_OnUpdate(fontString);

		if not fontString:IsShown() then
			table.insert(toRelease, fontString);
			needsLayout = true;
		end
	end

	for _i, fontString in ipairs(toRelease) do
		self.fontStringPool:Release(fontString);
	end

	local shouldUpdateLayout = self:IsShown() and needsLayout;
	if self.fontStringPool:GetNumActive() == 0 then
		-- We need skipLayoutUpdated here if we're going to UpdateLayout below.
		self:UpdateShownState(shouldUpdateLayout);
	end

	if shouldUpdateLayout then
		self:UpdateLayout();
	end
end

function RaidWarningFrameMixin:RegisterMessageEvents()
	for _i, messageType in ipairs(self.messageTypes) do
		for _j, event in ipairs(RaidWarningUtil.MessageTypeEvents[messageType]) do
			self:RegisterEvent(event);
		end
	end
end

function RaidWarningFrameMixin:AcquireString()
	local fontString, isNew = self.fontStringPool:Acquire();
	if isNew then
		fontString:SetWidth(self:GetWidth());
		fontString:SetJustifyH("CENTER");
		FadingFrame_InitSlot(fontString, FADE_IN_TIME, FADE_OUT_TIME, MIN_TEXT_HEIGHT, self.maxTextHeight, TEXT_SCALE_UP_TIME, TEXT_SCALE_DOWN_TIME);
	end

	return fontString;
end

function RaidWarningFrameMixin:FindSlotToEvict(incomingType)
	local typeCounts = {};
	for fontString in self.fontStringPool:EnumerateActive() do
		typeCounts[fontString.messageType] = (typeCounts[fontString.messageType] or 0) + 1;
	end

	-- Find the oldest fontString we can replace while preserving self.minReservedSlots.
	local oldestOverMinimum = nil;
	for fontString in self.fontStringPool:EnumerateActive() do
		local messageType = fontString.messageType;
		local sameType = (messageType == incomingType);

		-- If this is the same type we only need minReservedSlots since we're replacing "in place" but
		-- for other types we need to have more than minReservedSlots to replace a message.
		local required = sameType and self.minReservedSlots or (self.minReservedSlots + 1);
		if typeCounts[messageType] >= required then
			if not oldestOverMinimum or (fontString.messageOrder < oldestOverMinimum.messageOrder) then
				oldestOverMinimum = fontString;
			end
		end
	end

	return oldestOverMinimum;
end

function RaidWarningFrameMixin:AcquireOrEvictSlot(messageType)
	if self.fontStringPool:GetNumActive() < self.maxMessageSlots then
		return self:AcquireString();
	end

	local evictedFontString = self:FindSlotToEvict(messageType);
	self.fontStringPool:Release(evictedFontString);

	return self:AcquireString();
end

function RaidWarningFrameMixin:AddMessage(textString, colorInfo, displayTime, messageType)
	messageType = messageType or RaidWarningUtil.MessageType.RaidWarning;

	local fontString = self:AcquireOrEvictSlot(messageType);
	fontString:SetText(textString);
	fontString:SetTextColor(colorInfo.r, colorInfo.g, colorInfo.b, 1.0);
	fontString:SetTextHeight(MIN_TEXT_HEIGHT);
	fontString.messageType = messageType;

	-- We need to know the relative order of messages for eviction and layout.
	-- messageCounter continues increasing indefinitely.
	self.messageCounter = self.messageCounter + 1;
	fontString.messageOrder = self.messageCounter;

	local holdTime = GetHoldTime(displayTime);
	FadingFrame_SetHoldTime(fontString, holdTime);
	FadingFrame_Show(fontString);
	FadingFrame_StartTextScaling(fontString);

	self:Show();
	self:EnforceLineLimits(fontString);
	self:UpdateLayout();
end

function RaidWarningFrameMixin:EnforceLineLimits(newestFontString)
	local totalLines = 0;
	for fontString in self.fontStringPool:EnumerateActive() do
		fontString:SetMaxLines(0);
		totalLines = totalLines + fontString:GetNumLines();
	end

	local excessLines = totalLines - self.maxTotalLines;
	if excessLines <= 0 then
		return;
	end

	-- Truncate messages starting from the top until we're under the limit.
	local truncationOrder = self:GetSortedMessages();
	for _i, fontString in ipairs(truncationOrder) do
		if fontString ~= newestFontString then
			local currentLines = fontString:GetNumLines();
			if currentLines > 1 then
				local linesToFree = math.min(currentLines - 1, excessLines);
				fontString:SetMaxLines(currentLines - linesToFree);
				excessLines = excessLines - linesToFree;
				if excessLines <= 0 then
					return;
				end
			end
		end
	end

	-- If we're still not under the limit, truncate the newest message as well.
	-- Note: the newestMessage will always have at least (self.maxTotalLines - self.maxMessageSlots) lines.
	local newestLines = newestFontString:GetNumLines();
	local maxLines = math.max(newestLines - excessLines, 1);
	newestFontString:SetMaxLines(maxLines);
end

function RaidWarningFrameMixin:ClearMessages(messageType)
	if not messageType then
		self.fontStringPool:ReleaseAll();
	else
		local toRelease = {};
		for fontString in self.fontStringPool:EnumerateActive() do
			if fontString.messageType == messageType then
				table.insert(toRelease, fontString);
			end
		end

		for _i, fontString in ipairs(toRelease) do
			self.fontStringPool:Release(fontString);
		end
	end

	if self.fontStringPool:GetNumActive() == 0 then
		local skipLayoutUpdated = true;
		self:UpdateShownState(skipLayoutUpdated);
	end

	self:UpdateLayout();
end

local function SortMessages(a, b)
	local priorityA = RaidWarningUtil.MessageTypePriority[a.messageType];
	local priorityB = RaidWarningUtil.MessageTypePriority[b.messageType];
	if priorityA ~= priorityB then
		return priorityA < priorityB;
	end

	return a.messageOrder < b.messageOrder;
end

function RaidWarningFrameMixin:GetSortedMessages()
	local sorted = {};
	for fontString in self.fontStringPool:EnumerateActive() do
		table.insert(sorted, fontString);
	end

	table.sort(sorted, SortMessages);
	return sorted;
end

function RaidWarningFrameMixin:UpdateLayout()
	local sortedMessages = self:GetSortedMessages();
	for i, fontString in ipairs(sortedMessages) do
		fontString:ClearAllPoints();
		if i == 1 then
			fontString:SetPoint("TOP", self, "TOP");
		else
			local previousFontString = sortedMessages[i - 1];
			fontString:SetPoint("TOP", previousFontString, "BOTTOM");
		end
	end

	self:OnLayoutUpdated();
end

function RaidWarningFrameMixin:OnLayoutUpdated()
	-- Override to respond when the message layout has changed.
end

function RaidWarningFrameMixin:GetFirstMessage()
	local sortedMessages = self:GetSortedMessages();
	return sortedMessages[1];
end

function RaidWarningFrameMixin:GetLowestMessage()
	local sortedMessages = self:GetSortedMessages();
	return sortedMessages[#sortedMessages];
end

function RaidWarningFrameMixin:GetActiveMessageCount()
	return self.fontStringPool:GetNumActive();
end

GlobalRaidWarningFrameMixin = {};

function GlobalRaidWarningFrameMixin:OnLoad()
	RaidWarningFrameMixin.OnLoad(self);
	EditModeSystemMixin.OnSystemLoad(self);
end

function GlobalRaidWarningFrameMixin:OnLayoutUpdated()
	-- Overrides RaidWarningFrameMixin.

	RaidWarningUtil.UpdateCenterScreenAnchors();
end

PrivateRaidBossEmoteFrameAnchorMixin = {};

function PrivateRaidBossEmoteFrameAnchorMixin:OnLoad()
	local anchor =
	{
		point = "TOP",
		relativeTo = self,
		relativePoint = "TOP",
		offsetX = 0,
		offsetY = 0,
	};
	C_UnitAuras.SetPrivateWarningTextAnchor(self, anchor);
end
