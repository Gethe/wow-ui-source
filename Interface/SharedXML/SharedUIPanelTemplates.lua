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

local function ButtonFrameTemplate_UpdateRegionAnchor(region, desiredOffsetX)
	-- It's unfortunate that region needs to be checked here, but there's code that uses ButtonFrameTemplate_*Portrait calls
	-- on frames that don't actually inherit from ButtonFrameTemplate.
	if region then
		local point, relativeTo, relativePoint, currentOffsetX, offsetY = region:GetPointByName("TOPLEFT");
		if point then
			region:SetPoint(point, relativeTo, relativePoint, desiredOffsetX, offsetY);
		end
	end
end

local function ButtonFrameTemplate_UpdateBGAnchors(self, isPortraitMode)
	ButtonFrameTemplate_UpdateRegionAnchor(self.Bg, isPortraitMode and 2 or 7);
	ButtonFrameTemplate_UpdateRegionAnchor(self.Inset, isPortraitMode and 4 or 9);
end

function ButtonFrameTemplate_HidePortrait(self)
	self:SetBorder("ButtonFrameTemplateNoPortrait");
	self:SetPortraitShown(false);

	local isPortraitMode = false;
	ButtonFrameTemplate_UpdateBGAnchors(self, isPortraitMode);
end

function ButtonFrameTemplate_ShowPortrait(self)
	self:SetBorder("PortraitFrameTemplate");
	self:SetPortraitShown(true);

	local isPortraitMode = true;
	ButtonFrameTemplate_UpdateBGAnchors(self, isPortraitMode);
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
		local continueHide = true;
		if parent.onCloseCallback then
			continueHide = parent.onCloseCallback(self);
		end

		if continueHide then
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

PanelTabButtonMixin = {};

function PanelTabButtonMixin:OnLoad()
	self:SetFrameLevel(self:GetFrameLevel() + 4);
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function PanelTabButtonMixin:OnEvent(event, ...)
	if self:IsVisible() then
		PanelTemplates_TabResize(self, self:GetParent().tabPadding, nil, self:GetParent().minTabWidth, self:GetParent().maxTabWidth);
	end
end

function PanelTabButtonMixin:OnShow()
	PanelTemplates_TabResize(self, self:GetParent().tabPadding, nil, self:GetParent().minTabWidth, self:GetParent().maxTabWidth);
end

function PanelTabButtonMixin:OnEnter()
	if self.Text:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.Text:GetText());
	end
end

function PanelTabButtonMixin:OnLeave()
	GameTooltip_Hide();
end

PanelTopTabButtonMixin = {};

local TOP_TAB_HEIGHT_PERCENT = 0.75;
local TOP_TAB_BOTTOM_TEX_COORD = 1 - TOP_TAB_HEIGHT_PERCENT;

function PanelTopTabButtonMixin:OnLoad()
	PanelTabButtonMixin.OnLoad(self);

	for _, tabTexture in ipairs(self.TabTextures) do
		tabTexture:SetTexCoord(0, 1, 1, TOP_TAB_BOTTOM_TEX_COORD);
		tabTexture:SetHeight(tabTexture:GetHeight() * TOP_TAB_HEIGHT_PERCENT);
	end

	self.Left:ClearAllPoints();
	self.Left:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -3, 0);
	self.Right:ClearAllPoints();
	self.Right:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 7, 0);

	self.LeftActive:ClearAllPoints();
	self.LeftActive:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -1, 0);
	self.RightActive:ClearAllPoints();
	self.RightActive:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 8, 0);

	self.isTopTab = true;
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
	local sideWidths = tab.Left:GetWidth() + tab.Right:GetWidth();
	return tab:GetTextWidth() + sideWidths;
end

local TAB_SIDES_PADDING = 20;

function PanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)
	if absoluteTextSize then
		tab.Text:SetWidth(absoluteTextSize);
	else
		tab.Text:SetWidth(0);
	end

	local textWidth = tab.Text:GetStringWidth();
	local width = textWidth + TAB_SIDES_PADDING + (padding or 0);
	local sideWidths = tab.Left:GetWidth() + tab.Right:GetWidth();
	minWidth = minWidth or sideWidths;

	if absoluteSize then
		if absoluteSize < sideWidths then
			width = sideWidths;
		else
			width = absoluteSize;
		end

		textWidth = width - TAB_SIDES_PADDING - (padding or 0);
	else
		if maxWidth and width > maxWidth then
			width = maxWidth;
			textWidth = width - TAB_SIDES_PADDING - (padding or 0);
		elseif minWidth and width < minWidth then
			width = minWidth;
			textWidth = width - TAB_SIDES_PADDING - (padding or 0);
		end
	end

	tab.Text:SetWidth(textWidth);
	tab:SetWidth(width);
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
	PanelTemplates_AnchorTabs(frame);
end

function PanelTemplates_AnchorTabs(frame, numTabs)
	for i = 2, frame.numTabs do
		local lastTab = GetTabByIndex(frame, i - 1);
		local thisTab = GetTabByIndex(frame, i);
		thisTab:SetPoint("TOPLEFT", lastTab, "TOPRIGHT", 3, 0);
	end
end

function PanelTemplates_SetTabEnabled(frame, index, enabled)
	if (enabled) then
		PanelTemplates_EnableTab(frame, index);
	else
		PanelTemplates_DisableTab(frame, index);
	end
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
	tab.Left:Show();
	tab.Middle:Show();
	tab.Right:Show();
	tab:Enable();

	local offsetY = tab.deselectedTextY or 2;
	if tab.isTopTab then
		offsetY = -offsetY - 6;
	end

	tab.Text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), offsetY);

	tab.LeftActive:Hide();
	tab.MiddleActive:Hide();
	tab.RightActive:Hide();
end

function PanelTemplates_SelectTab(tab)
	tab.Left:Hide();
	tab.Middle:Hide();
	tab.Right:Hide();
	tab:Disable();
	tab:SetDisabledFontObject(GameFontHighlightSmall);

	local offsetY = tab.selectedTextY or -3;
	if tab.isTopTab then
		offsetY = -offsetY - 7;
	end

	tab.Text:SetPoint("CENTER", tab, "CENTER", (tab.selectedTextX or 0), offsetY);

	tab.LeftActive:Show();
	tab.MiddleActive:Show();
	tab.RightActive:Show();

	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(tab) then
		tooltip:Hide();
	end
end

function PanelTemplates_SetDisabledTabState(tab)
	tab.Left:Show();
	tab.Middle:Show();
	tab.Right:Show();
	tab:Disable();
	tab:SetDisabledFontObject(GameFontDisableSmall);

	local offsetY = tab.deselectedTextY or 2;
	if tab.isTopTab then
		offsetY = -offsetY - 6;
	end

	tab.Text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), offsetY);

	tab.LeftActive:Hide();
	tab.MiddleActive:Hide();
	tab.RightActive:Hide();
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
	local clampIfExceededRange = self.clampIfInputExceedsRange and (value ~= newValue);
	local changed = newValue ~= self.currentValue;
	if clampIfExceededRange or changed then
		self.currentValue = newValue;
		self:SetNumber(newValue);

		if self.highlightIfInputExceedsRange and clampIfExceededRange then
			self:HighlightText();
		end

		if changed and self.onValueChangedCallback then
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

UIResettableDropdownButtonMixin = {};

function UIResettableDropdownButtonMixin:OnLoad()
	self.ResetButton:SetScript("OnClick", function(button, buttonName, down)
		if self.resetFunction then
			 self.resetFunction();
		end

		self.ResetButton:Hide();
	end);
end

