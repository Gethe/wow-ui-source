SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP = 1;
SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM = 2;

ScrollingMessageFrameMixin = CreateFromMixins(FontableFrameMixin);

function ScrollingMessageFrameScrollBar_OnValueChanged(self, value, userInput)
	self.ScrollUp:Enable();
	self.ScrollDown:Enable();

	local minVal, maxVal = self:GetMinMaxValues();
	if value >= maxVal then
		self.ScrollDown:Disable()
	end
	if value <= minVal then
		self.ScrollUp:Disable();
	end
	
	if userInput then
		self:GetParent():SetScrollOffset(maxVal - value);
	end
end

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

-- Accepts a predicate that should return true if the entry should be transformed by the transformFunction
--[[
Example predicate:
	local function ShouldChangeToDeleted(message, r, g, b, ...)
		if #message > 30 then
			return true;
		end
	end
	
Example transformFunction:
	local function ChangeToDeleted(message, r, g, b, ...)
		return "This message has been deleted.", r, g, b, ...;
	end

	scrollingMessageFrame:TransformMessages(ShouldChangeToDeleted, ChangeToDeleted);
]]--
function ScrollingMessageFrameMixin:TransformMessages(predicate, transformFunction)
	local function Unpackage(entry)
		return self:UnpackageEntry(entry);
	end
	
	local function TransformEntry(...)
		return self:PackageEntry(transformFunction(...));
	end
	
	if self.historyBuffer:TransformIf(predicate, TransformEntry, Unpackage) then
		self:MarkDisplayDirty();
	end
end

function ScrollingMessageFrameMixin:ScrollByAmount(amount)
	self:SetScrollOffset(self:GetScrollOffset() + amount);
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:ScrollUp()
	self:ScrollByAmount(1);
end

function ScrollingMessageFrameMixin:ScrollDown()
	self:ScrollByAmount(-1);
end

function ScrollingMessageFrameMixin:PageUp()
	self:ScrollByAmount(self:GetPagingScrollAmount());
end

function ScrollingMessageFrameMixin:PageDown()
	self:ScrollByAmount(-self:GetPagingScrollAmount());
end

function ScrollingMessageFrameMixin:ScrollToTop()
	self:SetScrollOffset(self:GetMaxScrollRange());
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:ScrollToBottom()
	self:SetScrollOffset(0);
	self:ResetAllFadeTimes();
end

function ScrollingMessageFrameMixin:SetOnDisplayRefreshedCallback(callback)
	self.onDisplayRefreshedCallback = callback;
end

function ScrollingMessageFrameMixin:GetOnDisplayRefreshedCallback()
	return self.onDisplayRefreshedCallback;
end

function ScrollingMessageFrameMixin:SetOnScrollChangedCallback(onScrollChangedCallback)
	self.onScrollChangedCallback = onScrollChangedCallback;
end

function ScrollingMessageFrameMixin:GetOnScrollChangedCallback()
	return self.onScrollChangedCallback;
end

function ScrollingMessageFrameMixin:SetOnTextCopiedCallback(onTextCopiedCallback)
	self.onTextCopiedCallback = onTextCopiedCallback;
end

function ScrollingMessageFrameMixin:GetOnTextCopiedCallback()
	return self.onTextCopiedCallback;
end

function ScrollingMessageFrameMixin:SetScrollOffset(offset)
	local newOffset = Clamp(offset, 0, self:GetMaxScrollRange());
	if newOffset ~= self.scrollOffset then
		self.scrollOffset = newOffset;
		self:MarkDisplayDirty();
		if self.onScrollChangedCallback then
			self.onScrollChangedCallback(self, self.scrollOffset);
		end
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

function ScrollingMessageFrameMixin:GetPagingScrollAmount()
	return math.max(self:GetNumVisibleLines() - 1, 1);
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
		self:SetScrollOffset(0);
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

function ScrollingMessageFrameMixin:SetTextCopyable(textIsCopyable)
	if self:IsTextCopyable() ~= textIsCopyable then
		self.textIsCopyable = textIsCopyable;
		if not self:IsTextCopyable() then
			self:ResetSelectingText();
		end
	end
end

function ScrollingMessageFrameMixin:IsTextCopyable()
	return self.textIsCopyable;
end

function ScrollingMessageFrameMixin:IsSelectingText()
	return self.selectingCharacterIndex ~= nil;
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
	self.textIsCopyable = false;

	self.visibleLines = {};
end

function ScrollingMessageFrameMixin:OnPostShow()
	self:RefreshIfNecessary();
