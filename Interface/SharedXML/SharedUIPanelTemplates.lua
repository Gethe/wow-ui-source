-- Panel Positions
PANEL_INSET_LEFT_OFFSET = 4;
PANEL_INSET_RIGHT_OFFSET = -6;
PANEL_INSET_BOTTOM_OFFSET = 4;
PANEL_INSET_BOTTOM_BUTTON_OFFSET = 26;
PANEL_INSET_TOP_OFFSET = -24;
PANEL_INSET_ATTIC_OFFSET = -60;

-- Magic Button code
function MagicButton_OnLoad(self)
	local leftHandled = false;
	local rightHandled = false;

	-- Find out where this button is anchored and adjust positions/separators as necessary
	for i=1, self:GetNumPoints() do
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(i);

		if (relativeTo:GetObjectType() == "Button" and (point == "TOPLEFT" or point == "LEFT")) then

			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 1, 0);
			end

			leftHandled = true;

		elseif (relativeTo:GetObjectType() == "Button" and (point == "TOPRIGHT" or point == "RIGHT")) then

			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, -1, 0);
			end

			rightHandled = true;

		elseif (point == "BOTTOMLEFT") then
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 4, 4);
			end
			leftHandled = true;
		elseif (point == "BOTTOMRIGHT") then
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, -6, 4);
			end
			rightHandled = true;
		elseif (point == "BOTTOM") then
			if (offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 0, 4);
			end
		end
	end
end

function DynamicResizeButton_Resize(self)
	local padding = 40;
	local width = self:GetWidth();
	local textWidth = self:GetTextWidth() + padding;
	self:SetWidth(math.max(width, textWidth));
end

-- Frame template utilities to show/hide various decorative elements and to resize content areas
function FrameTemplate_SetAtticHeight(self, atticHeight)
	if self.bottomInset then
		self.bottomInset:SetPoint("TOPLEFT", self, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, -atticHeight);
	else
		self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, -atticHeight);
	end
end

function FrameTemplate_SetButtonBarHeight(self, buttonBarHeight)
	if self.topInset then
		self.topInset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, buttonBarHeight);
	else
		self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, buttonBarHeight);
	end
end

-- ButtonFrameTemplate code
function ButtonFrameTemplate_HideButtonBar(self)
	FrameTemplate_SetButtonBarHeight(self, PANEL_INSET_BOTTOM_OFFSET);
end

function ButtonFrameTemplate_ShowButtonBar(self)
	FrameTemplate_SetButtonBarHeight(self, PANEL_INSET_BOTTOM_BUTTON_OFFSET);
end

function ButtonFrameTemplate_HideAttic(self)
	FrameTemplate_SetAtticHeight(self, -PANEL_INSET_TOP_OFFSET);

	if self.TopTileStreaks then
		self.TopTileStreaks:Hide();
	end
end

function ButtonFrameTemplate_ShowAttic(self)
	FrameTemplate_SetAtticHeight(self, -PANEL_INSET_ATTIC_OFFSET);

	if self.TopTileStreaks then
		self.TopTileStreaks:Show();
	end
end

function ButtonFrameTemplate_HidePortrait(self)
	self:SetBorder("ButtonFrameTemplateNoPortrait");
	self:SetPortraitShown(false);
end

function ButtonFrameTemplate_ShowPortrait(self)
	self:SetBorder("PortraitFrameTemplate");
	self:SetPortraitShown(true);
end

function ButtonFrameTemplateMinimizable_HidePortrait(self)
	self:SetBorder("ButtonFrameTemplateNoPortraitMinimizable");
	self:SetPortraitShown(false);
end

function ButtonFrameTemplateMinimizable_ShowPortrait(self)
	self:SetBorder("PortraitFrameTemplateMinimizable");
	self:SetPortraitShown(true);
end

-- A bit ugly, we want the talent frame to display a dialog box in certain conditions.
function UIPanelCloseButton_OnClick(self)
	local parent = self:GetParent();
	if parent then
		if parent.onCloseCallback then
			parent.onCloseCallback(self);
		else
			HideUIPanel(parent);
		end
	end
end

function UIPanelStaticPopupSpecialCloseButton_OnClick(self)
	StaticPopupSpecial_Hide(self:GetParent());
end

