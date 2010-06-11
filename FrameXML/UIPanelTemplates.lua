-- functions to manage tab interfaces where only one tab of a group may be selected
function PanelTemplates_Tab_OnClick(self, frame)
	PanelTemplates_SetTab(frame, self:GetID())
end

function PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_GetSelectedTab(frame)
	return frame.selectedTab;
end

function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = _G[frame:GetName().."Tab"..i];
			if ( tab.isDisabled ) then
				PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

function PanelTemplates_GetTabWidth(tab)
	local tabName = tab:GetName();

	local sideWidths = 2 * _G[tabName.."Left"]:GetWidth();
	return tab:GetTextWidth() + sideWidths;
end

function PanelTemplates_TabResize(tab, padding, absoluteSize, maxWidth, absoluteTextSize)
	local tabName = tab:GetName();
	
	local buttonMiddle = _G[tabName.."Middle"];
	local buttonMiddleDisabled = _G[tabName.."MiddleDisabled"];
	local sideWidths = 2 * _G[tabName.."Left"]:GetWidth();
	local tabText = _G[tab:GetName().."Text"];
	local width, tabWidth;
	local textWidth;
	if ( absoluteTextSize ) then
		textWidth = absoluteTextSize;
	else
		textWidth = tabText:GetWidth();
	end
	-- If there's an absolute size specified then use it
	if ( absoluteSize ) then
		if ( absoluteSize < sideWidths) then
			width = 1;
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths;
			tabWidth = absoluteSize
		end
		tabText:SetWidth(width);
	else
		-- Otherwise try to use padding
		if ( padding ) then
			width = textWidth + padding;
		else
			width = textWidth + 24;
		end
		-- If greater than the maxWidth then cap it
		if ( maxWidth and width > maxWidth ) then
			if ( padding ) then
				width = maxWidth + padding;
			else
				width = maxWidth + 24;
			end
			tabText:SetWidth(width);
		else
			tabText:SetWidth(0);
		end
		tabWidth = width + sideWidths;
	end
	
	if ( buttonMiddle ) then
		buttonMiddle:SetWidth(width);
	end
	if ( buttonMiddleDisabled ) then
		buttonMiddleDisabled:SetWidth(width);
	end
	
	tab:SetWidth(tabWidth);
	local highlightTexture = _G[tabName.."HighlightTexture"];
	if ( highlightTexture ) then
		highlightTexture:SetWidth(tabWidth);
	end
end

function PanelTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function PanelTemplates_DisableTab(frame, index)
	_G[frame:GetName().."Tab"..index].isDisabled = 1;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_EnableTab(frame, index)
	local tab = _G[frame:GetName().."Tab"..index];
	tab.isDisabled = nil;
	-- Reset text color
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Show();
	_G[name.."Middle"]:Show();
	_G[name.."Right"]:Show();
	--tab:UnlockHighlight();
	tab:Enable();
	_G[name.."LeftDisabled"]:Hide();
	_G[name.."MiddleDisabled"]:Hide();
	_G[name.."RightDisabled"]:Hide();
end

function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Hide();
	_G[name.."Middle"]:Hide();
	_G[name.."Right"]:Hide();
	--tab:LockHighlight();
	tab:Disable();
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	_G[name.."LeftDisabled"]:Show();
	_G[name.."MiddleDisabled"]:Show();
	_G[name.."RightDisabled"]:Show();
	
	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Show();
	_G[name.."Middle"]:Show();
	_G[name.."Right"]:Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledFontObject(GameFontDisableSmall);
	_G[name.."LeftDisabled"]:Hide();
	_G[name.."MiddleDisabled"]:Hide();
	_G[name.."RightDisabled"]:Hide();
end

function ScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or _G[self:GetName() .. "ScrollBar"];
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - (scrollBar:GetHeight() / 2));
	else
		scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() / 2));
	end
end