function UIResettableDropdownButtonMixin:OnMouseDown()
	UIMenuButtonStretchMixin.OnMouseDown(self, button);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function UIResettableDropdownButtonMixin:SetResetFunction(resetFunction)
	self.resetFunction = resetFunction;
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
	if self.buttonArtKit then
		self:SetButtonArtKit(self.buttonArtKit);
	end

	if self.disabledTooltip then
		self:SetMotionScriptsWhileDisabled(true);
	end
end

function UIButtonMixin:OnClick(...)
	PlaySound(self.onClickSoundKit or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if self.onClickHandler then
		self.onClickHandler(self, ...);
	end
end

function UIButtonMixin:OnEnter()
	if self.onEnterHandler and self.onEnterHandler(self) then
		return;
	end

	local defaultTooltipAnchor = "ANCHOR_RIGHT";
	if self:IsEnabled() then
		if self.tooltipTitle or self.tooltipText then
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(self, self.tooltipAnchor or defaultTooltipAnchor, self.tooltipOffsetX, self.tooltipOffsetY);

			if self.tooltipTitle then
				GameTooltip_SetTitle(tooltip, self.tooltipTitle, self.tooltipTitleColor);
			end

			if self.tooltipText then
				local wrap = true;
				GameTooltip_AddColoredLine(tooltip, self.tooltipText, self.tooltipTextColor or NORMAL_FONT_COLOR, wrap);
			end

			tooltip:Show();
		end
	else
		if self.disabledTooltip then
			local tooltip = GetAppropriateTooltip();
			GameTooltip_ShowDisabledTooltip(tooltip, self, self.disabledTooltip, self.disabledTooltipAnchor or defaultTooltipAnchor, self.disabledTooltipOffsetX, self.disabledTooltipOffsetY);
		end
	end
end

function UIButtonMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
end

function UIButtonMixin:SetButtonArtKit(buttonArtKit)
	self.buttonArtKit = buttonArtKit;

	self:SetNormalAtlas(buttonArtKit);
	self:SetPushedAtlas(buttonArtKit.."-Pressed");
	self:SetDisabledAtlas(buttonArtKit.."-Disabled");
	self:SetHighlightAtlas(buttonArtKit.."-Highlight");
end

function UIButtonMixin:SetOnClickHandler(onClickHandler, onClickSoundKit)
	self.onClickHandler = onClickHandler;
	self.onClickSoundKit = onClickSoundKit;
end

function UIButtonMixin:SetOnEnterHandler(onEnterHandler)
	self.onEnterHandler = onEnterHandler;
end

function UIButtonMixin:SetTooltipInfo(tooltipTitle, tooltipText)
	self.tooltipTitle = tooltipTitle;
	self.tooltipText = tooltipText;
end

function UIButtonMixin:SetTooltipAnchor(tooltipAnchor, tooltipOffsetX, tooltipOffsetY)
	self.tooltipAnchor = tooltipAnchor;
	self.tooltipOffsetX = tooltipOffsetX;
	self.tooltipOffsetY = tooltipOffsetY;
end

function UIButtonMixin:SetDisabledTooltip(disabledTooltip, disabledTooltipAnchor, disabledTooltipOffsetX, disabledTooltipOffsetY)
	self.disabledTooltip = disabledTooltip;
	self.disabledTooltipAnchor = disabledTooltipAnchor;
	self.disabledTooltipOffsetX = disabledTooltipOffsetX;
	self.disabledTooltipOffsetY = disabledTooltipOffsetY;
	self:SetMotionScriptsWhileDisabled(disabledTooltip ~= nil);
end

IconButtonMixin = CreateFromMixins(UIButtonMixin);

function IconButtonMixin:OnLoad()
	if self.icon then
		self:SetIcon(self.icon);
	elseif self.iconAtlas then
		self:SetAtlas(self.iconAtlas, self.useAtlasSize);
	end

	if self.useIconAsHighlight then
		if self.icon then
			self:SetHighlightTexture(self.icon, "ADD");
		elseif self.iconAtlas then
			self:SetHighlightAtlas(self.iconAtlas, "ADD");
		end

		local highlightTexture = self:GetHighlightTexture();
		highlightTexture:SetPoint("TOPLEFT", self.Icon, "TOPLEFT");
		highlightTexture:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT");
	end

	if self.iconSize then
		self.Icon:SetSize(self.iconSize, self.iconSize);
	elseif self.iconWidth then
		self.Icon:SetSize(self.iconWidth, self.iconHeight);
	end
end

function IconButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self, "CENTER", 1, -1);
	end
end

function IconButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER", self, "CENTER");
end

function IconButtonMixin:SetIcon(icon)
	self.Icon:SetTexture(icon);
end

function IconButtonMixin:SetAtlas(atlas, useAtlasSize)
	self.Icon:SetAtlas(atlas, useAtlasSize);
end

function IconButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled);
	self.Icon:SetDesaturated(not enabled);
end

SquareIconButtonMixin = CreateFromMixins(IconButtonMixin);

function SquareIconButtonMixin:OnMouseDown()
	-- Overrides IconButtonMixin.

	if self:IsEnabled() then
		-- Square icon button template still uses down-to-the-left depress behavior to match the existing art.
		self.Icon:SetPoint("CENTER", self, "CENTER", -2, -1);
	end
end

function SquareIconButtonMixin:OnMouseUp()
	-- Overrides IconButtonMixin.

	self.Icon:SetPoint("CENTER", self, "CENTER", -1, 0);
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

NineSliceCheckButtonMixin = {};

function NineSliceCheckButtonMixin:OnLoad()
	self.SetCheckedBase = self.SetChecked;
	self.SetChecked = self.SetCheckedOverride;

	self.SetButtonStateBase = self.SetButtonState;
	self.SetButtonState = self.SetButtonStateOverride;

	-- Add padding to nine slices
	local function ApplyPadding(nineSliceName)
		local function GetPadding(paddingName)
			return self[string.lower(nineSliceName)..paddingName.."Padding"] or 0;
		end

		local nineSliceFrame = self[nineSliceName.."NineSlice"];

		local point, relativeTo, relativePoint = nineSliceFrame:GetPoint(1);
		nineSliceFrame:SetPoint(point, relativeTo, relativePoint, GetPadding("Left"), GetPadding("Top"));

		point, relativeTo, relativePoint = nineSliceFrame:GetPoint(2);
		nineSliceFrame:SetPoint(point, relativeTo, relativePoint, GetPadding("Right"), GetPadding("Bottom"));
	end

	ApplyPadding("Normal");
	ApplyPadding("Pushed");
	ApplyPadding("Highlight");
	ApplyPadding("Checked");
end

function NineSliceCheckButtonMixin:OnEnter()
	self.HighlightNineSlice:Show();
end

function NineSliceCheckButtonMixin:OnLeave()
	self.HighlightNineSlice:Hide();

	self.NormalNineSlice:Show();
	self.PushedNineSlice:Hide();
end

function NineSliceCheckButtonMixin:OnMouseDown()
	self.NormalNineSlice:Hide();
	self.PushedNineSlice:Show();
end

function NineSliceCheckButtonMixin:OnMouseUp()
	self.NormalNineSlice:Show();
	self.PushedNineSlice:Hide();
end

function NineSliceCheckButtonMixin:SetCheckedOverride(checked)
	self:SetCheckedBase(checked);

	local isChecked = self:GetChecked();
	self.CheckedNineSlice:SetShown(isChecked);
end

function NineSliceCheckButtonMixin:SetButtonStateOverride(state, lock)
	self:SetButtonStateBase(state, lock);

	local buttonState = self:GetButtonState();
	self.NormalNineSlice:SetShown(buttonState == "NORMAL");
	self.PushedNineSlice:SetShown(buttonState == "PUSHED");
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

