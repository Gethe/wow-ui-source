
function SearchBoxTemplate_OnLoad(self)
	self:SetText(SEARCH);
	self:SetFontObject("GameFontDisable");
	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	self:SetTextInsets(16, 20, 0, 0);
end

function SearchBoxTemplate_OnEditFocusLost(self)
	self:HighlightText(0, 0);
	self:SetFontObject("GameFontDisable");
	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	if ( self:GetText() == "" or self:GetText() == SEARCH ) then
		self:SetText(SEARCH);
		self.clearButton:Hide();
	end
end

function SerachBoxTemplate_OnEditFocusGained(self)
	self:HighlightText();
	self:SetFontObject("ChatFontSmall");
	self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
	if ( self:GetText() == SEARCH ) then
		self:SetText("")
	end
	self.clearButton:Show();
end

ITEM_SEARCHBAR_LIST = {
	"BagItemSearchBox",
	"GuildItemSearchBox",
	"VoidItemSearchBox",
	"BankItemSearchBox",
};

function BagSearch_OnHide(self)
	local allClosed = true;
	for _,barName in pairs(ITEM_SEARCHBAR_LIST) do
		local bar = _G[barName];
		if bar and bar ~= self and bar:IsVisible() then
			allClosed = false;
		end
	end
	if ( allClosed ) then
		self.clearButton:Click();
		BagSearch_OnTextChanged(self);
	end
end

function BagSearch_OnTextChanged(self, userChanged)
	local text = self:GetText();
	if ( text == SEARCH ) then
		text = "";
	end
	SetItemSearch(text);
	if (text ~= "") then
		self.clearButton:Show();
	else
		self.clearButton:Hide();
	end
end

function BagSearch_OnChar(self, text)
	-- clear focus if the player is repeating keys (ie - trying to move)
	-- TODO: move into base editbox code?
	local MIN_REPEAT_CHARACTERS = 3
	local searchString = self:GetText();
	if (string.len(searchString) > MIN_REPEAT_CHARACTERS) then
		local repeatChar = true;
		for i=1, MIN_REPEAT_CHARACTERS, 1 do 
			if ( string.sub(searchString,(0-i), (0-i)) ~= string.sub(searchString,(-1-i),(-1-i)) ) then
				repeatChar = false;
				break;
			end
		end
		if ( repeatChar ) then
			self:ClearFocus();
		end
	end
end

function BagSearch_OnEditFocusGained(self)
	SerachBoxTemplate_OnEditFocusGained(self);

	for _,barName in pairs(ITEM_SEARCHBAR_LIST) do
		local bar = _G[barName];
		if bar and bar ~= self then
			bar:SetText(SEARCH);
		end
	end
end

function BagSearch_OnEditFocusLost(self)
	SerachBoxTemplate_OnEditFocusGained(self);

	local search = self:GetText();
	for _,barName in pairs(ITEM_SEARCHBAR_LIST) do
		local bar = _G[barName];
		if bar and bar ~= self then
			bar:SetText(search);
		end
	end
end

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
	
function PanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)
	local tabName = tab:GetName();
	
	local buttonMiddle = tab.Middle or _G[tabName.."Middle"];
	local buttonMiddleDisabled = tab.MiddleDisabled or _G[tabName.."MiddleDisabled"];
	local sideWidths = tab.Left and 2 * tab.Left:GetWidth() or 2 * _G[tabName.."Left"]:GetWidth();
	local tabText = tab.Text or _G[tab:GetName().."Text"];
	local highlightTexture = tab.HighlightTexture or _G[tabName.."HighlightTexture"];
	
	local width, tabWidth;
	local textWidth;
	if ( absoluteTextSize ) then
		textWidth = absoluteTextSize;
	else
		tabText:SetWidth(0);
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
		if (minWidth and width < minWidth) then
			width = minWidth;
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
	
	local left = tab.Left or _G[name.."Left"];
	local middle = tab.Middle or _G[name.."Middle"];
	local right = tab.Right or _G[name.."Right"];
	left:Show();
	middle:Show();
	right:Show();
	--tab:UnlockHighlight();
	tab:Enable();
	local text = tab.Text or _G[name.."Text"];
	text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2));
	
	local leftDisabled = tab.LeftDisabled or _G[name.."LeftDisabled"];
	local middleDisabled = tab.MiddleDisabled or _G[name.."MiddleDisabled"];
	local rightDisabled = tab.RightDisabled or _G[name.."RightDisabled"];
	leftDisabled:Hide();
	middleDisabled:Hide();
	rightDisabled:Hide();