-- Function to handle the update of manually calculated scrollframes.  Used mostly for listings with an indeterminate number of items
function FauxScrollFrame_Update(frame, numItems, numToDisplay, valueStep, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar )
	-- If more than one screen full of skills then show the scrollbar
	local frameName = frame:GetName();
	local scrollBar = _G[ frameName.."ScrollBar" ];
	local showScrollBar;
	if ( numItems > numToDisplay or alwaysShowScrollBar ) then
		frame:Show();
		showScrollBar = 1;
	else
		scrollBar:SetValue(0);
		frame:Hide();
	end
	if ( frame:IsShown() ) then
		local scrollChildFrame = _G[ frameName.."ScrollChildFrame" ];
		local scrollUpButton = _G[ frameName.."ScrollBarScrollUpButton" ];
		local scrollDownButton = _G[ frameName.."ScrollBarScrollDownButton" ];
		local scrollFrameHeight = 0;
		local scrollChildHeight = 0;

		if ( numItems > 0 ) then
			scrollFrameHeight = (numItems - numToDisplay) * valueStep;
			scrollChildHeight = numItems * valueStep;
			if ( scrollFrameHeight < 0 ) then
				scrollFrameHeight = 0;
			end
			scrollChildFrame:Show();
		else
			scrollChildFrame:Hide();
		end
		scrollBar:SetMinMaxValues(0, scrollFrameHeight); 
		scrollBar:SetValueStep(valueStep);
		scrollChildFrame:SetHeight(scrollChildHeight);
		
		-- Arrow button handling
		if ( scrollBar:GetValue() == 0 ) then
			scrollUpButton:Disable();
		else
			scrollUpButton:Enable();
		end
		if ((scrollBar:GetValue() - scrollFrameHeight) == 0) then
			scrollDownButton:Disable();
		else
			scrollDownButton:Enable();
		end
		
		-- Shrink because scrollbar is shown
		if ( highlightFrame ) then
			highlightFrame:SetWidth(smallHighlightWidth);
		end
		if ( button ) then
			for i=1, numToDisplay do
				_G[button..i]:SetWidth(smallWidth);
			end
		end
	else
		-- Widen because scrollbar is hidden
		if ( highlightFrame ) then
			highlightFrame:SetWidth(bigHighlightWidth);
		end
		if ( button ) then
			for i=1, numToDisplay do
				_G[button..i]:SetWidth(bigWidth);
			end
		end
	end
	return showScrollBar;
end

function FauxScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(value);
	self.offset = floor((value / itemHeight) + 0.5);
	if ( updateFunction ) then
		updateFunction(self);
	end
end

function FauxScrollFrame_GetOffset(frame)
	return frame.offset;
end

function FauxScrollFrame_SetOffset(frame, offset)
	frame.offset = offset;
end

-- Scrollframe functions
function ScrollFrame_OnLoad(self)
	_G[self:GetName().."ScrollBarScrollDownButton"]:Disable();
	_G[self:GetName().."ScrollBarScrollUpButton"]:Disable();

	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetMinMaxValues(0, 0);
	scrollbar:SetValue(0);
	self.offset = 0;
	
	if ( self.scrollBarHideable ) then
		_G[self:GetName().."ScrollBar"]:Hide();
		_G[scrollbar:GetName().."ScrollDownButton"]:Hide();
		_G[scrollbar:GetName().."ScrollUpButton"]:Hide();
	else
		_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
		_G[scrollbar:GetName().."ScrollUpButton"]:Disable();
		_G[scrollbar:GetName().."ScrollDownButton"]:Show();
		_G[scrollbar:GetName().."ScrollUpButton"]:Show();
	end
end

function ScrollFrame_OnScrollRangeChanged(self, xrange, yrange)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	if ( not yrange ) then
		yrange = self:GetVerticalScrollRange();
	end
	local value = scrollbar:GetValue();
	if ( value > yrange ) then
		value = yrange;
	end
	scrollbar:SetMinMaxValues(0, yrange);
	scrollbar:SetValue(value);
	if ( floor(yrange) == 0 ) then
		if ( self.scrollBarHideable ) then
			_G[self:GetName().."ScrollBar"]:Hide();
			_G[scrollbar:GetName().."ScrollDownButton"]:Hide();
			_G[scrollbar:GetName().."ScrollUpButton"]:Hide();
			if ( self.haveTrack ) then
				_G[self:GetName().."Track"]:Hide();
			end
		else
			_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
			_G[scrollbar:GetName().."ScrollUpButton"]:Disable();
			_G[scrollbar:GetName().."ScrollDownButton"]:Show();
			_G[scrollbar:GetName().."ScrollUpButton"]:Show();
		end
		_G[scrollbar:GetName().."ThumbTexture"]:Hide();
	else
		_G[scrollbar:GetName().."ScrollDownButton"]:Show();
		_G[scrollbar:GetName().."ScrollUpButton"]:Show();
		_G[self:GetName().."ScrollBar"]:Show();
		_G[scrollbar:GetName().."ThumbTexture"]:Show();
		if ( self.haveTrack ) then
			_G[self:GetName().."Track"]:Show();
		end		
		-- The 0.005 is to account for precision errors
		if ( yrange - value > 0.005 ) then
			_G[scrollbar:GetName().."ScrollDownButton"]:Enable();
		else
			_G[scrollbar:GetName().."ScrollDownButton"]:Disable();
		end
	end
	
	-- Hide/show scrollframe borders
	local top = _G[self:GetName().."Top"];
	local bottom = _G[self:GetName().."Bottom"];
	local middle = _G[self:GetName().."Middle"];
	if ( top and bottom and self.scrollBarHideable ) then
		if ( self:GetVerticalScrollRange() == 0 ) then
			top:Hide();
			bottom:Hide();
		else
			top:Show();
			bottom:Show();
		end
	end
	if ( middle and self.scrollBarHideable ) then
		if ( self:GetVerticalScrollRange() == 0 ) then
			middle:Hide();
		else
			middle:Show();
		end
	end