function UIPanelCloseButton_SetBorderAtlas(self, atlas, xOffset, yOffset, textureKit)
	local border = self.Border or self:CreateTexture(nil, "OVERLAY", nil, 7);
	self.Border = border;

	if textureKit then
		-- NOTE: Using atlas as the texture kit format string here.
		SetupTextureKitOnFrame(textureKit, border, atlas, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	else
		border:SetAtlas(atlas, true);
	end

	border:SetPoint("CENTER", self, "CENTER", xOffset or 0, yOffset or 0);
end

function UIPanelCloseButton_SetBorderShown(self, shown)
	if self.Border then
		self.Border:SetShown(shown);
	end
end

-- Scrollframe functions
function ScrollFrame_OnLoad(self)
	local scrollbar = self.ScrollBar or _G[self:GetName().."ScrollBar"];
	scrollbar:SetMinMaxValues(0, 0);
	scrollbar:SetValue(0);
	self.offset = 0;

	local scrollDownButton = scrollbar.ScrollDownButton or _G[scrollbar:GetName().."ScrollDownButton"];
	local scrollUpButton = scrollbar.ScrollUpButton or _G[scrollbar:GetName().."ScrollUpButton"];

	scrollDownButton:Disable();
	scrollUpButton:Disable();

	if ( self.scrollBarHideable ) then
		scrollbar:Hide();
		scrollDownButton:Hide();
		scrollUpButton:Hide();
	else
		scrollDownButton:Disable();
		scrollUpButton:Disable();
		scrollDownButton:Show();
		scrollUpButton:Show();
	end
	if ( self.noScrollThumb ) then
		(scrollbar.ThumbTexture or _G[scrollbar:GetName().."ThumbTexture"]):Hide();
	end
end

function ScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or self.ScrollBar or _G[self:GetName() .. "ScrollBar"];
	local scrollStep = scrollBar.scrollStep or scrollBar:GetHeight() / 2
	if ( value > 0 ) then
		scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
	else
		scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
	end
end

function ScrollFrame_OnScrollRangeChanged(self, xrange, yrange)
	local name = self:GetName();
	local scrollbar = self.ScrollBar or _G[name.."ScrollBar"];
	if ( not yrange ) then
		yrange = self:GetVerticalScrollRange();
	end

	-- Accounting for very small ranges
	yrange = floor(yrange);

	local value = min(scrollbar:GetValue(), yrange);
	scrollbar:SetMinMaxValues(0, yrange);
	scrollbar:SetValue(value);

	local scrollDownButton = scrollbar.ScrollDownButton or _G[scrollbar:GetName().."ScrollDownButton"];
	local scrollUpButton = scrollbar.ScrollUpButton or _G[scrollbar:GetName().."ScrollUpButton"];
	local thumbTexture = scrollbar.ThumbTexture or _G[scrollbar:GetName().."ThumbTexture"];

	if ( yrange == 0 ) then
		if ( self.scrollBarHideable ) then
			scrollbar:Hide();
			scrollDownButton:Hide();
			scrollUpButton:Hide();
			thumbTexture:Hide();
		else
			scrollDownButton:Disable();
			scrollUpButton:Disable();
			scrollDownButton:Show();
			scrollUpButton:Show();
			if ( not self.noScrollThumb ) then
				thumbTexture:Show();
			end
		end
	else
		scrollDownButton:Show();
		scrollUpButton:Show();
		scrollbar:Show();
		if ( not self.noScrollThumb ) then
			thumbTexture:Show();
		end
		-- The 0.005 is to account for precision errors
		if ( yrange - value > 0.005 ) then
			scrollDownButton:Enable();
		else
			scrollDownButton:Disable();
		end
	end

	-- Hide/show scrollframe borders
	local top = self.Top or name and _G[name.."Top"];
	local bottom = self.Bottom or name and _G[name.."Bottom"];
	local middle = self.Middle or name and _G[name.."Middle"];
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

function ScrollBar_AdjustAnchors(scrollBar, topAdj, bottomAdj, xAdj)
	-- assumes default anchoring of topleft-topright, bottomleft-bottomright
	local topY = 0;
	local bottomY = 0;
	local point, parent, refPoint, x, y;
	for i = 1, 2 do
		point, parent, refPoint, x, y = scrollBar:GetPoint(i);
		if ( point == "TOPLEFT" ) then
			topY = y;
		elseif ( point == "BOTTOMLEFT" ) then
			bottomY = y;
		end
	end
	xAdj = xAdj or 0;
	topAdj = topAdj or 0;
	bottomAdj = bottomAdj or 0;
	scrollBar:SetPoint("TOPLEFT", parent, "TOPRIGHT", x + xAdj, topY + topAdj);
	scrollBar:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", x + xAdj, bottomY + bottomAdj);
end

function ScrollBar_Disable(scrollBar)
	scrollBar:Disable();
	local scrollDownButton = scrollBar.ScrollDownButton or _G[scrollBar:GetName().."ScrollDownButton"];
	if scrollDownButton then
		scrollDownButton:Disable();
	end
	local scrollUpButton = scrollBar.ScrollUpButton or _G[scrollBar:GetName().."ScrollUpButton"];
	if scrollUpButton then
		scrollUpButton:Disable();
	end
end

function ScrollBar_Enable(scrollBar)
	scrollBar:Enable();
	local currValue = scrollBar:GetValue();
	local minVal, maxVal = scrollBar:GetMinMaxValues();
	local scrollDownButton = scrollBar.ScrollDownButton or _G[scrollBar:GetName().."ScrollDownButton"];
	if scrollDownButton and currValue < maxVal then
		scrollDownButton:Enable();
	end
	local scrollUpButton = scrollBar.ScrollUpButton or _G[scrollBar:GetName().."ScrollUpButton"];
	if scrollUpButton and currValue > minVal then
		scrollUpButton:Enable();
	end
end

function HideParentPanel(self)
	HideUIPanel(self:GetParent());
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

function EditBox_SetFocus (self)
	self:SetFocus();
end

function InputBoxInstructions_OnTextChanged(self)
	self.Instructions:SetShown(self:GetText() == "")
end

function InputBoxInstructions_UpdateColorForEnabledState(self, color)
	if color then
		self:SetTextColor(color:GetRGBA());
	end
end

function InputBoxInstructions_OnDisable(self)
	InputBoxInstructions_UpdateColorForEnabledState(self, self.disabledColor);
end

function InputBoxInstructions_OnEnable(self)
	InputBoxInstructions_UpdateColorForEnabledState(self, self.enabledColor);
end

function SearchBoxTemplate_OnLoad(self)
	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	self:SetTextInsets(16, 20, 0, 0);
	self.Instructions:SetText(SEARCH);
	self.Instructions:ClearAllPoints();
	self.Instructions:SetPoint("TOPLEFT", self, "TOPLEFT", 16, 0);
	self.Instructions:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -20, 0);
end

function SearchBoxTemplate_OnEditFocusLost(self)
	if ( self:GetText() == "" ) then
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();
	end
end

function SearchBoxTemplate_OnEditFocusGained(self)
	self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
	self.clearButton:Show();
end

function SearchBoxTemplate_OnTextChanged(self)
	if ( not self:HasFocus() and self:GetText() == "" ) then
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();
	else
		self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.clearButton:Show();
	end
	InputBoxInstructions_OnTextChanged(self);
end

function SearchBoxTemplateClearButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local editBox = self:GetParent();
	editBox:SetText("");
	editBox:ClearFocus();
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

local function GetTabByIndex(frame, index)
	return frame.Tabs and frame.Tabs[index] or _G[frame:GetName().."Tab"..index];
end

function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = GetTabByIndex(frame, i);
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

	local buttonMiddle = tab.Middle or tab.middleTexture or _G[tabName.."Middle"];
	local buttonMiddleDisabled = tab.MiddleDisabled or (tabName and _G[tabName.."MiddleDisabled"]);
	local left = tab.Left or tab.leftTexture or _G[tabName.."Left"];
	local sideWidths = 2 * left:GetWidth();
	local tabText = tab.Text or _G[tab:GetName().."Text"];
	local highlightTexture = tab.HighlightTexture or (tabName and _G[tabName.."HighlightTexture"]);

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

function PanelTemplates_ResizeTabsToFit(frame, maxWidthForAllTabs)
	local selectedIndex = PanelTemplates_GetSelectedTab(frame);
	if ( not selectedIndex ) then
		return;
	end

	local currentWidth = 0;
	local truncatedText = false;
	for i = 1, frame.numTabs do
		local tab = GetTabByIndex(frame, i);
		currentWidth = currentWidth + tab:GetWidth();
		if tab.Text and tab.Text:IsTruncated() then
			truncatedText = true;
		end
	end
	if ( not truncatedText and currentWidth <= maxWidthForAllTabs ) then
		return;
	end

	local currentTab = GetTabByIndex(frame, selectedIndex);
	PanelTemplates_TabResize(currentTab, 0);
	local availableWidth = maxWidthForAllTabs - currentTab:GetWidth();
	local widthPerTab = availableWidth / (frame.numTabs - 1);
	for i = 1, frame.numTabs do
		if ( i ~= selectedIndex ) then
			local tab = GetTabByIndex(frame, i);
			PanelTemplates_TabResize(tab, 0, widthPerTab);
		end
	end
end

function PanelTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function PanelTemplates_DisableTab(frame, index)
	GetTabByIndex(frame, index).isDisabled = 1;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_EnableTab(frame, index)
	local tab = GetTabByIndex(frame, index);
	tab.isDisabled = nil;
	-- Reset text color
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_HideTab(frame, index)
	local tab = GetTabByIndex(frame, index);
	tab:Hide();
end

function PanelTemplates_ShowTab(frame, index)
	local tab = GetTabByIndex(frame, index);
	tab:Show();
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

	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(tab) then
		tooltip:Hide();
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

function ScrollingEdit_OnTextChanged(self, scrollFrame)
	-- force an update when the text changes
	self.handleCursorChange = true;
	ScrollingEdit_OnUpdate(self, 0, scrollFrame);
end

function ScrollingEdit_OnLoad(self)
	ScrollingEdit_SetCursorOffsets(self, 0, 0);
end

function ScrollingEdit_SetCursorOffsets(self, offset, height)
	self.cursorOffset = offset;
	self.cursorHeight = height;
end

function ScrollingEdit_OnCursorChanged(self, x, y, w, h)
	ScrollingEdit_SetCursorOffsets(self, y, h);
	self.handleCursorChange = true;
end

NumericInputSpinnerMixin = {};

-- "public"
function NumericInputSpinnerMixin:SetValue(value)
	local newValue = Clamp(value, self.min or -math.huge, self.max or math.huge);
	if newValue ~= self.currentValue then
		self.currentValue = newValue;
		self:SetNumber(newValue);

		if self.onValueChangedCallback then
			self.onValueChangedCallback(self, self:GetNumber());
		end
	end