end

function ScrollingMessageFrameMixin:OnPostHide()
	self:ResetSelectingText();
end

function ScrollingMessageFrameMixin:OnPostUpdate(elapsed)
	if self:IsSelectingText() then
		self:UpdateSelectingText();
	else
		self:RefreshIfNecessary();
		self:UpdateFading();
	end
end

function ScrollingMessageFrameMixin:OnPreSizeChanged()
	self:MarkLayoutDirty();
end

function ScrollingMessageFrameMixin:OnPostMouseDown()
	if self:IsTextCopyable() then
		self:ResetAllFadeTimes();
		self:RefreshIfNecessary();
		self:UpdateFading();

		local x, y = self:GetScaledCursorPosition();
		self.selectingCharacterIndex, self.selectingVisibleLineIndex = self:FindCharacterAndLineIndexAtCoordinate(x, y);
	end
end

function ScrollingMessageFrameMixin:OnPostMouseUp()
	if self:IsSelectingText() then
		local x, y = self:GetScaledCursorPosition();
		local selectedText = self:GatherSelectedText(x, y);

		local numCopied = nil;
		if selectedText then
			local REMOVE_MARKUP = true;
			numCopied = CopyToClipboard(selectedText, REMOVE_MARKUP);
		end

		self:ResetSelectingText();

		if numCopied and selectedText and self.onTextCopiedCallback then
			self.onTextCopiedCallback(self, selectedText, numCopied);
		end
	end
end

function ScrollingMessageFrameMixin:ResetSelectingText()
	if self:IsSelectingText() then
		self:ResetAllFadeTimes();

		self.selectingCharacterIndex, self.selectingVisibleLineIndex = nil, nil;

		if self.highlightTexturePool then
			self.highlightTexturePool:ReleaseAll();
		end
	end
end

function ScrollingMessageFrameMixin:CalculateSelectingCharacterIndicesForVisibleLine(lineIndex, startLineIndex, endLineIndex, startCharacterIndex, endCharacterIndex)
	local visibleLine = self.visibleLines[lineIndex];
	if lineIndex == startLineIndex and lineIndex == endLineIndex then
		return math.min(startCharacterIndex, endCharacterIndex), math.max(startCharacterIndex, endCharacterIndex);
	elseif lineIndex == startLineIndex then
		if self:GetInsertMode() == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP then
			if endLineIndex > startLineIndex then
				return startCharacterIndex, #visibleLine:GetText() + 1;
			else
				return 1, startCharacterIndex;
			end
		else
			if endLineIndex > startLineIndex then
				return 1, startCharacterIndex;
			else
				return startCharacterIndex, #visibleLine:GetText() + 1;
			end
		end
	elseif lineIndex == endLineIndex then
		if self:GetInsertMode() == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP then
			if endLineIndex > startLineIndex then
				return 1, endCharacterIndex;
			else
				return endCharacterIndex, #visibleLine:GetText() + 1;
			end
		else
			if endLineIndex > startLineIndex then
				return endCharacterIndex, #visibleLine:GetText() + 1;
			else
				return 1, endCharacterIndex;
			end
		end
	end

	return 1, #visibleLine:GetText() + 1;
end

function ScrollingMessageFrameMixin:UpdateSelectingText()
	if self.highlightTexturePool then
		self.highlightTexturePool:ReleaseAll();
	end

	local x, y = self:GetScaledCursorPosition();
	local characterIndex, visibleLineIndex = self:FindCharacterAndLineIndexAtCoordinate(x, y);
	if characterIndex and (self.selectingCharacterIndex ~= characterIndex or self.selectingVisibleLineIndex ~= visibleLineIndex) then
		local startLineIndex, endLineIndex = self.selectingVisibleLineIndex, visibleLineIndex;
		local startCharacterIndex, endCharacterIndex = self.selectingCharacterIndex, characterIndex;

		for lineIndex = math.min(startLineIndex, endLineIndex), math.max(startLineIndex, endLineIndex) do
			local visibleLine = self.visibleLines[lineIndex];
			if visibleLine:GetText() then
				local selectingStartIndex, selectingEndIndex = self:CalculateSelectingCharacterIndicesForVisibleLine(lineIndex, startLineIndex, endLineIndex, startCharacterIndex, endCharacterIndex);
				local screenAreaTable = visibleLine:CalculateScreenAreaFromCharacterSpan(selectingStartIndex, selectingEndIndex);

				if screenAreaTable then
					for i, screenArea in ipairs(screenAreaTable) do
						local highlightTexture = self:AcquireHighlightTexture();

						highlightTexture:SetPoint("BOTTOMLEFT", visibleLine, "BOTTOMLEFT", screenArea.left, screenArea.bottom);
						highlightTexture:SetPoint("TOPRIGHT", visibleLine, "BOTTOMLEFT", screenArea.left + screenArea.width, screenArea.bottom + screenArea.height);

						highlightTexture:Show();
					end
				end
			end
		end
	end