end

function ScrollingEdit_OnTextChanged(self, scrollFrame)
	-- force an update when the text changes
	self.handleCursorChange = true;
	ScrollingEdit_OnUpdate(self, 0, scrollFrame);
end

function ScrollingEdit_OnCursorChanged(self, x, y, w, h)
	self.cursorOffset = y;
	self.cursorHeight = h;
	self.handleCursorChange = true;
end

-- NOTE: If your edit box never shows partial lines of text, then this function will not work when you use
-- your mouse to move the edit cursor. You need the edit box to cut lines of text so that you can use your
-- mouse to highlight those partially-seen lines; otherwise you won't be able to use the mouse to move the
-- cursor above or below the current scroll area of the edit box.
function ScrollingEdit_OnUpdate(self, elapsed, scrollFrame)
local height, range, scroll, size, cursorOffset;
	if ( self.handleCursorChange ) then
		if ( not scrollFrame ) then
			scrollFrame = self:GetParent();
		end
		height = scrollFrame:GetHeight();
		range = scrollFrame:GetVerticalScrollRange();
		scroll = scrollFrame:GetVerticalScroll();
		size = height + range;
		cursorOffset = -self.cursorOffset;
		
		if ( math.floor(height) <= 0 or math.floor(range) <= 0 ) then
			--Frame has no area, nothing to calculate.
			return;
		end
		
		while ( cursorOffset < scroll ) do
			scroll = (scroll - (height / 2));
			if ( scroll < 0 ) then
				scroll = 0;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end

		while ( (cursorOffset + self.cursorHeight) > (scroll + height) and scroll < range ) do
			scroll = (scroll + (height / 2));
			if ( scroll > range ) then
				scroll = range;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end
		
		self.handleCursorChange = false;
	end
end

function EditBox_HandleTabbing(self, tabList)
	local editboxName = self:GetName();
	local index;
	for i=1, #tabList do
		if ( editboxName == tabList[i] ) then
			index = i;
			break;
		end
	end
	if ( IsShiftKeyDown() ) then
		index = index - 1;
	else
		index = index + 1;
	end

	if ( index == 0 ) then
		index = #tabList;
	elseif ( index > #tabList ) then
		index = 1;
	end

	local target = tabList[index];
	_G[target]:SetFocus();
end

function EditBox_ClearFocus (self)
	self:ClearFocus();
end

function EditBox_SetFocus (self)
	self:SetFocus();
end

function EditBox_HighlightText (self)
	self:HighlightText();
end

function EditBox_ClearHighlight (self)
	self:HighlightText(0, 0);
end

UIFrameCache = CreateFrame("FRAME");
local caches = {};
function UIFrameCache:New (frameType, baseName, parent, template)
	if ( self ~= UIFrameCache ) then
		error("Attempt to run factory method on class member");
	end
	
	local frameCache = {};

	setmetatable(frameCache, self);
	self.__index = self;
	
	frameCache.frameType = frameType;
	frameCache.baseName = baseName;
	frameCache.parent = parent;
	frameCache.template = template;
	frameCache.frames = {};
	frameCache.usedFrames = {};
	frameCache.numFrames = 0;

	tinsert(caches, frameCache);
	
	return frameCache;
end

function UIFrameCache:GetFrame ()
	local frame = self.frames[1];
	if ( frame ) then
		tremove(self.frames, 1);
		tinsert(self.usedFrames, frame);
		return frame;
	end
	
	frame = CreateFrame(self.frameType, self.baseName .. self.numFrames + 1, self.parent, self.template);
	frame.frameCache = self;
	self.numFrames = self.numFrames + 1;
	tinsert(self.usedFrames, frame);
	return frame;
end

function UIFrameCache:ReleaseFrame (frame)
	for k, v in next, self.frames do
		if ( v == frame ) then
			return;
		end
	end
	
	for k, v in next, self.usedFrames do
		if ( v == frame ) then
			tinsert(self.frames, frame);
			tremove(self.usedFrames, k);
			break;
		end
	end	
end

-- positionFunc = Callback to determine the visible buttons.
--		arguments: scroll value
--		must return: index of the topmost visible button (or nil if there are no buttons)
--					 the total height used by all buttons prior to topmost
--					 the total height of all the buttons
-- buttonFunc = Callback to configure each button
--		arguments: button, button index, first button
--			NOTE: first button is true if this is the first button in a rendering pass. For scrolling optimization, positionFunc may be called without subsequent calls to buttonFunc.
--		must return: height of button
function DynamicScrollFrame_CreateButtons(self, buttonTemplate, minButtonHeight, buttonFunc, positionFunc)
	if ( self.buttons ) then
		return;
	end

	local scrollChild = self.scrollChild;
	local scrollHeight = self:GetHeight();
	local buttonName = self:GetName().."Button";
	local buttons = { };
	local numButtons;
	
	local button = CreateFrame("BUTTON", buttonName.."1", scrollChild, buttonTemplate);
	button:SetPoint("TOPLEFT", 0, 0);
	tinsert(buttons, button);
	numButtons = math.ceil(scrollHeight / minButtonHeight) + 3;
	for i = 2, numButtons do
		button = CreateFrame("BUTTON", buttonName..i, scrollChild, buttonTemplate);
		button:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, 0);
		tinsert(buttons, button);
	end
	self.buttons = buttons;
	self.numButtons = numButtons;
	self.usedButtons = 0;
	self.buttonFunc = buttonFunc;
	self.positionFunc = positionFunc;
	self.scrollHeight = scrollHeight;
	-- optimization vars
	self.lastOffset = -1;
	self.topIndex = -1;
	self.nextButtonOffset = -1;