end

function NumericInputSpinnerMixin:SetMinMaxValues(min, max)
	if self.min ~= min or self.max ~= max then
		self.min = min;
		self.max = max;

		self:SetValue(self:GetValue());
	end
end

function NumericInputSpinnerMixin:GetValue()
	return self.currentValue or self.min or 0;
end

function NumericInputSpinnerMixin:SetOnValueChangedCallback(onValueChangedCallback)
	self.onValueChangedCallback = onValueChangedCallback;
end

function NumericInputSpinnerMixin:Increment(amount)
	self:SetValue(self:GetValue() + (amount or 1));
end

function NumericInputSpinnerMixin:Decrement(amount)
	self:SetValue(self:GetValue() - (amount or 1));
end

function NumericInputSpinnerMixin:SetEnabled(enable)
	self.IncrementButton:SetEnabled(enable);
	self.DecrementButton:SetEnabled(enable);
	getmetatable(self).__index.SetEnabled(self, enable);
end

function NumericInputSpinnerMixin:Enable()
	self:SetEnabled(true)
end

function NumericInputSpinnerMixin:Disable()
	self:SetEnabled(false)
end

-- "private"
function NumericInputSpinnerMixin:OnTextChanged()
	self:SetValue(self:GetNumber());
end

local MAX_TIME_BETWEEN_CHANGES_SEC = .5;
local MIN_TIME_BETWEEN_CHANGES_SEC = .075;
local TIME_TO_REACH_MAX_SEC = 3;

function NumericInputSpinnerMixin:StartIncrement()
	self.incrementing = true;
	self.startTime = GetTime();
	self.nextUpdate = MAX_TIME_BETWEEN_CHANGES_SEC;
	self:SetScript("OnUpdate", self.OnUpdate);
	self:Increment();
	self:ClearFocus();
end

function NumericInputSpinnerMixin:EndIncrement()
	self:SetScript("OnUpdate", nil);
end

function NumericInputSpinnerMixin:StartDecrement()
	self.incrementing = false;
	self.startTime = GetTime();
	self.nextUpdate = MAX_TIME_BETWEEN_CHANGES_SEC;
	self:SetScript("OnUpdate", self.OnUpdate);
	self:Decrement();
	self:ClearFocus();
end

function NumericInputSpinnerMixin:EndDecrement()
	self:SetScript("OnUpdate", nil);
end

function NumericInputSpinnerMixin:OnUpdate(elapsed)
	self.nextUpdate = self.nextUpdate - elapsed;
	if self.nextUpdate <= 0 then
		if self.incrementing then
			self:Increment();
		else
			self:Decrement();
		end

		local totalElapsed = GetTime() - self.startTime;

		local nextUpdateDelta = Lerp(MAX_TIME_BETWEEN_CHANGES_SEC, MIN_TIME_BETWEEN_CHANGES_SEC, Saturate(totalElapsed / TIME_TO_REACH_MAX_SEC));
		self.nextUpdate = self.nextUpdate + nextUpdateDelta;
	end
end

MaximizeMinimizeButtonFrameMixin = {};

function MaximizeMinimizeButtonFrameMixin:OnShow()
	if self.isAutomaticAction then
		self.isAutomaticAction = false;
	elseif self.cvar then
		local minimized = GetCVarBool(self.cvar);
		if minimized then
			self:Minimize();
		else
			self:Maximize();
		end
	end
end

function MaximizeMinimizeButtonFrameMixin:IsMinimized()
	return self.isMinimized;
end

function MaximizeMinimizeButtonFrameMixin:SetMinimizedCVar(cvar)
	self.cvar = cvar;
end

function MaximizeMinimizeButtonFrameMixin:SetOnMaximizedCallback(maximizedCallback)
	self.maximizedCallback = maximizedCallback;
end

function MaximizeMinimizeButtonFrameMixin:Maximize(isAutomaticAction)
	if self.maximizedCallback then
		self.maximizedCallback(self);
	end

	if not isAutomaticAction and self.cvar then
		SetCVar(self.cvar, 0);
	end

	self.isMinimized = false;
	self.isAutomaticAction = isAutomaticAction;

	self:SetMinimizedLook();
end

function MaximizeMinimizeButtonFrameMixin:SetOnMinimizedCallback(minimizedCallback)
	self.minimizedCallback = minimizedCallback;
end

function MaximizeMinimizeButtonFrameMixin:Minimize(isAutomaticAction)
	if self.minimizedCallback then
		self:minimizedCallback();
	end

	if not isAutomaticAction and self.cvar then
		SetCVar(self.cvar, 1);
	end

	self.isMinimized = true;
	self.isAutomaticAction = isAutomaticAction;

	self:SetMaximizedLook();
end

function MaximizeMinimizeButtonFrameMixin:SetMinimizedLook()
	self.MaximizeButton:Hide();
	self.MinimizeButton:Show();
end

function MaximizeMinimizeButtonFrameMixin:SetMaximizedLook()
	self.MaximizeButton:Show();
	self.MinimizeButton:Hide();
end

-- Truncated Button code

function TruncatedButton_OnSizeChanged(self, width, height)
	self.Text:SetWidth(width - 5);
	self.Text:SetHeight(height);
end

function TruncatedButton_OnEnter(self)
	if self.Text:IsTruncated() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		tooltip:SetText(self.Text:GetText());
		tooltip:Show();
	end
end

function TruncatedButton_OnLeave(self)
	local tooltip = GetAppropriateTooltip();
	if tooltip:GetOwner() == self then
		tooltip:Hide();
	end
end

-- Truncated Tooltip Script code

function TruncatedTooltipScript_OnEnter(self)
	local text = self.truncatedTooltipScriptText or self.Text;
	if text:IsTruncated() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(tooltip, text:GetText());
		tooltip:Show();
	end
end

function TruncatedTooltipScript_OnLeave(self)
	local tooltip = GetAppropriateTooltip();
	if tooltip:GetOwner() == self then
		tooltip:Hide();
	end
end

-- Add more methods as needed to pass functionality through to the FontString (like SetText and SetTextColor below)
TruncatedTooltipFontStringWrapperMixin = {}

function TruncatedTooltipFontStringWrapperMixin:SetText(...)
	self.Text:SetText(...);
	self:MarkDirty();
end

function TruncatedTooltipFontStringWrapperMixin:SetTextColor(...)
	self.Text:SetTextColor(...);
end

function TruncatedTooltipFontStringWrapperMixin:OnEnter()
	if self.Text:IsTruncated() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		tooltip:SetText(self.Text:GetText());
		tooltip:Show();
	end
end

function TruncatedTooltipFontStringWrapperMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	if tooltip:GetOwner() == self then
		tooltip:Hide();
	end
end

function GetAppropriateTopLevelParent()
	return UIParent or GlueParent;
end

function SetAppropriateTopLevelParent(frame)
	local parent = GetAppropriateTopLevelParent();
	if parent then
		frame:SetParent(parent);
	end
end

function GetAppropriateTooltip()
	return UIParent and GameTooltip or GlueTooltip;
end

ColumnDisplayMixin = {};

function ColumnDisplayMixin:OnLoad()
	self.columnHeaders = CreateFramePool("BUTTON", self, "ColumnDisplayButtonTemplate");
end

--[[
The layout of your column display might look something like:
local FOO_COLUMN_INFO = {
	[1] = {
		title = FOO_COLUMN_xxx_TITLE,
		width = 60,
	},

	...

	[5] = {
		title = FOO_COLUMN_xxxxx_TITLE,
		width = 0,
	},
};
--]]