-- Hack to set an alias for addon backward compatibility.
function UICheckButtonFontString_SetParentKeyAlias(fontString)
	local parent = fontString:GetParent();
	parent.text = fontString;
end

ResizeCheckButtonMixin = {}

function ResizeCheckButtonMixin:OnLoad()
	self.onBoxToggled = self.onBoxToggled or nop;

	if self.Label ~= nil then
		self.Label:SetText(self.labelText);
	end
end

function ResizeCheckButtonMixin:OnShow()
	ResizeLayoutMixin.OnShow(self);
end

function ResizeCheckButtonMixin:SetButton(button)
	self.Button = button;
	self:MarkDirty();
end

function ResizeCheckButtonMixin:SetLabel(labelFontString)
	self.Label = labelFontString;
	self.Label:SetText(self.labelText);
	self:MarkDirty();
end

function ResizeCheckButtonMixin:OnCheckButtonClick()
	local isUserInput = true;
	self.onBoxToggled(self:IsControlChecked(), isUserInput);
end

function ResizeCheckButtonMixin:SetLabelText(labelText)
	self.labelText = labelText;

	if self.Label ~= nil then
		self.Label:SetText(labelText);
		self:MarkDirty();
	end
end

function ResizeCheckButtonMixin:SetCallback(onBoxToggled)
	self.onBoxToggled = onBoxToggled;
end

function ResizeCheckButtonMixin:GetCallback()
	return self.onBoxToggled;
end

function ResizeCheckButtonMixin:SetControlChecked(checked, isUserInput)
	if self:IsControlChecked() == checked then
		return;
	end

	if self.Button == nil then
		return;
	end

	self.Button:SetChecked(checked);

	self.onBoxToggled(self:IsControlChecked(), not not isUserInput);
end

function ResizeCheckButtonMixin:IsControlChecked()
	if self.Button == nil then
		return false;
	end

	return self.Button:GetChecked();
end

function ResizeCheckButtonMixin:SetControlEnabled(enabled)
	self.Button:SetEnabled(enabled);

	if self.Label ~= nil then
		self.Label:SetFontObject(enabled and "GameFontHighlightLarge" or "GameFontDisableLarge")
	end
end

function ResizeCheckButtonMixin:IsControlEnabled()
	return self.Button:IsEnabled();
end

SubFrameMouseoverButtonMixin = {};

function SubFrameMouseoverButtonMixin:OnEnter()
	self.timeSinceMouseover = nil;
	self:SetSubFrameShown(true);
end

function SubFrameMouseoverButtonMixin:OnLeave()
	local function DropDownMouseoverButton_OnUpdate(onUpdateSelf, dt)
		if not onUpdateSelf:IsMouseOver() and not DoesAncestryInclude(self.subFrame, GetMouseFocus()) then
			onUpdateSelf.timeSinceMouseOver = (onUpdateSelf.timeSinceMouseOver or 0) + dt;
			if onUpdateSelf.timeSinceMouseOver > self.hideDelay then
				onUpdateSelf.timeSinceMouseOver = nil;
				self:SetSubFrameShown(false);
				self:SetScript("OnUpdate", nil);
			end
		end
	end

	self:SetScript("OnUpdate", DropDownMouseoverButton_OnUpdate);
end

function SubFrameMouseoverButtonMixin:OnHide()
	self:SetScript("OnUpdate", nil);
end

function SubFrameMouseoverButtonMixin:SetSubFrame(subFrame, customShownBehavior)
	self.subFrame = subFrame;
	self.customShownBehavior = customShownBehavior;
end

function SubFrameMouseoverButtonMixin:SetHideDelay(hideDelay)
	self.hideDelay = hideDelay;
end

function SubFrameMouseoverButtonMixin:SetSubFrameShown(shown)
	if self.customShownBehavior then
		self.customShownBehavior(shown);
	else
		self.subFrame:SetShown(shown);
	end
end

DropDownMouseoverButtonMixin = {};

function DropDownMouseoverButtonMixin:SetDropDown(dropDown, dropDownInitialize, displayMode, level, menuList)
	self.dropDown = dropDown;
	UIDropDownMenu_Initialize(self.dropDown, dropDownInitialize, displayMode, level, menuList);

	local dropDownList = DropDownList1;
	local function DropDownMouseoverButton_SetSubFrameShown(shown)
		if shown then
			if not dropDownList:IsShown() or (UIDropDownMenu_GetCurrentDropDown() ~= self.dropDown) then
				ToggleDropDownMenu(1, nil, self.dropDown, self, self.xOffset or 0, self.yOffset or 0);
			end
		else
			HideDropDownMenu(1);
		end
	end

	self:SetSubFrame(dropDownList, DropDownMouseoverButton_SetSubFrameShown);
end

function DropDownMouseoverButtonMixin:SetDropDownAnchor(point, relativePoint, xOffset, yOffset)
	self.dropDown.point = point;
	self.dropDown.relativePoint = relativePoint;
	self.xOffset = xOffset;
	self.yOffset = yOffset;
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

SliderControlFrameMixin = {};

function SliderControlFrameMixin:OnEnter()
end

function SliderControlFrameMixin:OnLeave()
end

function SliderControlFrameMixin:SetupSlider(minValue, maxValue, value, valueStep, label)
	self.minValue = minValue;
	self.maxValue = maxValue;
	self.Slider:SetMinMaxValues(minValue, maxValue);

	self.valueStep = valueStep;
	self.Slider:SetValueStep(valueStep);

	self.value = value;
	self.Slider:SetValue(value);

	self.Label:SetText(label);
end

function SliderControlFrameMixin:OnSliderValueChanged(value, userInput)
	-- Override in your mixin.
end

SliderWithButtonsAndLabelMixin = CreateFromMixins(SliderControlFrameMixin);

function SliderWithButtonsAndLabelMixin:OnSliderValueChanged(value, userInput)
	-- Overrides SliderControlFrameMixin.

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

SliderAndEditControlMixin = CreateFromMixins(SliderControlFrameMixin);

function SliderAndEditControlMixin:SetupSlider(minValue, maxValue, value, valueStep, label)
	SliderControlFrameMixin.SetupSlider(self, minValue, maxValue, value, valueStep, label);

	self.ValueBox:SetNumber(value);

	local function ValueBoxFinalizedCallback(valueBoxValue)
		local isUserInput = true;
		self:SetValue(valueBoxValue, isUserInput);
	end

	self.ValueBox:SetOnValueFinalizedCallback(ValueBoxFinalizedCallback);
end

function SliderAndEditControlMixin:OnSliderValueChanged(value, isUserInput)
	-- Overrides SliderControlFrameMixin.

	self.ValueBox:SetNumber(value);

	if self.callback ~= nil then
		self.callback(value, isUserInput);
	end
end

function SliderAndEditControlMixin:SetValue(value, isUserInput)
	self.Slider:SetValue(Clamp(value, self.minValue, self.maxValue), isUserInput);
end

function SliderAndEditControlMixin:SetCallback(callback)
	self.callback = callback;
end

SelectionPopoutButtonMixin = CreateFromMixins(CallbackRegistryMixin, EventButtonMixin);
SelectionPopoutButtonMixin:GenerateCallbackEvents(
	{
		"OnValueChanged",
	}
);

function SelectionPopoutButtonMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.parent = self:GetParent();

	if self.SelectionDetails then
		self.SelectionDetails:SetFrameLevel(self:GetFrameLevel());
	end

	self.Popout.logicalParent = self;

	if IsOnGlueScreen() then
		self.Popout:SetParent(GlueParent);
		self.Popout:SetFrameStrata("FULLSCREEN_DIALOG");
		self.Popout:SetToplevel(true);
		self.Popout:SetScale(self:GetEffectiveScale());
	elseif not DoesAncestryInclude(BarberShopFrame, self) then
		self.Popout:SetParent(UIParent);
		self.Popout:SetFrameStrata("FULLSCREEN_DIALOG");
		self.Popout:SetToplevel(true);
	end

	self.buttonPool = CreateFramePool("BUTTON", self.Popout, self.selectionEntryTemplates);
	self.initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.Popout, "TOPLEFT", 6, -12);
end

function SelectionPopoutButtonMixin:HandlesGlobalMouseEvent(buttonID, event)
	return event == "GLOBAL_MOUSE_DOWN" and buttonID == "LeftButton";
end

function SelectionPopoutButtonMixin:OnEnter()
	if self.parent.OnEnter then
		self.parent:OnEnter();
	end
	if not self.Popout:IsShown() then
		self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox-hover");
	end
end

function SelectionPopoutButtonMixin:OnLeave()
	if self.parent.OnLeave then
		self.parent:OnLeave();
	end
	if not self.Popout:IsShown() then
		self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox");
	end
end

function SelectionPopoutButtonMixin:SetEnabled_(enabled)
	self:SetEnabled(enabled);
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
	SelectionPopouts:CloseAll();

	self.Popout:Show();
	self.NormalTexture:SetAtlas("charactercreate-customize-dropdownbox-open");
	self.HighlightTexture:SetAlpha(0.2);
end

function SelectionPopoutButtonMixin:SetPopoutStrata(strata)
	self.Popout:SetFrameStrata(strata);
end

function SelectionPopoutButtonMixin:SetupSelections(selections, selectedIndex)
	self.selections = selections;
	self.selectedIndex = selectedIndex;

	if self.Popout:IsShown() then
		self:UpdatePopout();
	else
		self.popoutNeedsUpdate = true;
	end

	return self:UpdateButtonDetails();
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
	local maxPopoutHeight = self.parent.GetMaxPopoutHeight and self.parent:GetMaxPopoutHeight() or nil;
	if maxPopoutHeight then
		local selectionHeight = 20;
		return math.floor(maxPopoutHeight / selectionHeight);
	end
end

