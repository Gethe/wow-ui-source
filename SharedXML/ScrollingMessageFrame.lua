SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP = 1;
SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM = 2;

ScrollingMessageFrameMixin = CreateFromMixins(FontableFrameMixin);

-- where ... is any extra user data
function ScrollingMessageFrameMixin:AddMessage(message, r, g, b, ...)
	if self.historyBuffer:PushFront(self:PackageEntry(message, r, g, b, ...)) then
		if self:GetScrollOffset() ~= 0 then
			self:ScrollUp();
		end
		self:MarkDisplayDirty();
	end
end

-- where ... is any extra user data
function ScrollingMessageFrameMixin:BackFillMessage(message, r, g, b, ...)
	if self.historyBuffer:PushBack(self:PackageEntry(message, r, g, b, ...)) then
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:GetNumMessages()
	return self.historyBuffer:GetNumElements();
end

function ScrollingMessageFrameMixin:GetMessageInfo(messageIndex)
	local messageInfo = self.historyBuffer:GetEntryAtIndex(self.historyBuffer:GetNumElements() - messageIndex + 1);
	if messageInfo then
		return self:UnpackageEntry(messageInfo);
	end
end

function ScrollingMessageFrameMixin:RemoveMessagesByPredicate(predicate)
	local function Transform(entry)
		return self:UnpackageEntry(entry);
	end
	if self.historyBuffer:RemoveIf(predicate, Transform) then
		self:MarkDisplayDirty();
	end
end

-- Accepts a function that should return true if it wants to change the entries' color along with the new r, g, b values, false for no changes
--[[ Example function:
	local function ChangeRedToBlue(message, r, g, b, ...)
		if r == 1 and g == 0 and b == 0 then
			return true, 0, 0, 1;
		end
		return false; -- No change
	end

	scrollingMessageFrame:AdjustMessageColors(ChangeRedToBlue);
]]--
function ScrollingMessageFrameMixin:AdjustMessageColors(transformFunction)
	for i, entry in self.historyBuffer:EnumerateIndexedEntries() do
		local changeColor, newR, newG, newB = transformFunction(self:UnpackageEntry(entry));
		if changeColor then
			entry.r = newR;
			entry.g = newG;
			entry.b = newB;
			self:MarkDisplayDirty();
		end
	end
end

function ScrollingMessageFrameMixin:ScrollUp()
	self:SetScrollOffset(self:GetScrollOffset() + 1);
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:ScrollDown()
	self:SetScrollOffset(self:GetScrollOffset() - 1);
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:PageUp()
	self:SetScrollOffset(self:GetScrollOffset() + self:GetPagingScrollAmount());
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:PageDown()
	self:SetScrollOffset(self:GetScrollOffset() - self:GetPagingScrollAmount());
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:ScrollToTop()
	self:SetScrollOffset(self:GetMaxScrollRange());
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:ScrollToBottom()
	self:SetScrollOffset(0);
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:SetScrollOffset(offset)
	local newOffset = Clamp(offset, 0, self:GetMaxScrollRange());
	if newOffset ~= self.scrollOffset then
		self.scrollOffset = newOffset;
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:GetScrollOffset()
	return self.scrollOffset;
end

function ScrollingMessageFrameMixin:GetMaxScrollRange()
	return math.max(self.historyBuffer:GetNumElements() - 1, 0);
end

function ScrollingMessageFrameMixin:GetNumVisibleLines()
	return #self.visibleLines;
end

function ScrollingMessageFrameMixin:AtTop()
	return self.scrollOffset == self:GetMaxScrollRange();
end

function ScrollingMessageFrameMixin:AtBottom()
	return self.scrollOffset == 0;
end

function ScrollingMessageFrameMixin:SetMaxLines(maxLines)
	if self:GetMaxLines() ~= maxLines then
		self.historyBuffer:SetMaxNumElements(maxLines);
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:GetMaxLines()
	return self.historyBuffer:GetMaxNumElements();
end