function ColumnDisplayMixin:LayoutColumns(columnInfo, extraColumnInfo)
	self.columnHeaders:ReleaseAll();

	local extraHeader = nil;
	if extraColumnInfo then
		extraHeader = self.columnHeaders:Acquire();
		extraHeader:SetText(extraColumnInfo.title);
		extraHeader:SetWidth(extraColumnInfo.width);
		extraHeader:SetPoint("BOTTOMRIGHT", -28, 1);
		extraHeader:SetID(#columnInfo + 1);
		extraHeader:Show();
	end

	local previousHeader = nil;
	for i, info in ipairs(columnInfo) do
		local header = self.columnHeaders:Acquire();
		header:SetText(info.title);
		header:SetWidth(info.width);
		header:SetID(i);
		if i == 1 then
			header:SetPoint("BOTTOMLEFT", 2, 1);
			if #columnInfo == 1 then
				header:SetPoint("BOTTOMRIGHT");
			end
		else
			header:SetPoint("BOTTOMLEFT", previousHeader, "BOTTOMRIGHT", -2, 0);

			if i == #columnInfo and info.width == 0 then
				if extraHeader then
					header:SetPoint("BOTTOMRIGHT", extraHeader, "BOTTOMLEFT", 2, 0);
				else
					header:SetPoint("BOTTOMRIGHT", -28, 1);
				end
			end
		end

		header:Show();
		previousHeader = header;
	end
end

function ColumnDisplayMixin:OnClick(columnIndex)
	if self.sortingFunction then
		self.sortingFunction(self, columnIndex);
	end
end

function ColumnDisplayButton_OnClick(self)
	self:GetParent():OnClick(self:GetID());
end

IconButtonMixin = {};

function IconButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self, "CENTER", 0, -1);
	end
end

function IconButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER", self, "CENTER", -1, 0);
end

SquareIconButtonMixin = {};

function SquareIconButtonMixin:OnLoad()
	if self.icon then
		self:SetIcon(self.icon);
	elseif self.iconAtlas then
		self:SetAtlas(self.iconAtlas);
	end
end

function SquareIconButtonMixin:SetIcon(icon)
	self.Icon:SetTexture(icon);
end

function SquareIconButtonMixin:SetAtlas(atlas)
	self.Icon:SetAtlas(atlas);
end

function SquareIconButtonMixin:SetOnClickHandler(onClickHandler)
	self.onClickHandler = onClickHandler;
end

function SquareIconButtonMixin:SetTooltipInfo(tooltipTitle, tooltipText)
	self.tooltipTitle = tooltipTitle;
	self.tooltipText = tooltipText;
end

function SquareIconButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		-- Square icon button template still uses down-to-the-left depress behavior to match the existing art.
		self.Icon:SetPoint("CENTER", self, "CENTER", -2, -1);
	end
end

function SquareIconButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER", self, "CENTER", -1, 0);
end

function SquareIconButtonMixin:OnEnter()
	if self.tooltipTitle then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -8, -8);
		GameTooltip_SetTitle(GameTooltip, self.tooltipTitle);

		if self.tooltipText then
			local wrap = true;
			GameTooltip_AddNormalLine(GameTooltip, self.tooltipText, wrap);
		end

		GameTooltip:Show();
	end
end

function SquareIconButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function SquareIconButtonMixin:OnClick(...)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if self.onClickHandler then
		self.onClickHandler(self, ...);
	end
end

function SquareIconButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled);
	self.Icon:SetDesaturated(not enabled);
end

UIMenuButtonStretchMixin = {}

function UIMenuButtonStretchMixin:SetTextures(texture)
	self.TopLeft:SetTexture(texture);
	self.TopRight:SetTexture(texture);
	self.BottomLeft:SetTexture(texture);
	self.BottomRight:SetTexture(texture);
	self.TopMiddle:SetTexture(texture);
	self.MiddleLeft:SetTexture(texture);
	self.MiddleRight:SetTexture(texture);
	self.BottomMiddle:SetTexture(texture);
	self.MiddleMiddle:SetTexture(texture);
end

function UIMenuButtonStretchMixin:OnMouseDown(button)
	if ( self:IsEnabled() ) then
		self:SetTextures("Interface\\Buttons\\UI-Silver-Button-Down");
		if ( self.Icon ) then
			if ( not self.Icon.oldPoint ) then
				local point, relativeTo, relativePoint, x, y = self.Icon:GetPoint(1);
				self.Icon.oldPoint = point;
				self.Icon.oldX = x;
				self.Icon.oldY = y;
			end
			self.Icon:SetPoint(self.Icon.oldPoint, self.Icon.oldX + 1, self.Icon.oldY - 1);
		end
	end
end

function UIMenuButtonStretchMixin:OnMouseUp(button)
	if ( self:IsEnabled() ) then
		self:SetTextures("Interface\\Buttons\\UI-Silver-Button-Up");
		if ( self.Icon ) then
			self.Icon:SetPoint(self.Icon.oldPoint, self.Icon.oldX, self.Icon.oldY);
		end
	end
end

function UIMenuButtonStretchMixin:OnShow()
	-- we need to reset our textures just in case we were hidden before a mouse up fired
	self:SetTextures("Interface\\Buttons\\UI-Silver-Button-Up");
end

function UIMenuButtonStretchMixin:OnEnable()
	self:SetTextures("Interface\\Buttons\\UI-Silver-Button-Up");
end

function UIMenuButtonStretchMixin:OnEnter()
	if(self.tooltipText ~= nil) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipText);
		GameTooltip:Show();
	end
end

function UIMenuButtonStretchMixin:OnLeave()
	if(self.tooltipText ~= nil) then
		GameTooltip:Hide();
	end
end

DialogHeaderMixin = {};

function DialogHeaderMixin:OnLoad()
	if self.textString then
		self:Setup(self.textString);
	end
end

function DialogHeaderMixin:Setup(text)
	self.Text:SetText(text);
	self:SetWidth(self.Text:GetWidth() + self.headerTextPadding);
end

UIButtonMixin = {}

function UIButtonMixin:InitButton()
	self:SetNormalAtlas(self.atlasName);
	self:SetPushedAtlas(self.atlasName.."-Pressed");
	self:SetDisabledAtlas(self.atlasName.."-Disabled");
	self:SetHighlightAtlas(self.atlasName.."-Highlight");
end

function UIButtonMixin:GetAppropriateTooltip()
	return UIParent and GameTooltip or GlueTooltip;
end

function UIButtonMixin:OnEnter()
	local tooltipText = GetValueOrCallFunction(self, "tooltip");
	if tooltipText then
		local tooltip = self:GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		tooltip:SetText(tooltipText);
	end
end

function UIButtonMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

ThreeSliceButtonMixin = CreateFromMixins(UIButtonMixin);

function ThreeSliceButtonMixin:GetLeftAtlasName()
	return self.atlasName.."-Left";
end

function ThreeSliceButtonMixin:GetRightAtlasName()
	return self.atlasName.."-Right";
end

function ThreeSliceButtonMixin:GetCenterAtlasName()
	return "_"..self.atlasName.."-Center";
end

function ThreeSliceButtonMixin:GetHighlightAtlasName()
	return self.atlasName.."-Highlight";
end

function ThreeSliceButtonMixin:InitButton()
	self.leftAtlasInfo = C_Texture.GetAtlasInfo(self:GetLeftAtlasName());
	self.rightAtlasInfo = C_Texture.GetAtlasInfo(self:GetRightAtlasName());

	self:SetHighlightAtlas(self:GetHighlightAtlasName());