end

function ScrollingMessageFrameMixin:GatherSelectedText(x, y)
	local characterIndex, visibleLineIndex = self:FindCharacterAndLineIndexAtCoordinate(x, y);
	if characterIndex and (self.selectingCharacterIndex ~= characterIndex or self.selectingVisibleLineIndex ~= visibleLineIndex) then
		local pendingText = {};
		local startLineIndex, endLineIndex = self.selectingVisibleLineIndex, visibleLineIndex;
		local startCharacterIndex, endCharacterIndex = self.selectingCharacterIndex, characterIndex - 1;

		local effectiveStartLineIndex, effectiveEndLineIndex, direction;
		if self:GetInsertMode() == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP then
			effectiveStartLineIndex = math.min(startLineIndex, endLineIndex);
			effectiveEndLineIndex = math.max(startLineIndex, endLineIndex);
			direction = 1;
		else
			effectiveStartLineIndex = math.max(startLineIndex, endLineIndex);
			effectiveEndLineIndex = math.min(startLineIndex, endLineIndex);
			direction = -1;
		end

		for lineIndex = effectiveStartLineIndex, effectiveEndLineIndex, direction do
			local visibleLine = self.visibleLines[lineIndex];
			local text = visibleLine:GetText();
			if text then
				local selectingStartIndex, selectingEndIndex = self:CalculateSelectingCharacterIndicesForVisibleLine(lineIndex, startLineIndex, endLineIndex, startCharacterIndex, endCharacterIndex);
				local subText = text:sub(selectingStartIndex, selectingEndIndex);
				table.insert(pendingText, subText);
			end
		end

		return table.concat(pendingText, "\n");
	end
	return nil;
end

local function CalculateDistanceSqToLine(x, y, visibleLine)
	-- perimeter would be more accurate, but this seems to work well enough
	local cx, cy = visibleLine:GetCenter();
	return CalculateDistanceSq(x, y, cx, cy);
end

function ScrollingMessageFrameMixin:FindCharacterAndLineIndexAtCoordinate(x, y)
	local closestLineIndex, closestCharacterIndex, closestDistance;
	for lineIndex, visibleLine in ipairs(self.visibleLines) do
		local characterIndex, isInside = visibleLine:FindCharacterIndexAtCoordinate(x, y);
		if characterIndex then
			if isInside then
				return characterIndex, lineIndex;
			end

			local distanceToLine = CalculateDistanceSqToLine(x, y, visibleLine);
			if not closestDistance or distanceToLine < closestDistance then
				closestLineIndex = lineIndex;
				closestCharacterIndex = characterIndex;
				closestDistance = distanceToLine;
			end
		end
	end
	return closestCharacterIndex, closestLineIndex;
end

function ScrollingMessageFrameMixin:GetScaledCursorPosition()
	local scale = self:GetEffectiveScale();
	local x, y = GetCursorPosition();
	return x / scale, y / scale;
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
		self:CallOnDisplayRefreshed();
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

	self:CallOnDisplayRefreshed();
end

function ScrollingMessageFrameMixin:CallOnDisplayRefreshed()
	local callback = self:GetOnDisplayRefreshedCallback();

	if callback then
		callback(self);
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
	fontString:SetNonSpaceWrap(true);
	return fontString;
end

function ScrollingMessageFrameMixin:AcquireHighlightTexture()
	if not self.highlightTexturePool then
		self.highlightTexturePool = CreateTexturePool(self.FontStringContainer, "BACKGROUND", 1);
	end

	local texture = self.highlightTexturePool:Acquire();
	texture:SetColorTexture(.37, .37, .37);
	return texture;
end

function ScrollingMessageFrameMixin:CalculateLineSpacing()
	local fontString = self:AcquireFontString();
	local lineSpacing = fontString:GetLineHeight();
	self.fontStringPool:Release(fontString);
	return lineSpacing;
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
	return self.shouldFadeAfterInactivity and self:AtBottom() and not self:IsSelectingText();
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