function SelectionPopoutButtonMixin:UpdatePopout()
	self.buttonPool:ReleaseAll();

	local selections = self:GetSelections();
	local numColumns, stride = getNumColumnsAndStride(#selections, self:GetMaxPopoutStride());
	local buttons = {};

	local hasIneligibleChoice = false;
	local hasLockedChoice = false;
	for _, selectionData in ipairs(selections) do
		if selectionData.ineligibleChoice then
			hasIneligibleChoice = true;
		end
		if selectionData.isLocked then
			hasLockedChoice = true;
		end
	end

	local maxDetailsWidth = 0;
	for index, selectionInfo in ipairs(selections) do
		local button = self.buttonPool:Acquire();

		local isSelected = (index == self.selectedIndex);
		button:SetupEntry(selectionInfo, index, isSelected, numColumns > 1, hasIneligibleChoice, hasLockedChoice);
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

function SelectionPopoutButtonMixin:GetSelections()
	return self.selections;
end

function SelectionPopoutButtonMixin:GetCurrentSelectedData()
	local selections = self:GetSelections();
	return selections[self.selectedIndex];
end

function SelectionPopoutButtonMixin:UpdateButtonDetails()
	if self.SelectionDetails then
		self.SelectionDetails:SetupDetails(self:GetCurrentSelectedData(), self.selectedIndex);
	end
end

function SelectionPopoutButtonMixin:GetTooltipText()
	if self.SelectionDetails then
		return self.SelectionDetails:GetTooltipText();
	end

	return nil;
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

function SelectionPopoutButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self:TogglePopout();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function SelectionPopoutButtonMixin:FindIndex(predicate)
	return FindInTableIf(self:GetSelections(), predicate);
end

function SelectionPopoutButtonMixin:IsDataMatch(data1, data2)
	return data1 == data2;
end

function SelectionPopoutButtonMixin:OnEntryClicked(entryData)
	if entryData.isLocked then
		return;
	end
	local newIndex = self:FindIndex(function(element)
		return self:IsDataMatch(element, entryData);
	end);
	self:SetSelectedIndex(newIndex);

	self:HidePopout();

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function SelectionPopoutButtonMixin:Update()
	self:UpdateButtonDetails();
	self:UpdatePopout();

	if self.parent.UpdateButtons then
		self.parent:UpdateButtons();
	end
end

function SelectionPopoutButtonMixin:CallOnEntrySelected(entryData)
	if self.parent.OnEntrySelected then
		self.parent:OnEntrySelected(entryData);
	end
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

function SelectionPopoutButtonMixin:GetAdjustedIndex(forward, selections)
	if not self.selectedIndex then
		return nil;
	end
	local offset = forward and 1 or -1;
	local nextIndex = self.selectedIndex + offset;
	local data = selections[nextIndex];
	while data do
		if data.disabled == nil and not data.isLocked then
			return nextIndex;
		else
			nextIndex = nextIndex + offset;
			data = selections[nextIndex];
		end
	end

	return nil;
end

function SelectionPopoutButtonMixin:Increment()
	local forward = true;
	local index = self:GetAdjustedIndex(forward, self:GetSelections());
	self:SetSelectedIndex(index);
end

function SelectionPopoutButtonMixin:Decrement()
	local forward = false;
	local index = self:GetAdjustedIndex(forward, self:GetSelections());
	self:SetSelectedIndex(index);
end

function SelectionPopoutButtonMixin:SetSelectedIndex(newIndex)
	local oldIndex = self.selectedIndex;
	local isNewIndex = newIndex and newIndex ~= oldIndex;
	if isNewIndex then
		self.selectedIndex = newIndex;
		self:Update();

		self:TriggerEvent(SelectionPopoutButtonMixin.Event.OnValueChanged, self:GetCurrentSelectedData());
	end

	if self.parent.ShouldTriggerSelection and self.parent.ShouldTriggerSelection(oldIndex, newIndex) or isNewIndex then
		self:CallOnEntrySelected(self:GetCurrentSelectedData());
	end
end

SelectionPopoutWithButtonsMixin = {};

function SelectionPopoutWithButtonsMixin:OnLoad()
	local xOffset = self.incrementOffsetX or 4;
	self.IncrementButton:SetPoint("LEFT", self.Button, "RIGHT", xOffset, 0);
	self.IncrementButton:SetScript("OnClick", GenerateClosure(self.OnIncrementClicked, self));

	xOffset = self.decrementOffsetX or -5;
	self.DecrementButton:SetPoint("RIGHT", self.Button, "LEFT", xOffset, 0);
	self.DecrementButton:SetScript("OnClick", GenerateClosure(self.OnDecrementClicked, self));
end

function SelectionPopoutWithButtonsMixin:SetEnabled_(enabled)
	self.Button:SetEnabled_(enabled);
	self:UpdateButtons();
end

function SelectionPopoutWithButtonsMixin:OnIncrementClicked(button, buttonName, down)
	self.Button:Increment();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function SelectionPopoutWithButtonsMixin:OnDecrementClicked(button, buttonName, down)
	self.Button:Decrement();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function SelectionPopoutWithButtonsMixin:SetupSelections(selections, selectedIndex, label)
	local result = self.Button:SetupSelections(selections, selectedIndex);
	self:UpdateButtons();
	return result;
end

function SelectionPopoutWithButtonsMixin:OnEnter()
end

function SelectionPopoutWithButtonsMixin:OnLeave()
end

function SelectionPopoutWithButtonsMixin:Increment()
	self.Button:Increment();
end

function SelectionPopoutWithButtonsMixin:Decrement()
	self.Button:Decrement();
end

function SelectionPopoutWithButtonsMixin:OnPopoutShown()
end

function SelectionPopoutWithButtonsMixin:HidePopout()
	self.Button:HidePopout();
end

function SelectionPopoutWithButtonsMixin:OnEntrySelected(entryData)
end

function SelectionPopoutWithButtonsMixin:GetTooltipText()
	return self.Button:GetTooltipText();
end

function SelectionPopoutWithButtonsMixin:OnEntryMouseEnter(entry)
end

function SelectionPopoutWithButtonsMixin:OnEntryMouseLeave(entry)
end

function SelectionPopoutWithButtonsMixin:GetMaxPopoutHeight()
end

function SelectionPopoutWithButtonsMixin:UpdateButtons()
	local enabled = self.Button:IsEnabled();
	if enabled then
		local selections = self.Button:GetSelections()

		local forward = true;
		local index = self.Button:GetAdjustedIndex(forward, selections);
		self.IncrementButton:SetEnabled(index ~= nil);

		forward = false;
		local index = self.Button:GetAdjustedIndex(forward, selections);
		self.DecrementButton:SetEnabled(index ~= nil);
	else
		self.IncrementButton:SetEnabled(false);
		self.DecrementButton:SetEnabled(false);
	end
end

SelectionPopoutWithButtonsAndLabelMixin = CreateFromMixins(SelectionPopoutWithButtonsMixin);

function SelectionPopoutWithButtonsAndLabelMixin:SetupSelections(selections, selectedIndex, label)
	SelectionPopoutWithButtonsMixin.SetupSelections(self, selections, selectedIndex);

	self.Label:SetText(label);
end

SelectionPopoutMixin = {};

function SelectionPopoutMixin:OnShow()
	self:Layout();
	self.logicalParent:OnPopoutShown();
	SelectionPopouts:Add(self);
end

function SelectionPopoutMixin:OnHide()
	SelectionPopouts:Remove(self);
end

SelectionPopoutEntryMixin = {};

function SelectionPopoutEntryMixin:OnLoad()
	self.parentButton = self:GetParent().logicalParent;
end

function SelectionPopoutEntryMixin:HandlesGlobalMouseEvent(buttonID, event)
	return event == "GLOBAL_MOUSE_DOWN" and buttonID == "LeftButton";
end

function SelectionPopoutEntryMixin:SetupEntry(selectionData, index, isSelected, multipleColumns, hasAFailedReq, hasALockedChoice)
	self.isSelected = isSelected;
	self.selectionData = selectionData;
	self.popoutHasAFailedReq = hasAFailedReq;
	self.popoutHasALockedChoice = hasALockedChoice;

	self.SelectionDetails:SetupDetails(selectionData, index, isSelected, hasAFailedReq, hasALockedChoice);
	self.SelectionDetails:AdjustWidth(multipleColumns, self.defaultWidth);
end

function SelectionPopoutEntryMixin:GetTooltipText()
	return self.SelectionDetails:GetTooltipText();
end

function SelectionPopoutEntryMixin:OnEnter()
	self.parentButton:OnEntryMouseEnter(self);
end

function SelectionPopoutEntryMixin:OnLeave()
	self.parentButton:OnEntryMouseLeave(self);
end

function SelectionPopoutEntryMixin:OnClick()
	self.parentButton:OnEntryClicked(self.selectionData);
end

SelectionPopouts = {};

function SelectionPopouts:OnLoad()
	self.popouts = {};
end

function SelectionPopouts:ContainsMouse()
	for index, popout in ipairs(self.popouts) do
		if popout:IsShown() and popout:IsMouseOver() then
			return true;
		end
	end
	return false;
end

function SelectionPopouts:CloseAll()
	local shallow = true;
	local popoutsCopy = CopyTable(self.popouts, shallow);
	wipe(self.popouts);

	for index, popout in ipairs(popoutsCopy) do
		popout.logicalParent:HidePopout();
	end
end

function SelectionPopouts:HandleGlobalMouseEvent(buttonID, event)
	if event == "GLOBAL_MOUSE_DOWN" and (buttonID == "LeftButton" or buttonID == "RightButton") then
		if not self:ContainsMouse() then
			self:CloseAll();
		end
	end
end

function SelectionPopouts:Add(popout)
	table.insert(self.popouts, popout);
end

function SelectionPopouts:Remove(popout)
	tDeleteItem(self.popouts, popout);
end

SelectionPopouts:OnLoad();

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
	self:SetTarget(self:GetParent());
end

function PanelDragBarMixin:Init(target)
	self:SetTarget(target);
end

function PanelDragBarMixin:SetTarget(target)
	self.target = target;
end

function PanelDragBarMixin:OnDragStart()
	self.target:StartMoving();
end

function PanelDragBarMixin:OnDragStop()
	self.target:StopMovingOrSizing();
end

PanelResizeButtonMixin = {};

function PanelResizeButtonMixin:Init(target, minWidth, minHeight, maxWidth, maxHeight, rotationDegrees)
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

	if rotationDegrees ~= nil then
		self:SetRotationDegrees(rotationDegrees);
	end
end

function PanelResizeButtonMixin:OnMouseDown()
	self.isActive = true;

	if self.target then
		local alwaysStartFromMouse = true;
		self.target:StartSizing("BOTTOMRIGHT", alwaysStartFromMouse);
	end
end

function PanelResizeButtonMixin:OnMouseUp()
	self.isActive = false;

	if self.target then
		self.target:StopMovingOrSizing();

		if self.resizeStoppedCallback ~= nil then
			self.resizeStoppedCallback(self.target);
		end
	end
end

function PanelResizeButtonMixin:IsActive()
	return not not self.isActive;
end

function PanelResizeButtonMixin:SetMinWidth(minWidth)
	self.minWidth = minWidth;
end

function PanelResizeButtonMixin:SetMinHeight(minHeight)
	self.minHeight = minHeight;
end

function PanelResizeButtonMixin:SetRotationDegrees(rotationDegrees)
	local rotationRadians = (rotationDegrees / 180) * math.pi;
	self:SetRotationRadians(rotationRadians);
end

function PanelResizeButtonMixin:SetRotationRadians(rotationRadians)
	local childRegions = { self:GetRegions() };
	for i, child in ipairs(childRegions) do
		if child.SetRotation ~= nil then
			child:SetRotation(rotationRadians);
		end
	end
end

function PanelResizeButtonMixin:SetOnResizeStoppedCallback(resizeStoppedCallback)
	self.resizeStoppedCallback = resizeStoppedCallback;
end

DropDownControlMixin = {};

function DropDownControlMixin:OnLoad()
	local function InitializeDropDownFrame(frame, level)
		self:Initialize(level);
	end

	UIDropDownMenu_Initialize(self.DropDownMenu, InitializeDropDownFrame);

	self:UpdateDropDownWidth(self:GetWidth());
	self:UpdateSavedDefaultTextColor();
end

function DropDownControlMixin:AddTopLabel(labelText, labelFont, labelOffsetX, labelOffsetY)
	labelFont = labelFont or "GameFontNormal";
	labelOffsetX = labelOffsetX or 20;
	labelOffsetY = labelOffsetY or 2;

	if self.Label then
		self.Label:Hide();
	end

	self.Label = self:CreateFontString(nil, "OVERLAY", labelFont);
	self.Label:SetText(labelText);
	self.Label:SetPoint("BOTTOMLEFT", self.DropDownMenu, "TOPLEFT", labelOffsetX, labelOffsetY)

	self:SetHeight(32 + self.Label:GetHeight() + labelOffsetY);

	self.DropDownMenu:ClearAllPoints();
	self.DropDownMenu:SetPoint("BOTTOM", 0, 0);
end

function DropDownControlMixin:SetControlWidth(width)
	self:SetWidth(width);
	self:UpdateDropDownWidth(width);
end

function DropDownControlMixin:UpdateDropDownWidth(width)
	UIDropDownMenu_SetWidth(self.DropDownMenu, width - 20);
end

function DropDownControlMixin:Initialize(level)
	if self.options == nil then
		return;
	end

	local function DropDownControlButton_OnClick(button)
		local isUserInput = true;
		self:SetSelectedValue(button.value, isUserInput);
	end

	for i, option in ipairs(self.options) do
		local optionLevel = option.level or 1;
		if not level or optionLevel == level then
			if option.isSeparator then
				UIDropDownMenu_AddSeparator(option.level);
			else
				local info = UIDropDownMenu_CreateInfo();
				if not self.skipNormalSetup then
					info.text = option.text;
					info.tooltipTitle = option.tooltipTitle;
					info.tooltipText = option.tooltipText;
					info.tooltipInstruction = option.tooltipInstruction;
					info.tooltipWarning = option.tooltipWarning;
					info.tooltipOnButton = option.tooltipOnButton;
					info.iconTooltipTitle = option.iconTooltipTitle;
					info.iconTooltipText = option.iconTooltipText;
					info.minWidth = self.dropDownListMinWidth or 108;
					info.value = option.value;
					info.checked = self.selectedValue == option.value;
					info.func = DropDownControlButton_OnClick;
				end

				info.data = option.data;
				info.level = optionLevel;

				if self.customSetupCallback ~= nil then
					self.customSetupCallback(info, DropDownControlButton_OnClick);
				end

				UIDropDownMenu_AddButton(info, option.level);
			end
		end
	end
end

function DropDownControlMixin:SetSelectedValue(value, isUserInput)
	if self.enabledCallback and not self.enabledCallback(value, isUserInput) then
		return;
	end

	self.selectedValue = value;

	self:UpdateSelectedText();

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

function DropDownControlMixin:GetSelectedValueIndex()
	if not self.selectedValue or not self.options then
		return nil;
	end

	for i, option in ipairs(self.options) do
		if option.value == self.selectedValue then
			return i;
		end
	end
end

function DropDownControlMixin:UpdateSelectedText()
	local selectedValue = self.selectedValue;
	if selectedValue == nil then
		UIDropDownMenu_SetText(self.DropDownMenu, self.noneSelectedText);
	elseif self.options ~= nil then
		for i, option in ipairs(self.options) do
			if option.value == selectedValue then
				UIDropDownMenu_SetText(self.DropDownMenu, option.selectedText or option.text);
			end
		end
	end

	self:UpdateSelectedTextColor();
end

function DropDownControlMixin:UpdateSelectedTextColor()
	if self.selectedValue == nil and self.noneSelectedTextColor then
		self.DropDownMenu.Text:SetTextColor(self.noneSelectedTextColor:GetRGBA());
	else
		self.DropDownMenu.Text:SetTextColor(self.defaultTextColor:GetRGBA());
	end
end

function DropDownControlMixin:SetOptionSelectedCallback(optionSelectedCallback)
	self.optionSelectedCallback = optionSelectedCallback;
end

-- options: an array of tables that contain info to display the different dropdown options.
-- Option keys:
--   value: a unique value that identifies the option and is passed through to optionSelectedCallback.
--   text: the text that appears in the dropdown list, and on the dropdown control when an option is selected.
--   selectedText: an override for text that appears on the dropdown control when an option is selected.
--	 isSeparator: a boolean that causes this option to display as a non-clickable separator line
--   data: optional extra data you want attached to this option
--	 level: the level you want to display this option at (1 is default and 2+ will mean the option shows in a sub-dropdown)
function DropDownControlMixin:CreateOption(value, text, selectedText, isSeparator, data, level)
    return { value = value, text = text, selectedText = selectedText, isSeparator = isSeparator, data = data, level = level };
end

function DropDownControlMixin:SetOptions(options, defaultSelectedValue)
	self.options = options;
	self:Initialize();

	if defaultSelectedValue then
		self:SetSelectedValue(defaultSelectedValue);
	end

	self:UpdateSelectedText();
end

-- Dropdown override for simple lists ie: {"Option 1", "Option 2", "Option 3"}
-- See SetOptions for additional supported args
function DropDownControlMixin:SetListOptions(list, ...)
	local options = {};
	for _, value in ipairs(list) do
		table.insert(options, { value = value, text = value, });
	end

	self:SetOptions(options, ...)
end

function DropDownControlMixin:ClearOptions()
	self:ClearSelectedValue();
	self:SetOptions();
end

function DropDownControlMixin:GetOptionCount()
	return self.options and #self.options or 0;
end

function DropDownControlMixin:HasOptions()
	return self:GetOptionCount() > 0;
end

function DropDownControlMixin:SetCustomSetup(customSetupCallback, skipNormalSetup)
	self.customSetupCallback = customSetupCallback;
	self.skipNormalSetup = skipNormalSetup;
end

function DropDownControlMixin:SetDropDownTextFontObject(fontObject)
	self.DropDownMenu.Text:SetFontObject(fontObject);
	self:UpdateSavedDefaultTextColor();
	self:UpdateSelectedTextColor();
end

function DropDownControlMixin:SetDropDownTextColor(...)
	self.DropDownMenu.Text:SetTextColor(...);
	self:UpdateSavedDefaultTextColor();
	self:UpdateSelectedTextColor();
end

function DropDownControlMixin:UpdateSavedDefaultTextColor()
	self.defaultTextColor = CreateColor(self.DropDownMenu.Text:GetTextColor());
end

function DropDownControlMixin:SetTextJustifyH(...)
	self.DropDownMenu.Text:SetJustifyH(...);
end

function DropDownControlMixin:AdjustTextPointsOffset(...)
	self.DropDownMenu.Text:AdjustPointsOffset(...);
end

function DropDownControlMixin:SetNoneSelectedText(text)
	self.noneSelectedText = text;
end

function DropDownControlMixin:SetNoneSelectedTextColor(r, g, b, a)
	self.noneSelectedTextColor = CreateColor(r, g, b, a);
	self:UpdateSelectedTextColor();
end

function DropDownControlMixin:SetDropDownListMinWidth(minWidth)
	self.dropDownListMinWidth = minWidth;
end

function DropDownControlMixin:SetCustomMenuAnchorInfo(xOffset, yOffset, point, relativePoint, relativeTo)
	self.DropDownMenu.xOffset = xOffset;
	self.DropDownMenu.yOffset = yOffset;
	self.DropDownMenu.point = point;
	self.DropDownMenu.relativePoint = relativePoint;
	self.DropDownMenu.relativeTo = relativeTo;
end

function DropDownControlMixin:SetEnabled(enabled, disabledTooltip)
	UIDropDownMenu_SetDropDownEnabled(self.DropDownMenu, enabled, disabledTooltip);
	if enabled then
		self:UpdateSelectedTextColor();
	end
end

-- enabledCallback: called before a selection is allowed (in case enabled state changed while the dropdown list is open). ([selectionID]) -> shouldBeEnabled
function DropDownControlMixin:SetEnabledCallback(enabledCallback)
	self.enabledCallback = enabledCallback;
end

function DropDownControlMixin:GetEnabledCallback()
	return self.enabledCallback;
end

EnumDropDownControlMixin = CreateFromMixins(DropDownControlMixin);

function EnumDropDownControlMixin:SetEnum(enum, nameTranslation, ordering)
	local options = {};
	for enumKey, enumValue in pairs(enum) do
		local optionText = type(nameTranslation) == "function" and nameTranslation(enumValue) or nameTranslation[enumValue];
		table.insert(options, { value = enumValue, text = optionText, });
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

LabeledEnumDropDownControlMixin = CreateFromMixins(EnumDropDownControlMixin);

function LabeledEnumDropDownControlMixin:OnLoad()
	EnumDropDownControlMixin.OnLoad(self);

	self:SetHeight(self:GetHeight() + 20);

	self.DropDownMenu:ClearAllPoints();
	self.DropDownMenu:SetPoint("BOTTOM", 0, 2);
end

function LabeledEnumDropDownControlMixin:SetLabelText(text)
	self.Label:SetText(text);
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

NumericInputBoxMixin = {};

function NumericInputBoxMixin:OnTextChanged(isUserInput)
	self.valueChangedCallback(self:GetNumber(), isUserInput);
end

function NumericInputBoxMixin:OnEditFocusLost()
	EditBox_ClearHighlight(self);

	self.valueFinalizedCallback(self:GetNumber());
end

function NumericInputBoxMixin:SetOnValueChangedCallback(valueChangedCallback)
	self.valueChangedCallback = valueChangedCallback;
end

function NumericInputBoxMixin:SetOnValueFinalizedCallback(valueFinalizedCallback)
	self.valueFinalizedCallback = valueFinalizedCallback;
end

IconSelectorPopupFrameTemplateMixin = {};

IconSelectorPopupFrameModes = EnumUtil.MakeEnum(
	"New",
	"Edit"
);

local ValidIconSelectorCursorTypes = {
	"item",
	"spell",
	"mount",
	"battlepet",
	"macro"
};

local IconSelectorPopupFramesShown = 0;

function IconSelectorPopupFrameTemplateMixin:OnLoad()
	local function IconButtonInitializer(button, selectionIndex, icon)
		button:SetIconTexture(icon);
	end
	self.IconSelector:SetSetupCallback(IconButtonInitializer);
	self.IconSelector:AdjustScrollBarOffsets(0, 18, -1);

	self.BorderBox.OkayButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
		self:OkayButton_OnClick();
	end);

	self.BorderBox.CancelButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
		self:CancelButton_OnClick();
	end);

	self.BorderBox.EditBoxHeaderText:SetText(self.editBoxHeaderText);