end

function ThreeSliceButtonMixin:UpdateScale()
	local buttonHeight = self:GetHeight();
	local buttonWidth = self:GetWidth();
	local scale = buttonHeight / self.leftAtlasInfo.height;
	self.Left:SetScale(scale);
	self.Right:SetScale(scale);

	local leftWidth = self.leftAtlasInfo.width * scale;
	local rightWidth = self.rightAtlasInfo.width * scale;
	local leftAndRightWidth = leftWidth + rightWidth;

	if leftAndRightWidth > buttonWidth then
		-- At the current buttonHeight, the left and right textures are too big to fit within the button width
		-- So slice some width off of the textures and adjust texture coords accordingly
		local extraWidth = leftAndRightWidth - buttonWidth;
		local newLeftWidth = leftWidth;
		local newRightWidth = rightWidth;

		-- If one of the textures is sufficiently larger than the other one, we can remove all of the width from there
		if (leftWidth - extraWidth) > rightWidth then
			-- left is big enough to take the whole thing...deduct it all from there
			newLeftWidth = leftWidth - extraWidth;
		elseif (rightWidth - extraWidth) > leftWidth then
			-- right is big enough to take the whole thing...deduct it all from there
			newRightWidth = rightWidth - extraWidth;
		else
			-- neither side is sufficiently larger than the other to take the whole extra width
			if leftWidth ~= rightWidth then
				-- so set both widths equal to the smaller size and subtract the difference from extraWidth
				local unevenAmount = math.abs(leftWidth - rightWidth);
				extraWidth = extraWidth - unevenAmount;
				newLeftWidth = math.min(leftWidth, rightWidth);
				newRightWidth = newLeftWidth;
			end
			-- newLeftWidth and newRightWidth are now equal and we just need to remove half of extraWidth from each
			local equallyDividedExtraWidth = extraWidth / 2;
			newLeftWidth = newLeftWidth - equallyDividedExtraWidth;
			newRightWidth = newRightWidth - equallyDividedExtraWidth;
		end

		-- Now set the tex coords and widths of both textures
		local leftPercentage = newLeftWidth / leftWidth;
		self.Left:SetTexCoord(0, leftPercentage, 0, 1);
		self.Left:SetWidth(newLeftWidth / scale);

		local rightPercentage = newRightWidth / rightWidth;
		self.Right:SetTexCoord(1 - rightPercentage, 1, 0, 1);
		self.Right:SetWidth(newRightWidth / scale);
	else
		self.Left:SetTexCoord(0, 1, 0, 1);
		self.Left:SetWidth(self.leftAtlasInfo.width);
		self.Right:SetTexCoord(0, 1, 0, 1);
		self.Right:SetWidth(self.rightAtlasInfo.width);
	end
end

function ThreeSliceButtonMixin:UpdateButton(buttonState)
	buttonState = buttonState or self:GetButtonState();

	if not self:IsEnabled() then
		buttonState = "DISABLED";
	end

	local atlasNamePostfix = "";
	if buttonState == "DISABLED" then
		atlasNamePostfix = "-Disabled";
	elseif buttonState == "PUSHED" then
		atlasNamePostfix = "-Pressed";
	end

	local useAtlasSize = true;
	self.Left:SetAtlas(self:GetLeftAtlasName()..atlasNamePostfix, useAtlasSize);
	self.Center:SetAtlas(self:GetCenterAtlasName()..atlasNamePostfix);
	self.Right:SetAtlas(self:GetRightAtlasName()..atlasNamePostfix, useAtlasSize);

	self:UpdateScale();
end

function ThreeSliceButtonMixin:OnMouseDown()
	self:UpdateButton("PUSHED");
end

function ThreeSliceButtonMixin:OnMouseUp()
	self:UpdateButton("NORMAL");
end

-- Allows inheriting buttons to override OnLoad and OnShow
ButtonControllerMixin = {};

function ButtonControllerMixin:OnLoad()
	if self:GetParent().InitButton then
		self:GetParent():InitButton();
	end
end

function ButtonControllerMixin:OnShow()
	if self:GetParent().UpdateButton then
		self:GetParent():UpdateButton();
	end
end

ResizeCheckButtonMixin = {}

function ResizeCheckButtonMixin:OnLoad()
	self.Label:SetText(self.labelText);
end

function ResizeCheckButtonMixin:OnShow()
	ResizeLayoutMixin.OnShow(self);
end

-- Override in derived mixins
function ResizeCheckButtonMixin:OnCheckButtonClick()
end

SharedEditBoxMixin = {}

function SharedEditBoxMixin:OnLoad()
	local leftAtlasInfo = C_Texture.GetAtlasInfo("common-gray-button-entrybox-left");

	local editBoxHeight = self:GetHeight();
	local scale = editBoxHeight / leftAtlasInfo.height;

	self.Left:SetScale(scale);
	self.Right:SetScale(scale);

	if self.justifyH then
		self:SetJustifyH(self.justifyH);
	end
end

SliderWithButtonsAndLabelMixin = {}

function SliderWithButtonsAndLabelMixin:OnEnter()
end

function SliderWithButtonsAndLabelMixin:OnLeave()
end

function SliderWithButtonsAndLabelMixin:SetupSlider(minValue, maxValue, value, valueStep, label)
	self.minValue = minValue;
	self.maxValue = maxValue;
	self.Slider:SetMinMaxValues(minValue, maxValue);

	self.valueStep = valueStep;
	self.Slider:SetValueStep(valueStep);

	self.value = value;
	self.Slider:SetValue(value);

	self.Label:SetText(label);
end

function SliderWithButtonsAndLabelMixin:OnSliderValueChanged(value, userInput)
	self.value = value;

	self.IncrementButton:SetEnabled(value < self.maxValue);
	self.DecrementButton:SetEnabled(value > self.minValue);
end

function SliderWithButtonsAndLabelMixin:Increment()
	local userInput = true;
	self.Slider:SetValue(self.value + self.valueStep, userInput);
end

function SliderWithButtonsAndLabelMixin:Decrement()
	local userInput = true;
	self.Slider:SetValue(self.value - self.valueStep, userInput);
end

SelectionPopoutWithButtonsAndLabelMixin = {};

function SelectionPopoutWithButtonsAndLabelMixin:SetupSelections(selections, selectedIndex, label)
	self.SelectionPopoutButton:SetupSelections(selections, selectedIndex);
	self.Label:SetText(label);
	self:UpdateButtons();
end

function SelectionPopoutWithButtonsAndLabelMixin:OnEnter()
end

function SelectionPopoutWithButtonsAndLabelMixin:OnLeave()
end

function SelectionPopoutWithButtonsAndLabelMixin:Increment()
	self.SelectionPopoutButton:Increment();
end

function SelectionPopoutWithButtonsAndLabelMixin:Decrement()
	self.SelectionPopoutButton:Decrement();
end

function SelectionPopoutWithButtonsAndLabelMixin:OnPopoutShown()
end

function SelectionPopoutWithButtonsAndLabelMixin:HidePopout()
	self.SelectionPopoutButton:HidePopout();
end

function SelectionPopoutWithButtonsAndLabelMixin:OnEntryClick(entryData)
end

function SelectionPopoutWithButtonsAndLabelMixin:GetTooltipText()
	return self.SelectionPopoutButton:GetTooltipText();
end

function SelectionPopoutWithButtonsAndLabelMixin:OnEntryMouseEnter(entry)
end

function SelectionPopoutWithButtonsAndLabelMixin:OnEntryMouseLeave(entry)
end