end

function DynamicScrollFrame_OnVerticalScroll(self, offset)
	offset = math.floor(offset + 0.5);
	if ( offset ~= self.lastOffset ) then
		local scrollBar = self.scrollBar;
		local min, max = scrollBar:GetMinMaxValues();
		scrollBar:SetValue(offset);
		if ( offset == 0 ) then
			_G[scrollBar:GetName().."ScrollUpButton"]:Disable();
		else
			_G[scrollBar:GetName().."ScrollUpButton"]:Enable();
		end
		if ( offset == math.floor(max + 0.5) ) then
			_G[scrollBar:GetName().."ScrollDownButton"]:Disable();
		else
			_G[scrollBar:GetName().."ScrollDownButton"]:Enable();
		end
		self.lastOffset = offset;
		DynamicScrollFrame_Update(self, offset, true);
	end
end

function DynamicScrollFrame_Update(self, scrollValue, isScrollUpdate)
	if ( not self.positionFunc ) then
		return;
	end
	if ( not scrollValue ) then
		scrollValue = floor(self.scrollBar:GetValue() + 0.5);
	end
	local buttonIndex = 0;
	local buttons = self.buttons;
	local topIndex, heightUsed, totalHeight = self.positionFunc(scrollValue);
	if ( topIndex ) then
		if ( isScrollUpdate and self.topIndex == topIndex and ( self.nextButtonOffset == 0 or scrollValue < self.nextButtonOffset ) ) then
			return;
		end
		self.allowedRange = totalHeight - self.scrollHeight;		-- temp fix to jitter scroll (see task 39261)
		self.topIndex = topIndex;
		local button;
		local buttonFunc = self.buttonFunc;
		local buttonHeight;
		local visibleRange = scrollValue + self.scrollHeight;
		if ( topIndex > 1 ) then
			buttons[1]:SetHeight(heightUsed);
			buttons[1]:Show();
			buttonIndex = 1;
		end
		for dataIndex = topIndex, topIndex + self.numButtons - 1 do
			buttonIndex = buttonIndex + 1;
			button = buttons[buttonIndex];
			buttonHeight = buttonFunc(button, dataIndex, (dataIndex == topIndex));
			button:SetHeight(buttonHeight);
			heightUsed = heightUsed + buttonHeight;
			if ( heightUsed >= totalHeight ) then
				self.nextButtonOffset = 0;
				break;
			elseif ( heightUsed >= visibleRange ) then
				buttonIndex = buttonIndex + 1;
				button = buttons[buttonIndex];
				button:SetHeight(totalHeight - heightUsed);
				button:Show();
				self.nextButtonOffset = floor(scrollValue + heightUsed - visibleRange);
				break;
			end
		end
	end
	for i = buttonIndex + 1, self.numButtons do
		buttons[i]:Hide();
	end
	self.usedButtons = buttonIndex;
end

function DynamicScrollFrame_UnlockAllHighlights(self)
	local buttons = self.buttons;
	for i = 1, self.usedButtons do
		buttons[i]:UnlockHighlight();
	end
end