end

-- Usually overridden by inheriting frame.
function IconSelectorPopupFrameTemplateMixin:OnShow()
	IconSelectorPopupFramesShown = IconSelectorPopupFramesShown + 1;

	self:RegisterEvent("CURSOR_CHANGED");
	self:RegisterEvent("GLOBAL_MOUSE_UP");

	self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconSelector(self);
	self.BorderBox.IconSelectorEditBox:SetIconSelector(self);
end

-- Usually overridden by inheriting frame.
function IconSelectorPopupFrameTemplateMixin:OnHide()
	IconSelectorPopupFramesShown = IconSelectorPopupFramesShown - 1;
	self:UnregisterEvent("CURSOR_CHANGED");
	self:UnregisterEvent("GLOBAL_MOUSE_UP");
end

-- Usually overridden by inheriting frame.
function IconSelectorPopupFrameTemplateMixin:Update()
end

function IconSelectorPopupFrameTemplateMixin:OnEvent(event, ...)
	if ( event == "CURSOR_CHANGED" ) then
		local cursorType = GetCursorInfo();
		local isValidCursorType = false;
		for _, validType in ipairs(ValidIconSelectorCursorTypes) do
			if ( cursorType == validType ) then
				isValidCursorType = true;
				break;
			end
		end

		self.BorderBox.IconDragArea:SetShown(isValidCursorType);
		self.BorderBox.IconSelectionText:SetShown(not isValidCursorType);
		self.IconSelector:SetShown(not isValidCursorType);
	elseif ( event == "GLOBAL_MOUSE_UP" and DoesAncestryInclude(self, GetMouseFocus())) then
		self:SetIconFromMouse();
	end