function SelectionPopoutWithButtonsAndLabelMixin:GetMaxPopoutHeight()
end

function SelectionPopoutWithButtonsAndLabelMixin:UpdateButtons()
	self.IncrementButton:SetEnabled(self.SelectionPopoutButton.selectedIndex < #self.SelectionPopoutButton.selections);
	self.DecrementButton:SetEnabled(self.SelectionPopoutButton.selectedIndex > 1);
end

SelectionPopoutButtonMixin = {};

function SelectionPopoutButtonMixin:OnLoad()
	self.parent = self:GetParent();
	self.SelectionDetails:SetPoint("CENTER", self.ButtonText,"CENTER");

	self.buttonPool = CreateFramePool("BUTTON", self.Popout, "SelectionPopoutEntryTemplate");
	self.initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.Popout, "TOPLEFT", 6, -12);
end

function SelectionPopoutButtonMixin:HandlesGlobalMouseEvent()
	return true;
end

function SelectionPopoutButtonMixin:OnEnter()
	self.parent:OnEnter();
	if not self.Popout:IsShown() then
		self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox-hover");
	end
end

function SelectionPopoutButtonMixin:OnLeave()
	self.parent:OnLeave();
	if not self.Popout:IsShown() then
		self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox");
	end
end

function SelectionPopoutButtonMixin:OnPopoutShown()
	if self.parent.OnPopoutShown then
		self.parent:OnPopoutShown();
	end
end

function SelectionPopoutButtonMixin:OnHide()
	self:HidePopout();
end

function SelectionPopoutButtonMixin:HidePopout()
	self.Popout:Hide();

	if GetMouseFocus() == self then
		self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox-hover");
	else
		self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox");
	end

	self.HighlightTexture:SetAlpha(0);
end

function SelectionPopoutButtonMixin:ShowPopout()
	if self.popoutNeedsUpdate then
		self:UpdatePopout();
	end

	self.Popout:Show();
	self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox-open");
	self.HighlightTexture:SetAlpha(0.2);
end

function SelectionPopoutButtonMixin:SetupSelections(selections, selectedIndex)
	self.selections = selections;
	self.selectedIndex = selectedIndex;

	if self.Popout:IsShown() then
		self:UpdatePopout();
	else
		self.popoutNeedsUpdate = true;
	end

	self:UpdateButtonDetails();
end

local MAX_POPOUT_ENTRIES_FOR_1_COLUMN = 10;
local MAX_POPOUT_ENTRIES_FOR_2_COLUMNS = 24;
local MAX_POPOUT_ENTRIES_FOR_3_COLUMNS = 36;

local function getNumColumnsAndStride(numSelections, maxStride)
	local numColumns, stride;
	if numSelections > MAX_POPOUT_ENTRIES_FOR_3_COLUMNS then
		numColumns, stride = 4, math.ceil(numSelections / 4);
	elseif numSelections > MAX_POPOUT_ENTRIES_FOR_2_COLUMNS then
		numColumns, stride = 3, math.ceil(numSelections / 3);
	elseif numSelections > MAX_POPOUT_ENTRIES_FOR_1_COLUMN then
		numColumns, stride =  2, math.ceil(numSelections / 2);
	else
		numColumns, stride =  1, numSelections;
	end

	if maxStride and stride > maxStride then
		numColumns = math.ceil(numSelections / maxStride);
		stride = math.ceil(numSelections / numColumns);
	end

	return numColumns, stride;
end

function SelectionPopoutButtonMixin:GetMaxPopoutStride()
	local maxPopoutHeight = self:GetParent():GetMaxPopoutHeight();
	if maxPopoutHeight then
		local selectionHeight = 20;
		return math.floor(maxPopoutHeight / selectionHeight);
	end
end

function SelectionPopoutButtonMixin:UpdatePopout()
	self.buttonPool:ReleaseAll();

	local numColumns, stride = getNumColumnsAndStride(#self.selections, self:GetMaxPopoutStride());
	local buttons = {};

	local hasIneligibleChoice = false;
	for _, selectionData in ipairs(self.selections) do
		if selectionData.ineligibleChoice then
			hasIneligibleChoice = true;
			break;
		end
	end

	local maxDetailsWidth = 0;
	for index, selectionData in ipairs(self.selections) do
		local button = self.buttonPool:Acquire();
		local selectionInfo = self.selections[index];

		local isSelected = (index == self.selectedIndex);
		button:SetupEntry(selectionInfo, index, isSelected, numColumns > 1, hasIneligibleChoice);
		maxDetailsWidth = math.max(maxDetailsWidth, button.SelectionDetails:GetWidth());

		table.insert(buttons, button);
	end

	for _, button in ipairs(buttons) do
		button.SelectionDetails:SetWidth(maxDetailsWidth);
		button:Layout();
		button:Show();
	end

	if stride ~= self.lastStride then
		self.layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, stride);
		self.lastStride = stride;
	end

	AnchorUtil.GridLayout(buttons, self.initialAnchor, self.layout);

	self.popoutNeedsUpdate = false;
end

function SelectionPopoutButtonMixin:GetCurrentSelectedData()
	return self.selections[self.selectedIndex];
end

function SelectionPopoutButtonMixin:UpdateButtonDetails()
	local currentSelectedData = self:GetCurrentSelectedData();
	self.SelectionDetails:SetupDetails(currentSelectedData, self.selectedIndex);
	local maxNameWidth = 126;
	if self.SelectionDetails.SelectionName:GetWidth() > maxNameWidth then
		self.SelectionDetails.SelectionName:SetWidth(maxNameWidth);
	end
	self.SelectionDetails:Layout();
end

function SelectionPopoutButtonMixin:GetTooltipText()
	return self.SelectionDetails:GetTooltipText();
end

function SelectionPopoutButtonMixin:TogglePopout()
	local showPopup = not self.Popout:IsShown();
	if showPopup then
		self:ShowPopout();
	else
		self:HidePopout();
	end
end

function SelectionPopoutButtonMixin:OnMouseWheel(delta)
	if delta > 0 then
		self:Increment();
	else
		self:Decrement();
	end
end

function SelectionPopoutButtonMixin:OnClick()
	self:TogglePopout();
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function SelectionPopoutButtonMixin:OnEntryClick(entryData)
	if self.parent.OnEntryClick then
		self.parent:OnEntryClick(entryData);
	end

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function SelectionPopoutButtonMixin:OnEntryMouseEnter(entry)
	if self.parent.OnEntryMouseEnter then
		self.parent:OnEntryMouseEnter(entry);
	end
end

function SelectionPopoutButtonMixin:OnEntryMouseLeave(entry)
	if self.parent.OnEntryMouseLeave then
		self.parent:OnEntryMouseLeave(entry);
	end
end