end

function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	
	local left = tab.Left or _G[name.."Left"];
	local middle = tab.Middle or _G[name.."Middle"];
	local right = tab.Right or _G[name.."Right"];
	left:Hide();
	middle:Hide();
	right:Hide();
	--tab:LockHighlight();
	tab:Disable();
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	local text = tab.Text or _G[name.."Text"];
	text:SetPoint("CENTER", tab, "CENTER", (tab.selectedTextX or 0), (tab.selectedTextY or -3));
	
	local leftDisabled = tab.LeftDisabled or _G[name.."LeftDisabled"];
	local middleDisabled = tab.MiddleDisabled or _G[name.."MiddleDisabled"];
	local rightDisabled = tab.RightDisabled or _G[name.."RightDisabled"];
	leftDisabled:Show();
	middleDisabled:Show();
	rightDisabled:Show();
	
	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	local left = tab.Left or _G[name.."Left"];
	local middle = tab.Middle or _G[name.."Middle"];
	local right = tab.Right or _G[name.."Right"];
	left:Show();
	middle:Show();
	right:Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledFontObject(GameFontDisableSmall);
	local leftDisabled = tab.LeftDisabled or _G[name.."LeftDisabled"];
	local middleDisabled = tab.MiddleDisabled or _G[name.."MiddleDisabled"];
	local rightDisabled = tab.RightDisabled or _G[name.."RightDisabled"];
	leftDisabled:Hide();
	middleDisabled:Hide();
	rightDisabled:Hide();
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

-- Truncated Button code