end

function IconSelectorPopupFrameTemplateMixin:SetIconFromMouse()
	local cursorType, ID = GetCursorInfo();
	for _, validType in ipairs(ValidIconSelectorCursorTypes) do
		if ( cursorType == validType ) then
			local icon;
			if ( cursorType == "item" ) then
				icon = select(10, GetItemInfo(ID));
			elseif ( cursorType == "spell" ) then
				-- 'ID' field for spells would actually be the slot number, not the actual spellID, so we get this separately.
				local spellID = select(4, GetCursorInfo());
				icon = select(3, GetSpellInfo(spellID));
			elseif ( cursorType == "mount" ) then
				icon = select(3, C_MountJournal.GetMountInfoByID(ID));
			elseif ( cursorType == "battlepet" ) then
				icon = select(9, C_PetJournal.GetPetInfoByPetID(ID));
			elseif ( cursorType == "macro" ) then
				icon = select(2, GetMacroInfo(ID));
			end

			self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(icon));
			self.IconSelector:ScrollToSelectedIndex();
			ClearCursor();

			if ( icon ) then
				self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);
				self.BorderBox.SelectedIconArea.SelectedIconButton:SetSelectedTexture();
			end

			self:SetSelectedIconText();
			break;
		end
	end
end

function IconSelectorPopupFrameTemplateMixin:SetSelectedIconText()
	if ( self:GetSelectedIndex() ) then
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconHeader:SetText(ICON_SELECTION_TITLE_CURRENT);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
	else
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconHeader:SetText(ICON_SELECTION_TITLE_CUSTOM);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_NOTINLIST);
	end

	self.BorderBox.SelectedIconArea.SelectedIconText:Layout();
end

-- Usually overridden by inheriting frame.
function IconSelectorPopupFrameTemplateMixin:OkayButton_OnClick()
	self:Hide();
end

-- Usually overridden by inheriting frame.
function IconSelectorPopupFrameTemplateMixin:CancelButton_OnClick()
	self:Hide();
end

function IconSelectorPopupFrameTemplateMixin:GetIconByIndex(index)
	return self.iconDataProvider:GetIconByIndex(index);
end

function IconSelectorPopupFrameTemplateMixin:GetIndexOfIcon(icon)
	return self.iconDataProvider:GetIndexOfIcon(icon);
end

function IconSelectorPopupFrameTemplateMixin:GetNumIcons()
	return self.iconDataProvider:GetNumIcons();
end

function IconSelectorPopupFrameTemplateMixin:GetSelectedIndex()
	return self.IconSelector:GetSelectedIndex();
end

function IsAnyIconSelectorPopupFrameShown()
	return IconSelectorPopupFramesShown and IconSelectorPopupFramesShown > 0;
end

SelectedIconButtonMixin = {};

function SelectedIconButtonMixin:SetIconTexture(iconTexture)
	self.Icon:SetTexture(iconTexture);
end

function SelectedIconButtonMixin:GetIconTexture()
	return self.Icon:GetTexture();
end

function SelectedIconButtonMixin:SetSelectedTexture()
	self.SelectedTexture:SetShown(self:GetIconSelectorPopupFrame():GetSelectedIndex() == nil);
end

function SelectedIconButtonMixin:OnClick()
	if ( self:GetIconSelectorPopupFrame():GetSelectedIndex() == nil ) then
		return;
	end

	self:GetIconSelectorPopupFrame().IconSelector:ScrollToSelectedIndex();
end

function SelectedIconButtonMixin:GetIconSelectorPopupFrame()
	return self.selectedIconButtonIconSelector;