function SelectionPopoutButtonMixin:Increment()
	local newIndex = math.min(self.selectedIndex + 1, #self.selections);
	if newIndex ~= self.selectedIndex then
		self.selectedIndex = newIndex;
		self:OnEntryClick(self:GetCurrentSelectedData());
	end
end

function SelectionPopoutButtonMixin:Decrement()
	local newIndex = math.max(self.selectedIndex - 1, 1);
	if newIndex ~= self.selectedIndex then
		self.selectedIndex = newIndex;
		self:OnEntryClick(self:GetCurrentSelectedData());
	end
end

SelectionPopoutDetailsMixin = {};

function SelectionPopoutDetailsMixin:GetTooltipText()
	if self.SelectionName:IsShown() and self.SelectionName:IsTruncated() then
		return self.name;
	end

	return nil;
end

function SelectionPopoutDetailsMixin:AdjustWidth(multipleColumns, defaultWidth)
	local width = defaultWidth;

	if self.ColorSwatch1:IsShown() or self.ColorSwatch2:IsShown() then
		if multipleColumns then
			width = self.SelectionNumber:GetWidth() + self.ColorSwatch2:GetWidth() + 18;
		end
	elseif self.SelectionName:IsShown() then
		if multipleColumns then
			width = 108;
		end
	else
		if multipleColumns then
			width = 42;
		end
	end

	self:SetWidth(Round(width));
end

local function GetNormalSelectionTextFontColor(selectionData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	else
		return DISABLED_FONT_COLOR;
	end
end

local eligibleChoiceColor = CreateColor(.808, 0.808, 0.808);
local ineligibleChoiceColor = CreateColor(.337, 0.337, 0.337);

local function GetFailedReqSelectionTextFontColor(selectionData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	elseif selectionData.ineligibleChoice then
		return ineligibleChoiceColor;
	else
		return eligibleChoiceColor;
	end
end

function SelectionPopoutDetailsMixin:GetFontColors(selectionData, isSelected, hasAFailedReq)
	if self.selectable then
		local fontColorFunction = hasAFailedReq and GetFailedReqSelectionTextFontColor or GetNormalSelectionTextFontColor;
		local fontColor = fontColorFunction(selectionData, isSelected);
		local showAsNew = (selectionData.isNew and self.selectable);
		if showAsNew then
			return fontColor, HIGHLIGHT_FONT_COLOR;
		else
			return fontColor, fontColor;
		end
	else
		return NORMAL_FONT_COLOR, NORMAL_FONT_COLOR;
	end
end

function SelectionPopoutDetailsMixin:UpdateFontColors(selectionData, isSelected, hasAFailedReq)
	local nameColor, numberColor = self:GetFontColors(selectionData, isSelected, hasAFailedReq);
	self.SelectionName:SetTextColor(nameColor:GetRGB());
	self.SelectionNumber:SetTextColor(numberColor:GetRGB());
end

local function startsWithOne(index)
	local indexString = tostring(index);
	return indexString:sub(1, 1) == "1";
end

function SelectionPopoutDetailsMixin:SetShowAsNew(showAsNew)
	if showAsNew then
		self.SelectionNumber:SetShadowColor(NEW_FEATURE_SHADOW_COLOR:GetRGBA());

		local halfStringWidth = self.SelectionNumber:GetStringWidth() / 2;
		local extraOffset = startsWithOne(self.index) and 1 or 0;
		self.NewGlow:SetPoint("CENTER", self.SelectionNumber, "LEFT", halfStringWidth + extraOffset, -2);
		self.SelectionNumberBG:Show();
		self.NewGlow:Show();
	else
		self.SelectionNumber:SetShadowColor(BLACK_FONT_COLOR:GetRGBA());
		self.SelectionNumberBG:Hide();
		self.NewGlow:Hide();
	end
end

function SelectionPopoutDetailsMixin:UpdateText(selectionData, isSelected, hasAFailedReq, hideNumber, hasColors)
	self:UpdateFontColors(selectionData, isSelected, hasAFailedReq);

	self.SelectionNumber:SetText(self.index);
	self.SelectionNumberBG:SetText(self.index);

	if hasColors then
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	elseif selectionData.name ~= "" then
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetText(selectionData.name);
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	else
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(0);
		self.SelectionNumberBG:SetWidth(0);
	end

	self.SelectionNumber:SetShown(not hideNumber);

	local showAsNew = (self.selectable and not hideNumber and selectionData.isNew);
	self:SetShowAsNew(showAsNew);
end

function SelectionPopoutDetailsMixin:SetupDetails(selectionData, index, isSelected, hasAFailedReq)
	self.name = selectionData.name;
	self.index = index;

	local color1 = selectionData.swatchColor1 or selectionData.swatchColor2;
	local color2 = selectionData.swatchColor1 and selectionData.swatchColor2;
	if color1 then
		if color2 then
			self.ColorSwatch2:Show();
			self.ColorSwatch2Glow:Show();
			self.ColorSwatch2:SetVertexColor(color2:GetRGB());
			self.ColorSwatch1:SetAtlas("charactercreate-customize-palette-half");
		else
			self.ColorSwatch2:Hide();
			self.ColorSwatch2Glow:Hide();
			self.ColorSwatch1:SetAtlas("charactercreate-customize-palette");
		end

		self.ColorSwatch1:Show();
		self.ColorSwatch1Glow:Show();
		self.ColorSwatch1:SetVertexColor(color1:GetRGB());
	elseif selectionData.name ~= "" then
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
	else
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
	end

	self.ColorSelected:SetShown(self.selectable and color1 and isSelected);

	local hideNumber = (not self.selectable and (color1 or (selectionData.name ~= "")));
	if hideNumber then
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self, "LEFT", 18, -2);
	else
		self.SelectionName:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 18, -2);
	end

	self:UpdateText(selectionData, isSelected, hasAFailedReq, hideNumber, color1);
end

SelectionPopoutMixin = {};

function SelectionPopoutMixin:OnShow()
	self:Layout();
	self:GetParent():OnPopoutShown();
end

SelectionPopoutEntryMixin = {};

function SelectionPopoutEntryMixin:OnLoad()
	self.SelectionDetails:SetPoint("TOPLEFT", self.ButtonText,"TOPLEFT", 14, 0);
	self.SelectionDetails.SelectionName:SetPoint("RIGHT", self.SelectionDetails, "RIGHT");
	self.parentButton = self:GetParent():GetParent();
end

function SelectionPopoutEntryMixin:HandlesGlobalMouseEvent(buttonID, event)
	return event == "GLOBAL_MOUSE_DOWN" and buttonID == "LeftButton";
end

function SelectionPopoutEntryMixin:SetupEntry(selectionData, index, isSelected, multipleColumns, hasAFailedReq)
	self.isSelected = isSelected;
	self.selectionData = selectionData;
	self.popoutHasAFailedReq = hasAFailedReq;
	self.isNew = selectionData.isNew;

	self.SelectionDetails:SetupDetails(selectionData, index, isSelected, hasAFailedReq);
	self.SelectionDetails:AdjustWidth(multipleColumns, 116);
end

function SelectionPopoutEntryMixin:GetTooltipText()
	return self.SelectionDetails:GetTooltipText();
end

function SelectionPopoutEntryMixin:OnEnter()
	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0.15);
		self.SelectionDetails.SelectionNumber:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.SelectionDetails.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	self.parentButton:OnEntryMouseEnter(self);
end

function SelectionPopoutEntryMixin:OnLeave()
	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0);
		self.SelectionDetails:UpdateFontColors(self.selectionData, self.isSelected, self.popoutHasAFailedReq);
	end

	self.parentButton:OnEntryMouseLeave(self);
end

function SelectionPopoutEntryMixin:OnClick()
	self.parentButton:OnEntryClick(self.selectionData);
end

DefaultScaleFrameMixin = {};

function DefaultScaleFrameMixin:OnDefaultScaleFrameLoad()
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:UpdateScale();
end

function DefaultScaleFrameMixin:OnDefaultScaleFrameEvent(event, ...)
	if event == "DISPLAY_SIZE_CHANGED" then
		self:UpdateScale();
	end
end

function DefaultScaleFrameMixin:UpdateScale()
	ApplyDefaultScale(self, self.minScale, self.maxScale);
end

-- Click to drag directly attached to frame itself.
ClickToDragMixin = {};

function ClickToDragMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function ClickToDragMixin:OnDragStart()
	self:StartMoving();
end

function ClickToDragMixin:OnDragStop()
	self:StopMovingOrSizing();
end

-- Click to drag attached to a subframe. For example, a title bar.
PanelDragBarMixin = {};

function PanelDragBarMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function PanelDragBarMixin:Init(target)
	self.target = target;
end

function PanelDragBarMixin:OnDragStart()
	self.target:StartMoving();
end

function PanelDragBarMixin:OnDragStop()
	self.target:StopMovingOrSizing();
end

PanelResizeButtonMixin = {};

function PanelResizeButtonMixin:Init(target, minWidth, minHeight, maxWidth, maxHeight)
	self.target = target;
	self.minWidth = minWidth;
	self.minHeight = minHeight;
	self.maxWidth = maxWidth;
	self.maxHeight = maxHeight;

	local originalTargetOnSizeChanged = target:GetScript("OnSizeChanged") or nop;
	target:SetScript("OnSizeChanged", function(target, width, height)
		originalTargetOnSizeChanged(target, width, height);

		if width < self.minWidth then
			target:SetWidth(self.minWidth);
		elseif self.maxWidth and width > self.maxWidth then
			target:SetWidth(self.maxWidth);
		end

		if height < self.minHeight then
			target:SetHeight(self.minHeight);
		elseif self.maxHeight and height > self.maxHeight then
			target:SetHeight(self.maxHeight);
		end
	end);
end

function PanelResizeButtonMixin:OnMouseDown()
	if self.target then
		self.target:StartSizing("BOTTOMRIGHT");
	end
end

function PanelResizeButtonMixin:OnMouseUp()
	if self.target then
		self.target:StopMovingOrSizing();

		if self.resizeStoppedCallback ~= nil then
			self.resizeStoppedCallback(self.target);
		end
	end
end

function PanelResizeButtonMixin:SetOnResizeStoppedCallback(resizeStoppedCallback)
	self.resizeStoppedCallback = resizeStoppedCallback;
end

DropDownControlMixin = {};

function DropDownControlMixin:OnLoad()
	local function InitializeDropDownFrame()
		self:Initialize();
	end

	UIDropDownMenu_Initialize(self.DropDownMenu, InitializeDropDownFrame);

	self:UpdateWidth(self:GetWidth());
end

function DropDownControlMixin:UpdateWidth(width)
	UIDropDownMenu_SetWidth(self.DropDownMenu, width - 20);
end

function DropDownControlMixin:Initialize()
	if self.options == nil then
		return;
	end

	local function DropDownControlButton_OnClick(button)
		local isUserInput = true;
		self:SetSelectedValue(button.value, isUserInput);
	end

	for i, option in ipairs(self.options) do
		local info = UIDropDownMenu_CreateInfo();
		if not self.skipNormalSetup then
			info.text = option.text;
			info.minWidth = 108;
			info.value = option.value;
			info.checked = self.selectedValue == option.value;
			info.func = DropDownControlButton_OnClick;
		end

		if self.customSetupCallback ~= nil then
			self.customSetupCallback(info);
		end

		UIDropDownMenu_AddButton(info);
	end
end

function DropDownControlMixin:SetSelectedValue(value, isUserInput)
	self.selectedValue = value;

	if value == nil then
		UIDropDownMenu_SetText(self.DropDownMenu, self.noneSelectedText);
	elseif self.options ~= nil then
		for i, option in ipairs(self.options) do
			if option.value == value then
				UIDropDownMenu_SetText(self.DropDownMenu, option.selectedText or option.text);
			end
		end
	end

	if self.optionSelectedCallback ~= nil then
		self.optionSelectedCallback(value, isUserInput);
	end
end

function DropDownControlMixin:ClearSelectedValue()
	self:SetSelectedValue(nil, false);
end

function DropDownControlMixin:GetSelectedValue()
	return self.selectedValue;
end

function DropDownControlMixin:SetOptionSelectedCallback(optionSelectedCallback)
	self.optionSelectedCallback = optionSelectedCallback;
end

-- options: an array of tables that contain info to display the different dropdown options.
-- Option keys:
--   value: a unique value that identifies the option and is passed through to optionSelectedCallback.
--   text: the text that appears in the dropdown list, and on the dropdown control when an option is selected.
--   selectedText: an override for text that appears on the dropdown control when an option is selected.
function DropDownControlMixin:CreateOption(value, text, selectedText)
    return { value = value, text = text, selectedText = selectedText };
end

function DropDownControlMixin:SetOptions(options, defaultSelectedValue)
	self.options = options;
	self:Initialize();

	if defaultSelectedValue then
		self:SetSelectedValue(defaultSelectedValue);
	end
end

function DropDownControlMixin:SetCustomSetup(customSetupCallback, skipNormalSetup)
	self.customSetupCallback = customSetupCallback;
	self.skipNormalSetup = skipNormalSetup;
end

function DropDownControlMixin:SetTextJustifyH(...)
	self.DropDownMenu.Text:SetJustifyH(...);
end

function DropDownControlMixin:AdjustTextPointsOffset(...)
	self.DropDownMenu.Text:AdjustPointsOffset(...);
end

function DropDownControlMixin:SetEnabled(enabled)
	UIDropDownMenu_SetDropDownEnabled(self.DropDownMenu, enabled);
end

EnumDropDownControlMixin = CreateFromMixins(DropDownControlMixin);

function EnumDropDownControlMixin:SetEnum(enum, nameTranslation, ordering)
	local options = {};
	for enumKey, enumValue in pairs(enum) do
		table.insert(options, { value = enumValue, text = nameTranslation(enumValue), });
	end

	if ordering then
		local function EnumOrderingComparator(lhs, rhs)
			return ordering[lhs.value] < ordering[rhs.value];
		end

		table.sort(options, EnumOrderingComparator);
	else
		local function EnumComparator(lhs, rhs)
			return lhs.value < rhs.value;
		end

		table.sort(options, EnumComparator);
	end

	self:SetOptions(options);
end

DisabledTooltipButtonMixin = {};

function DisabledTooltipButtonMixin:OnEnter()
	if not self:IsEnabled() then
		local disabledTooltip, disabledTooltipAnchor = self:GetDisabledTooltip();
		if disabledTooltip ~= nil then
			GameTooltip_ShowDisabledTooltip(GameTooltip, self, disabledTooltip, disabledTooltipAnchor);
		end
	end
end

function DisabledTooltipButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function DisabledTooltipButtonMixin:SetDisabledTooltip(disabledTooltip, disabledTooltipAnchor)
	self.disabledTooltip = disabledTooltip;
	self.disabledTooltipAnchor = disabledTooltipAnchor;
end

function DisabledTooltipButtonMixin:GetDisabledTooltip()
	return self.disabledTooltip, self.disabledTooltipAnchor;
end

function DisabledTooltipButtonMixin:SetDisabledState(disabled, disabledTooltip, disabledTooltipAnchor)
	self:SetEnabled(not disabled);
	self:SetDisabledTooltip(disabledTooltip, disabledTooltipAnchor);
end

AlphaHighlightButtonMixin = {};

function AlphaHighlightButtonMixin:OnLoad()
	self:SetHighlightAtlas(self.NormalTexture:GetAtlas());
end

function AlphaHighlightButtonMixin:OnMouseDown()
	self:SetHighlightAtlas(self.PushedTexture:GetAtlas());
end

function AlphaHighlightButtonMixin:OnMouseUp()
	self:SetHighlightAtlas(self.NormalTexture:GetAtlas());
end