function TruncatedButton_OnEnter(self)
	local text = _G[self:GetName().."Text"];
	if ( text:IsTruncated() ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(text:GetText());
		GameTooltip:Show();
	end
end

function TruncatedButton_OnLeave(self)
	if ( GameTooltip:GetOwner() == self ) then
		GameTooltip:Hide();
	end
end


-- SquareButton template code
SQUARE_BUTTON_TEXCOORDS = {
	["UP"] = {     0.45312500,    0.64062500,     0.01562500,     0.20312500};
	["DOWN"] = {   0.45312500,    0.64062500,     0.20312500,     0.01562500};
	["LEFT"] = {   0.23437500,    0.42187500,     0.01562500,     0.20312500};
	["RIGHT"] = {  0.42187500,    0.23437500,     0.01562500,     0.20312500};
	["DELETE"] = { 0.01562500,    0.20312500,     0.01562500,     0.20312500};
};

function SquareButton_SetIcon(self, name)
	local coords = SQUARE_BUTTON_TEXCOORDS[strupper(name)];
	if (coords) then
		self.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	end
end


-- Cap progress bar
function CapProgressBar_SetNotches(capBar, count)
	local barWidth = capBar:GetWidth();
	local barName = capBar:GetName();
	
	if ( capBar.notchCount and capBar.notchCount > count ) then
		for i = count + 1, capBar.notchCount do
			_G[barName.."Divider"..i]:Hide();
		end
	end
	
	local notchWidth = barWidth / count;
	
	for i=1, count - 1 do
		local notch = _G[barName.."Divider"..i];
		if ( not notch ) then
			notch = capBar:CreateTexture(barName.."Divider"..i, "BORDER", "CapProgressBarDividerTemplate", -1);
		end
		notch:ClearAllPoints();
		notch:SetPoint("LEFT", capBar, "LEFT", notchWidth * i - 2, 0);
	end
	capBar.notchCount = count;
end

function CapProgressBar_Update(capBar, cap1Quantity, cap1Limit, cap2Quantity, cap2Limit, totalQuantity, totalLimit, hasNoSharedStats)
	if ( totalLimit == 0) then
		return;
	end
	
	local barWidth = capBar:GetWidth() - 4;
	local sizePerPoint = barWidth / totalLimit;
	local progressWidth = totalQuantity * sizePerPoint;
	
	local cap1Width, cap2Width;
	if ( cap2Quantity and cap2Limit ) then
		cap1Width = min(cap1Limit - cap1Quantity, cap2Limit - cap2Quantity) * sizePerPoint;	--cap1 can't go past the cap2 LFG limit either.
		cap2Width = (cap2Limit - cap2Quantity) * sizePerPoint - cap1Width;
	else
		cap1Width = (cap1Limit - cap1Quantity) * sizePerPoint;
		cap2Width = 0;
	end
	
	--Don't let it go past the end.
	progressWidth = min(progressWidth, barWidth);
	cap1Width = min(cap1Width, barWidth - progressWidth);
	cap2Width = min(cap2Width, barWidth - progressWidth - cap1Width);
	capBar.progress:SetWidth(progressWidth);
	
	capBar.cap1:SetWidth(cap1Width);
	capBar.cap2:SetWidth(cap2Width);
	
	local lastFrame, lastRelativePoint = capBar, "LEFT";
	
	if ( progressWidth > 0 ) then
		capBar.progress:Show();
		capBar.progress:SetPoint("LEFT", lastFrame, lastRelativePoint, 2, 0);
		lastFrame, lastRelativePoint = capBar.progress, "RIGHT";
	else
		capBar.progress:Hide();
	end
	
	if ( cap1Width > 0 and not hasNoSharedStats) then
		capBar.cap1:Show();
		capBar.cap1Marker:Show();
		capBar.cap1:SetPoint("LEFT", lastFrame, lastRelativePoint, 0, 0);
		lastFrame, lastRelativePoint = capBar.cap1, "RIGHT";
	else
		capBar.cap1:Hide();
		capBar.cap1Marker:Hide();
	end
	
	if ( cap2Width > 0 and not hasNoSharedStats) then
		capBar.cap2:Show();
		capBar.cap2Marker:Show();
		capBar.cap2:SetPoint("LEFT", lastFrame, lastRelativePoint, 0, 0);
		lastFrame, lastRelativePoint = capBar.cap2, "RIGHT";
	else
		capBar.cap2:Hide();
		capBar.cap2Marker:Hide();
	end
end

function InputScrollFrame_OnLoad(self)
	local scrollBar = self.ScrollBar;
	scrollBar:SetFrameLevel(self.FocusButton:GetFrameLevel() + 2);
	scrollBar:ClearAllPoints();
	scrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", -13, -11);
	scrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -13, 9);
	-- reposition the up and down buttons
	self.ScrollBar.ScrollDownButton:SetPoint("TOP", scrollBar, "BOTTOM", 0, 4);
	self.ScrollBar.ScrollUpButton:SetPoint("BOTTOM", scrollBar, "TOP", 0, -4);
	-- make the scroll bar hideable and force it to start off hidden so positioning calculations can be done
	-- as soon as it needs to be shown
	self.scrollBarHideable = 1;
	scrollBar:Hide();
	self.EditBox:SetWidth(self:GetWidth() - 18);
	self.EditBox:SetMaxLetters(self.maxLetters);
	self.EditBox.Instructions:SetText(self.instructions);
	self.CharCount:SetShown(not self.hideCharCount);
end

--Radio button functions
function SetCheckButtonIsRadio(button, isRadio)
	if ( isRadio ) then
		button:SetNormalTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetNormalTexture():SetTexCoord(0, 0.25, 0, 1);
		
		button:SetHighlightTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetHighlightTexture():SetTexCoord(0.5, 0.75, 0, 1);
		
		button:SetCheckedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetCheckedTexture():SetTexCoord(0.25, 0.5, 0, 1);
		
		button:SetPushedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetPushedTexture():SetTexCoord(0, 0.25, 0, 1);
		
		button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-RadioButton");
		button:GetDisabledCheckedTexture():SetTexCoord(0.75, 1, 0, 1);
	else
		button:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up");
		button:GetNormalTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight");
		button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
		button:GetPushedTexture():SetTexCoord(0, 1, 0, 1);
		
		button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
		button:GetDisabledCheckedTexture():SetTexCoord(0, 1, 0, 1);
	end	
end