end

function SelectedIconButtonMixin:SetIconSelector(iconSelector)
	self.selectedIconButtonIconSelector = iconSelector;
end

IconSelectorEditBoxMixin = {};

function IconSelectorEditBoxMixin:OnTextChanged()
	local iconSelectorPopupFrame = self:GetIconSelectorPopupFrame();
	local text = self:GetText();
	text = string.gsub(text, "\"", "");
	if #text > 0 then
		iconSelectorPopupFrame.BorderBox.OkayButton:Enable();
	else
		iconSelectorPopupFrame.BorderBox.OkayButton:Disable();
	end
end

function IconSelectorEditBoxMixin:OnEnterPressed()
	local text = self:GetText();
	text = string.gsub(text, "\"", "");
	if #text > 0 then
		self:GetIconSelectorPopupFrame():OkayButton_OnClick();
	end
end

function IconSelectorEditBoxMixin:OnEscapePressed()
	self:GetIconSelectorPopupFrame():CancelButton_OnClick();
end

function IconSelectorEditBoxMixin:GetIconSelectorPopupFrame()
	return self.editBoxIconSelector;
end

function IconSelectorEditBoxMixin:SetIconSelector(iconSelector)
	self.editBoxIconSelector = iconSelector;
end

RingedFrameWithTooltipMixin = {};
function RingedFrameWithTooltipMixin:OnLoad()
	if self.simpleTooltipLine then
		self:AddTooltipLine(self.simpleTooltipLine, HIGHLIGHT_FONT_COLOR);
	end
end

function RingedFrameWithTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
end

function RingedFrameWithTooltipMixin:AddTooltipLine(lineText, lineColor)
	if not self.tooltipLines then
		self.tooltipLines = {};
	end

	table.insert(self.tooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR});
end

function RingedFrameWithTooltipMixin:AddBlankTooltipLine()
	self:AddTooltipLine(" ");
end

function RingedFrameWithTooltipMixin:GetAppropriateTooltip()
	error("You must implement GetAppropriateTooltip on your mixin!");
end

function RingedFrameWithTooltipMixin:SetupAnchors(tooltip)
	if self.tooltipAnchor == "ANCHOR_TOPRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_TOPLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	else
		tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function RingedFrameWithTooltipMixin:AddExtraStuffToTooltip()
end

function RingedFrameWithTooltipMixin:OnEnter()
	if self.tooltipLines then
		local tooltip = self:GetAppropriateTooltip();

		self:SetupAnchors(tooltip);

		if self.tooltipMinWidth then
			tooltip:SetMinimumWidth(self.tooltipMinWidth);
		end

		if self.tooltipPadding then
			tooltip:SetPadding(self.tooltipPadding, self.tooltipPadding, self.tooltipPadding, self.tooltipPadding);
		end

		for _, lineInfo in ipairs(self.tooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color);
		end

		self:AddExtraStuffToTooltip();

		tooltip:Show();
	end
end

function RingedFrameWithTooltipMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

RingedMaskedButtonMixin = CreateFromMixins(RingedFrameWithTooltipMixin);

function RingedMaskedButtonMixin:OnLoad()
	RingedFrameWithTooltipMixin.OnLoad(self);

	self.CircleMask:SetPoint("TOPLEFT", self, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);

	self.New:SetPoint("CENTER", self, "BOTTOM", 0, self.newTagYOffset);

	local hasRingSizes = self.ringWidth and self.ringHeight;
	if hasRingSizes then
		self.Ring:SetAtlas(self.ringAtlas);
		self.Ring:SetSize(self.ringWidth, self.ringHeight);
		self.Flash.Ring:SetAtlas(self.ringAtlas);
		self.Flash.Ring:SetSize(self.ringWidth, self.ringHeight);
		self.Flash.Ring2:SetAtlas(self.ringAtlas);
		self.Flash.Ring2:SetSize(self.ringWidth, self.ringHeight);
	else
		self.Ring:SetAtlas(self.ringAtlas, true);
		self.Flash.Ring:SetAtlas(self.ringAtlas, true);
		self.Flash.Ring2:SetAtlas(self.ringAtlas, true);
	end

	self.NormalTexture:AddMaskTexture(self.CircleMask);
	self.PushedTexture:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:SetAlpha(self.disabledOverlayAlpha);
	self.CheckedTexture:SetSize(self.checkedTextureSize, self.checkedTextureSize);
	self.Flash.Portrait:AddMaskTexture(self.CircleMask);

	if self.flipTextures then
		self.NormalTexture:SetTexCoord(1, 0, 0, 1);
		self.PushedTexture:SetTexCoord(1, 0, 0, 1);
		self.Flash.Portrait:SetTexCoord(1, 0, 0, 1);
	end

	if self.BlackBG then
		self.BlackBG:AddMaskTexture(self.CircleMask);
	end
end

function RingedMaskedButtonMixin:SetIconAtlas(atlas)
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);
	self.Flash.Portrait:SetAtlas(atlas);
end

function RingedMaskedButtonMixin:ClearFlashTimer()
	if self.FlashTimer then
		self.FlashTimer:Cancel();
	end
end

function RingedMaskedButtonMixin:StartFlash()
	self:ClearFlashTimer();

	local function playFlash()
		self.Flash:Show();
		self.Flash.Anim:Play();
	end

	self.FlashTimer = C_Timer.NewTimer(0.8, playFlash);
end

function RingedMaskedButtonMixin:StopFlash()
	self:ClearFlashTimer();
	self.Flash.Anim:Stop();
	self.Flash:Hide();
end

function RingedMaskedButtonMixin:SetEnabledState(enabled)
	local buttonEnableState = enabled or self.allowSelectionOnDisable;
	self:SetEnabled(buttonEnableState);

	local normalTex = self:GetNormalTexture();
	if normalTex then
		normalTex:SetDesaturated(not enabled);
	end

	local pushedTex = self:GetPushedTexture();
	if pushedTex then
		pushedTex:SetDesaturated(not enabled);
	end

	self.Ring:SetAtlas(self.ringAtlas..(enabled and "" or "-disabled"));

	self.DisabledOverlay:SetShown(not enabled);
end

function RingedMaskedButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.CheckedTexture:SetPoint("CENTER", self, "CENTER", 1, -1);
		self.CircleMask:SetPoint("TOPLEFT", self.PushedTexture, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
		self.CircleMask:SetPoint("BOTTOMRIGHT", self.PushedTexture, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
		self.Ring:SetPoint("CENTER", self, "CENTER", 1, -1);
		self.Flash:SetPoint("CENTER", self, "CENTER", 1, -1);
	end
end

function RingedMaskedButtonMixin:OnMouseUp(button)
	if button == "RightButton" and self.expandedTooltipFrame then
		self.tooltipsExpanded = not self.tooltipsExpanded;
		if GetMouseFocus() == self then
			self:OnEnter();
		end
	end

	self.CheckedTexture:SetPoint("CENTER");
	self.CircleMask:SetPoint("TOPLEFT", self.NormalTexture, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self.NormalTexture, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
	self.Ring:SetPoint("CENTER");
	self.Flash:SetPoint("CENTER");
end

function RingedMaskedButtonMixin:UpdateHighlightTexture()
	if self:GetChecked() then
		self.HighlightTexture:SetAtlas("charactercreate-ring-select");
		self.HighlightTexture:SetPoint("TOPLEFT", self.CheckedTexture);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.CheckedTexture);
	else
		self.HighlightTexture:SetAtlas(self.ringAtlas);
		self.HighlightTexture:SetPoint("TOPLEFT", self.Ring);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.Ring);
	end
end