function ScrollingMessageFrameMixin:SetFading(shouldFadeAfterInactivity)
	shouldFadeAfterInactivity = not not shouldFadeAfterInactivity;
	if self.shouldFadeAfterInactivity ~= shouldFadeAfterInactivity then
		self.shouldFadeAfterInactivity = shouldFadeAfterInactivity;
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:GetFading()
	return self.shouldFadeAfterInactivity;
end

function ScrollingMessageFrameMixin:SetTimeVisible(timeVisibleSecs)
	if self.timeVisibleSecs ~= timeVisibleSecs then
		self.timeVisibleSecs = timeVisibleSecs;
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:GetTimeVisible()
	return self.timeVisibleSecs;
end

function ScrollingMessageFrameMixin:SetFadeDuration(fadeDurationSecs)
	if self.fadeDurationSecs ~= fadeDurationSecs then
		self.fadeDurationSecs = fadeDurationSecs;
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:GetFadeDuration()
	return self.fadeDurationSecs;
end

function ScrollingMessageFrameMixin:Clear()
	if not self.historyBuffer:IsEmpty() then
		self.historyBuffer:Clear();
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:SetInsertMode(insertMode)
	if self:GetInsertMode() ~= insertMode then
		self.insertMode = insertMode;
		self:MarkLayoutDirty();
	end
end

function ScrollingMessageFrameMixin:GetInsertMode()
	return self.insertMode;
end

-- "private" functions
function ScrollingMessageFrameMixin:OnPreLoad()
	self:InitializeFontableFrame("ScrollingMessageFrame");

	self.insertMode = SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM;
	self.historyBuffer = CreateCircularBuffer(120);
	self.shouldFadeAfterInactivity = true;
	self.timeVisibleSecs = 10.0;
	self.fadeDurationSecs = 3.0;
	self.scrollOffset = 0;
	self.overrideFadeTimestamp = 0;

	self.visibleLines = {};
end

function ScrollingMessageFrameMixin:OnPostShow()
	self:RefreshIfNecessary();
end

function ScrollingMessageFrameMixin:OnPostUpdate(elapsed)
	self:RefreshIfNecessary();
	self:UpdateFading();
end

function ScrollingMessageFrameMixin:OnPreSizeChanged()
	self:MarkLayoutDirty();
end

function ScrollingMessageFrameMixin:RefreshLayout()
	self.isLayoutDirty = false;

	if self.fontStringPool then
		self.fontStringPool:ReleaseAll();
	end

	local numVisibleLines = self:CalculateNumVisibleLines();

	local frameWidth = self:GetWidth();
	for lineIndex = 1, numVisibleLines do
		local fontString = self:AcquireFontString();
		self.visibleLines[lineIndex] = fontString;
		if lineIndex == 1 then
			if self:GetInsertMode() == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP then
				fontString:SetPoint("TOPLEFT", self, "TOPLEFT");
			else
				fontString:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT");
			end
		else
			if self:GetInsertMode() == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP then
				fontString:SetPoint("TOPLEFT", self.visibleLines[lineIndex - 1], "BOTTOMLEFT", 0, -fontString:GetSpacing());
			else
				fontString:SetPoint("BOTTOMLEFT", self.visibleLines[lineIndex - 1], "TOPLEFT", 0, fontString:GetSpacing());
			end
		end
		fontString:SetWidth(frameWidth);
	end

	for lineIndex = self:GetNumVisibleLines(), numVisibleLines, -1 do
		self.visibleLines[lineIndex] = nil;
	end

	self:MarkDisplayDirty();
end

function ScrollingMessageFrameMixin:RefreshIfNecessary()
	if self.isLayoutDirty then
		self:RefreshLayout();
	end
	if self.isDisplayDirty then
		self:RefreshDisplay();
	end
end

function ScrollingMessageFrameMixin:RefreshDisplay()
	self.isDisplayDirty = false;
	if self:GetNumVisibleLines() == 0 then
		return;
	end

	local canFade = self:CanEffectivelyFade();
	local now = GetTime();

	local fontR, fontG, fontB = self:GetTextColor();
	for lineIndex, visibleLine in ipairs(self.visibleLines) do
		local messageIndex = lineIndex + self.scrollOffset;
		local messageInfo = self.historyBuffer:GetEntryAtIndex(messageIndex);
		if messageInfo then
			visibleLine.messageInfo = messageInfo;
			visibleLine:SetText(messageInfo.message);
			visibleLine:SetTextColor(messageInfo.r or fontR, messageInfo.g or fontG, messageInfo.b or fontB);
			if canFade then
				local alpha = self:CalculateLineAlphaValueFromTimestamp(now, math.max(messageInfo.timestamp, self.overrideFadeTimestamp));
				visibleLine:SetAlpha(alpha);
				visibleLine:SetShown(alpha > 0);
			else
				visibleLine:SetAlpha(1);
				visibleLine:Show();
			end
		else
			visibleLine.messageInfo = nil;
			visibleLine:Hide();
		end
	end
end

function ScrollingMessageFrameMixin:CalculateLineAlphaValueFromTimestamp(now, timestamp)
	local delta = now - timestamp;
	if delta <= self:GetTimeVisible() then
		return 1.0;
	end
	delta = delta - self:GetTimeVisible();

	if delta >= self:GetFadeDuration() then
		return 0.0;
	end

	return 1.0 - delta / self:GetFadeDuration();
end

function ScrollingMessageFrameMixin:CalculateNumVisibleLines()
	if not self:HasFontObject() then
		return 0;
	end

	local lineSpacing = self:CalculateLineSpacing();
	local height = self:GetHeight();
	if height and lineSpacing > 0 then
		return math.ceil(height / lineSpacing) + 1;
	end
	return 0;
end

function ScrollingMessageFrameMixin:MarkLayoutDirty()
	self.isLayoutDirty = true;
end

function ScrollingMessageFrameMixin:MarkDisplayDirty()
	self.isDisplayDirty = true;
end

function ScrollingMessageFrameMixin:ResetAllFadeTimes()
	self.overrideFadeTimestamp = GetTime();
end

function ScrollingMessageFrameMixin:AcquireFontString()
	if not self.fontStringPool then
		self.fontStringPool = CreateFontStringPool(self.FontStringContainer, "BACKGROUND", 0);
	end

	local fontString = self.fontStringPool:Acquire();
	fontString:SetFontObject(self:GetFontObject());
	return fontString;
end

function ScrollingMessageFrameMixin:CalculateLineSpacing()
	local fontString = self:AcquireFontString();
	local lineSpacing = fontString:GetLineHeight();
	self.fontStringPool:Release(fontString);
	return lineSpacing;
end

function ScrollingMessageFrameMixin:GetPagingScrollAmount()
	return math.max(self:GetNumVisibleLines() - 1, 1);
end

function ScrollingMessageFrameMixin:PackageEntry(message, r, g, b, ...)
	local extraDataCount = select("#", ...);
	local extraData;
	if extraDataCount > 0 then
		extraData = { ... };
		extraData.n = extraDataCount;
	end
	return { message = message, r = r, g = g, b = b, extraData = extraData, timestamp = GetTime(), };
end

function ScrollingMessageFrameMixin:UnpackageEntry(entry)
	if entry.extraData then
		return entry.message, entry.r, entry.g, entry.b, unpack(entry.extraData, 1, entry.extraData.n);
	end
	return entry.message, entry.r, entry.g, entry.b;
end

function ScrollingMessageFrameMixin:CanEffectivelyFade()
	return self.shouldFadeAfterInactivity and self:AtBottom();
end

function ScrollingMessageFrameMixin:UpdateFading()
	if not self:CanEffectivelyFade() then
		return;
	end

	local now = GetTime();
	for lineIndex, visibleLine in ipairs(self.visibleLines) do
		if visibleLine.messageInfo then
			local alpha = self:CalculateLineAlphaValueFromTimestamp(now, math.max(visibleLine.messageInfo.timestamp, self.overrideFadeTimestamp));
			visibleLine:SetAlpha(alpha);
			visibleLine:SetShown(alpha > 0);
		end
	end
end

function ScrollingMessageFrameMixin:OnFontObjectUpdated() -- override from FontableFrameMixin
	self:MarkLayoutDirty();
end