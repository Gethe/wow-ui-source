local envTable = GetCurrentEnvironment();

-- Panel Positions
PANEL_INSET_LEFT_OFFSET = 4;
PANEL_INSET_RIGHT_OFFSET = -6;
PANEL_INSET_BOTTOM_OFFSET = 4;
PANEL_INSET_BOTTOM_BUTTON_OFFSET = 26;
PANEL_INSET_TOP_OFFSET = -24;
PANEL_INSET_ATTIC_OFFSET = -60;

-- Magic Button code
function MagicButton_OnLoad(self)

	-- Find out where this button is anchored and adjust positions/separators as necessary
	for i=1, self:GetNumPoints() do
		local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(i);

		if (relativeTo:GetObjectType() == "Button" and (point == "TOPLEFT" or point == "LEFT")) then

			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 1, 0);
			end


		elseif (relativeTo:GetObjectType() == "Button" and (point == "TOPRIGHT" or point == "RIGHT")) then

			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, -1, 0);
			end


		elseif (point == "BOTTOMLEFT") then
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, 4, 4);
			end
		elseif (point == "BOTTOMRIGHT") then
			if (offsetX == 0 and offsetY == 0) then
				self:SetPoint(point, relativeTo, relativePoint, -6, 4);
			end
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
	elseif self.Inset then
		self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, -atticHeight);
	end
end

function FrameTemplate_SetButtonBarHeight(self, buttonBarHeight)
	if self.topInset then
		self.topInset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, buttonBarHeight);
	elseif self.Inset then
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

local function ButtonFrameTemplate_UpdateAnchors(self, isPortraitMode)
	ButtonFrameTemplate_UpdateRegionAnchor(self.Bg, isPortraitMode and 2 or 7);
	ButtonFrameTemplate_UpdateRegionAnchor(self.Inset, isPortraitMode and 4 or 9);

	if self.TitleContainer then
		self.TitleContainer:SetPoint("TOPLEFT", self, "TOPRIGHT", isPortraitMode and 58 or 0, -1);
		self.TitleContainer:SetPoint("TOPRIGHT", self, "TOPLEFT", isPortraitMode and -24 or 0, -1);
	end
end

function ButtonFrameTemplate_HidePortrait(self)
	self:SetBorder("ButtonFrameTemplateNoPortrait");
	self:SetPortraitShown(false);

	local isPortraitMode = false;
	ButtonFrameTemplate_UpdateAnchors(self, isPortraitMode);
end

function ButtonFrameTemplate_ShowPortrait(self)
	self:SetBorder("PortraitFrameTemplate");
	self:SetPortraitShown(true);

	local isPortraitMode = true;
	ButtonFrameTemplate_UpdateAnchors(self, isPortraitMode);
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
	envTable[target]:SetFocus();
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
	self.Instructions:SetText(self.instructionText);
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

function SearchBoxTemplate_ClearText(self)
	self:SetText("");
	self:ClearFocus();
end

function SearchBoxTemplateClearButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	SearchBoxTemplate_ClearText(self:GetParent());
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
	if not IsOnGlueScreen() then
		GameTooltip_Hide();
	end

	if self.Text:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.Text:GetText());
	end
end

function PanelTabButtonMixin:OnLeave()
	if not IsOnGlueScreen() then
		GameTooltip_Hide();
	end
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
	return frame.Tabs and frame.Tabs[index] or envTable[frame:GetName().."Tab"..index];
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

function PanelTemplates_SetTabShown(frame, index, shown)
	if shown then
		PanelTemplates_ShowTab(frame, index);
	else
		PanelTemplates_HideTab(frame, index);
	end
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
	local height, range, scroll, cursorOffset;
	if ( self.handleCursorChange ) then
		if ( not scrollFrame ) then
			scrollFrame = self:GetParent();
		end
		height = scrollFrame:GetHeight();
		range = scrollFrame:GetVerticalScrollRange();
		scroll = scrollFrame:GetVerticalScroll();
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
	GetEditBoxMetatable().__index.SetEnabled(self, enable);
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
	elseif self.cvar and not self.skipResetOnShow then
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

function MaximizeMinimizeButtonFrameMixin:SkipResetOnShow(skipResetOnShow)
	self.skipResetOnShow = skipResetOnShow;
end

function MaximizeMinimizeButtonFrameMixin:SetMinimizedCVar(cvar)
	self.cvar = cvar;
end

function MaximizeMinimizeButtonFrameMixin:SetOnMaximizedCallback(maximizedCallback)
	self.maximizedCallback = maximizedCallback;
end

function MaximizeMinimizeButtonFrameMixin:Maximize(isAutomaticAction, skipCallback)
	if self.maximizedCallback and not skipCallback then
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

function MaximizeMinimizeButtonFrameMixin:Minimize(isAutomaticAction, skipCallback)
	if self.minimizedCallback and not skipCallback then
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
		tooltip:SetText(self.Text:GetText(), self.Text:GetTextColor());
		tooltip:Show();
	end
end

function TruncatedTooltipFontStringWrapperMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	if tooltip:GetOwner() == self then
		tooltip:Hide();
	end
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
	if self:IsEnabled() then
		self:SetTextures("Interface\\Buttons\\UI-Silver-Button-Down");
		if self.Icon then
			self.Icon:AdjustPointsOffset(1, -1);
		end
	end
end

function UIMenuButtonStretchMixin:OnMouseUp(button)
	if self:IsEnabled() then
		self:SetTextures("Interface\\Buttons\\UI-Silver-Button-Up");
		if self.Icon then
			self.Icon:AdjustPointsOffset(-1, 1);
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
	self.ResetButton = CreateFrame("Button", nil, self, "UIResetButtonTemplate");
	self.ResetButton:SetPoint("CENTER", self, "TOPRIGHT", -3, 0);
	self.ResetButton:SetScript("OnClick", function(button, buttonName, down)
		if not self:IsEnabled() then
			return;
		end

		if self.resetFunction then
			 self.resetFunction();
		end

		self.ResetButton:Hide();
	end);
end

function UIResettableDropdownButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self:OnMouseDownInternal(button);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function UIResettableDropdownButtonMixin:OnMouseDownInternal(button)
	-- Override as needed:
	-- Not all UIResettableDropdownButtonMixin inherit from something that uses UIMenuButtonStretchMixin.
	UIMenuButtonStretchMixin.OnMouseDown(self, button);
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
	self:UpdateWidth();
end

function DialogHeaderMixin:SetHeaderFont(font)
	self.Text:SetFontObject(font);
	self:UpdateWidth();
end

function DialogHeaderMixin:UpdateWidth()
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

function UIButtonMixin:GetOnClickSoundKit()
	return self.onClickSoundKit;
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
		self:UpdateLabelFont();
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
	self:UpdateLabelFont();
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

function ResizeCheckButtonMixin:SetTooltipText(tooltipText)
	self.tooltipText = tooltipText;
end

function ResizeCheckButtonMixin:SetTooltipDisabled(disabled)
	self.tooltipDisabled = disabled;

	if self.tooltipDisabled and GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
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
	if self.Button == nil then
		return;
	end
	
	self.Button:SetEnabled(enabled);

	self:UpdateLabelFont();
	end

function ResizeCheckButtonMixin:IsControlEnabled()
	if self.Button == nil then
		return false;
end

	return self.Button:IsEnabled();
end

function ResizeCheckButtonMixin:OnEnter()
	if(self.tooltipText ~= nil and not self.tooltipDisabled) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipText);
		GameTooltip:Show();
	end
end

function ResizeCheckButtonMixin:OnLeave()
	if(self.tooltipText ~= nil and not self.tooltipDisabled) then
		GameTooltip:Hide();
	end
end

function ResizeCheckButtonMixin:UpdateLabelFont()
	if not self.Label then
		return;
	end

	local enabledFont = self.labelFont or "GameFontHighlightLarge";
	local disabledFont = self.disabledLabelFont or "GameFontDisableLarge";
	local enabled = self:IsControlEnabled();
	self.Label:SetFontObject(enabled and enabledFont or disabledFont);
end

function ResizeCheckButtonMixin:OnEnter()
	if(self.tooltipText ~= nil and not self.tooltipDisabled) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipText);
		GameTooltip:Show();
	end
end

function ResizeCheckButtonMixin:OnLeave()
	if(self.tooltipText ~= nil and not self.tooltipDisabled) then
		GameTooltip:Hide();
	end
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

DropdownWithSteppersMixin = {};

function DropdownWithSteppersMixin:OnLoad()
	self.IncrementButton:SetPoint("LEFT", self.Dropdown, "RIGHT", (self.incrementOffsetX or 4), 0);
	self.IncrementButton:SetScript("OnClick", GenerateClosure(self.OnIncrementClicked, self));

	self.DecrementButton:SetPoint("RIGHT", self.Dropdown, "LEFT", (self.decrementOffsetX or -5), 0);
	self.DecrementButton:SetScript("OnClick", GenerateClosure(self.OnDecrementClicked, self));

	local function OnUpdate(o, previousRadio, nextRadio, selections)
		local canDecrement = previousRadio ~= nil;
		local canIncrement = nextRadio ~= nil;
		self:SetSteppersEnabled(canDecrement, canIncrement);
	end

	self.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnUpdate, OnUpdate);
end

function DropdownWithSteppersMixin:SetEnabled(enabled)
	self.Dropdown:SetEnabled(enabled);
	self:UpdateSteppers();
end

function DropdownWithSteppersMixin:OnIncrementClicked(button, buttonName, down)
	self:Increment();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function DropdownWithSteppersMixin:OnDecrementClicked(button, buttonName, down)
		self:Decrement();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function DropdownWithSteppersMixin:Increment()
	self.Dropdown:Increment();
end

function DropdownWithSteppersMixin:Decrement()
	self.Dropdown:Decrement();
end

function DropdownWithSteppersMixin:SetSteppersEnabled(canDecrement, canIncrement)
	if self.Dropdown:IsEnabled() then
		self.DecrementButton:SetEnabled(canDecrement);
		self.IncrementButton:SetEnabled(canIncrement);
	else
		self.DecrementButton:SetEnabled(false);
		self.IncrementButton:SetEnabled(false);
	end
end

function DropdownWithSteppersMixin:UpdateSteppers()
	if self.Dropdown:IsEnabled() then
		local previousRadio, nextRadio, selections = self.Dropdown:CollectSelectionData();
		local canDecrement = previousRadio ~= nil;
		local canIncrement = nextRadio ~= nil;
		self:SetSteppersEnabled(canDecrement, canIncrement);
	else
		self:SetSteppersEnabled(false, false);
end
end

DropdownWithSteppersAndLabelMixin = CreateFromMixins(DropdownWithSteppersMixin);

function DropdownWithSteppersAndLabelMixin:SetText(text)
	self.Label:SetText(text);
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

TopLevelParentScaleFrameMixin = {};

function TopLevelParentScaleFrameMixin:OnScaleFrameLoad()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:UpdateScale();
end

function TopLevelParentScaleFrameMixin:OnScaleFrameEvent(event, ...)
	if (event == "DISPLAY_SIZE_CHANGED") or (event == "UI_SCALE_CHANGED") then
		self:UpdateScale();
	end
end

function TopLevelParentScaleFrameMixin:OnScaleFrameShow()
	self:UpdateScale();
end

function TopLevelParentScaleFrameMixin:UpdateScale()
	-- Avoid getting ourselves as the top parent for scaling, in case we're currently the alternate top
	local optionalExcludedParent = self;
	local topLevelParent = GetAppropriateTopLevelParent(optionalExcludedParent);

	if topLevelParent then
		self:SetScale(topLevelParent:GetScale());
	end
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
	local target = self.target;

	local continueDragStart = true;
	if target.onDragStartCallback then
		continueDragStart = target.onDragStartCallback(self);
	end

	if continueDragStart then
		target:StartMoving();
	end

	if SetCursor then
		SetCursor("UI_MOVE_CURSOR");
	end
end

function PanelDragBarMixin:OnDragStop()
	local target = self.target;

	local continueDragStop = true;
	if target.onDragStopCallback then
		continueDragStop = target.onDragStopCallback(self);
	end

	if continueDragStop then
		target:StopMovingOrSizing();
	end

	if SetCursor then
		SetCursor(nil);
	end
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

function PanelResizeButtonMixin:OnEnter()
	if SetCursor then
		SetCursor("UI_RESIZE_CURSOR");
	end
end

function PanelResizeButtonMixin:OnLeave()
	if SetCursor then
		SetCursor(nil);
	end
end

function PanelResizeButtonMixin:OnMouseDown()
	self.isActive = true;

	local target = self.target;
	if not target then
		return;
	end

	local continueResizeStart = true;
	if target.onResizeStartCallback then
		continueResizeStart = target.onResizeStartCallback(self);
	end

	if continueResizeStart then
		local alwaysStartFromMouse = true;
		self.target:StartSizing("BOTTOMRIGHT", alwaysStartFromMouse);
	end
end

function PanelResizeButtonMixin:OnMouseUp()
	self.isActive = false;

	local target = self.target;
	if not target then
		return;
	end

	local continueResizeStop = true;
	if target.onResizeStopCallback then
		continueResizeStop = target.onResizeStopCallback(self);
	end

	if continueResizeStop then
		target:StopMovingOrSizing();
	end

	if self.resizeStoppedCallback ~= nil then
		self.resizeStoppedCallback(self.target);
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

AlphaHighlightButtonMixin = {};

function AlphaHighlightButtonMixin:UpdateHighlightForState()
	self:SetHighlightAtlas(self:GetHighlightForState());
end

function AlphaHighlightButtonMixin:GetHighlightForState()
	if self.isPressed then
		return self.PushedTexture:GetAtlas();
	end

	return self.NormalTexture:GetAtlas();
end

function AlphaHighlightButtonMixin:OnMouseDown()
	self:SetPressed(true);
end

function AlphaHighlightButtonMixin:OnMouseUp()
	self:SetPressed(false);
end

function AlphaHighlightButtonMixin:SetPressed(pressed)
	self.isPressed = pressed;
	self:UpdateHighlightForState();
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

IconSelectorPopupFrameIconFilterTypes = EnumUtil.MakeEnum(
	"All",
	"Spell",
	"Item"
);

local ValidIconSelectorCursorTypes = {
	"item",
	"spell",
	"mount",
	"battlepet",
	"macro"
};

local function IconSelectorPopupFrame_IconFilterToIconTypes(filter)
	if (filter == IconSelectorPopupFrameIconFilterTypes.All) then
		return IconDataProvider_GetAllIconTypes();
	elseif (filter == IconSelectorPopupFrameIconFilterTypes.Spell) then
		return { IconDataProviderIconType.Spell };
	elseif (filter == IconSelectorPopupFrameIconFilterTypes.Item) then
		return { IconDataProviderIconType.Item };
	end
	return nil;
end

local IconSelectorPopupFramesShown = 0;

function IconSelectorPopupFrameTemplateMixin:OnLoad()
	local function IconButtonInitializer(button, selectionIndex, icon)
		button:SetIconTexture(icon);
	end
	self.IconSelector:SetSetupCallback(IconButtonInitializer);
	self.IconSelector:AdjustScrollBarOffsets(-14, -4, 6);

	self.BorderBox.OkayButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
		self:OkayButton_OnClick();
	end);

	self.BorderBox.CancelButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
		self:CancelButton_OnClick();
	end);

	self.BorderBox.EditBoxHeaderText:SetText(self.editBoxHeaderText);

	self.iconFilter = IconSelectorPopupFrameIconFilterTypes.All;

	self.BorderBox.IconTypeDropdown:SetWidth(150);

	self:UpdateDropdown();
end

-- Usually overridden by inheriting frame.
function IconSelectorPopupFrameTemplateMixin:OnShow()
	IconSelectorPopupFramesShown = IconSelectorPopupFramesShown + 1;

	self:RegisterEvent("CURSOR_CHANGED");
	self:RegisterEvent("GLOBAL_MOUSE_UP");

	self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconSelector(self);
	self.BorderBox.IconSelectorEditBox:SetIconSelector(self);

	self:UpdateStateFromCursorType();
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
		self:UpdateStateFromCursorType();
	elseif ( event == "GLOBAL_MOUSE_UP" and DoesAncestryIncludeAny(self, GetMouseFoci())) then
		self:SetIconFromMouse();
	end
end

function IconSelectorPopupFrameTemplateMixin:UpdateDropdown()
	local function IsSelected(filterType)
		return self:GetIconFilter() == filterType;
	end

	local function SetSelected(filterType)
		self:SetIconFilterInternal(filterType);
	end

	self.BorderBox.IconTypeDropdown:SetupMenu(function(dropdown, rootDescription)
		for key, filterType in pairs(IconSelectorPopupFrameIconFilterTypes) do
			local text = envTable["ICON_FILTER_" .. strupper(key)];
			rootDescription:CreateRadio(text, IsSelected, SetSelected, filterType);
		end
	end);
end

function IconSelectorPopupFrameTemplateMixin:UpdateStateFromCursorType()
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
	self.BorderBox.IconTypeDropdown:SetShown(not isValidCursorType);
		self.IconSelector:SetShown(not isValidCursorType);
end

function IconSelectorPopupFrameTemplateMixin:SetIconFromMouse()
	local cursorType, ID = GetCursorInfo();
	for _, validType in ipairs(ValidIconSelectorCursorTypes) do
		if ( cursorType == validType ) then
			local icon;
			if ( cursorType == "item" ) then
				icon = select(10, C_Item.GetItemInfo(ID));
			elseif ( cursorType == "spell" ) then
				-- 'ID' field for spells would actually be the slot number, not the actual spellID, so we get this separately.
				local spellID = select(4, GetCursorInfo());
				icon = C_Spell.GetSpellTexture(spellID);
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
			end

			self:SetSelectedIconText();
			break;
		end
	end
end

function IconSelectorPopupFrameTemplateMixin:SetSelectedIconText()
	if ( self:GetSelectedIndex() ) then
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall);
	else
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_NOTINLIST);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontDisableSmall);
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

function IconSelectorPopupFrameTemplateMixin:SetIconFilterInternal(iconFilter)
	if (self.iconFilter == iconFilter) then
		return;
	end

	self.iconFilter = iconFilter;
	local iconTypes = IconSelectorPopupFrame_IconFilterToIconTypes(self.iconFilter);
	self.iconDataProvider:SetIconTypes(iconTypes);
	self.IconSelector:UpdateSelections();
	self:ReevaluateSelectedIcon();
end

function IconSelectorPopupFrameTemplateMixin:SetIconFilter(iconFilter)
	self:SetIconFilterInternal(iconFilter);

	self:UpdateDropdown();
end

function IconSelectorPopupFrameTemplateMixin:GetIconFilter()
	return self.iconFilter;
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

function IconSelectorPopupFrameTemplateMixin:ReevaluateSelectedIcon()
	local texture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
	self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture));
	self:SetSelectedIconText();
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

SearchBoxListElementMixin = {};

function SearchBoxListElementMixin:OnEnter()
	self:GetParent():SetSearchPreviewSelection(self:GetID());
end

function SearchBoxListElementMixin:OnClick()
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
end

-- SearchBoxListMixin was refactored out of EncounterJournal for use in Professions but is not complete. It doesn't
-- provide any interface for handling the bar progress updates.
SearchBoxListMixin = {};

function SearchBoxListMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);

	self.searchButtons = {};

	local function SetupButton(button, index)
		button:SetFrameStrata("DIALOG");
		button:SetFrameLevel(self:GetFrameLevel() + 10);
		button:SetID(index);
		button:Hide();
	end

	local buttonFirst = CreateFrame("BUTTON", nil, self, self.buttonTemplate);
	buttonFirst:SetPoint("TOPLEFT", self.searchPreviewContainer, "TOPLEFT");
	buttonFirst:SetPoint("BOTTOMRIGHT", self.searchPreviewContainer, "BOTTOMRIGHT");
	SetupButton(buttonFirst, 1);
	table.insert(self.searchButtons, buttonFirst);

	local buttonsMax = math.max(1, self.buttonCount or 5);
	local buttonIndex = 2;
	local buttonLast = buttonFirst;
	while buttonIndex <= buttonsMax do
		local button = CreateFrame("BUTTON", nil, self, self.buttonTemplate);
		button:SetPoint("TOPLEFT", buttonLast, "BOTTOMLEFT");
		button:SetPoint("TOPRIGHT", buttonLast, "BOTTOMRIGHT");
		SetupButton(button, buttonIndex);

		table.insert(self.searchButtons, button);
		buttonIndex = buttonIndex + 1;
		buttonLast = button;
	end

	self.showAllResults = CreateFrame("BUTTON", nil, self, self.showAllButtonTemplate);
	self.showAllResults:SetPoint("LEFT", buttonFirst, "LEFT");
	self.showAllResults:SetPoint("RIGHT", buttonFirst, "RIGHT");
	self.showAllResults:SetPoint("TOP", buttonLast, "BOTTOM");
	local showAllResultsIndex =  #self.searchButtons + 1;
	SetupButton(self.showAllResults, showAllResultsIndex);
	self.allResultsIndex = showAllResultsIndex;

	local bar = self.searchProgress.bar;
	bar:SetStatusBarColor(0, .6, 0, 1);
	bar:SetMinMaxValues(0, 1000);
	bar:SetValue(0);
	bar:GetStatusBarTexture():SetDrawLayer("BORDER");

	bar:SetScript("OnHide", function()
		bar:SetValue(0);
		bar.previousResults = nil;
	end);

	self.HasStickyFocus = function()
		return DoesAncestryIncludeAny(self, GetMouseFoci());
	end
	self.selectedIndex = 1;
end

function SearchBoxListMixin:HideSearchPreview()
	self.searchProgress:Hide();
	self.showAllResults:Hide();

	for index, button in ipairs(self.searchButtons) do
		button:Hide();
	end

	self.searchPreviewContainer:Hide();
end

function SearchBoxListMixin:HideSearchProgress()
	self.searchProgress:Hide();
	self:FixSearchPreviewBottomBorder();
end

function SearchBoxListMixin:Close()
	self:HideSearchPreview();
	self:ClearFocus();
end

function SearchBoxListMixin:Clear()
	self.clearButton:Click();
end

function SearchBoxListMixin:IsSearchPreviewShown()
	return self.searchPreviewContainer:IsShown();
end

function SearchBoxListMixin:SetSearchResultsFrame(frame)
	self.searchResultsFrame = frame;
end

function SearchBoxListMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end

function SearchBoxListMixin:IsCurrentTextValidForSearch()
	return self:IsTextValidForSearch(self:GetText());
end

function SearchBoxListMixin:IsTextValidForSearch(text)
	return strlen(text) >= (self.minCharacters or 1);
end

function SearchBoxListMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);

	local text = self:GetText();
	if not self:IsTextValidForSearch(text) then
		self:HideSearchPreview();
		return false, text;
	end

	self:SetSearchPreviewSelection(1);

	return true, text;
end

function SearchBoxListMixin:GetButtons()
	return self.searchButtons;
end

function SearchBoxListMixin:GetAllResultsButton()
	return self.showAllResults;
end

function SearchBoxListMixin:GetSearchButtonCount()
	return #self:GetButtons();
end

function SearchBoxListMixin:UpdateSearchPreview(finished, dbLoaded, numResults)
	local lastShown = self;
	if self.searchButtons[numResults] then
		lastShown = self.searchButtons[numResults];
	end

	self.showAllResults:Hide();
	self.searchProgress:Hide();
	if not finished then
		self.searchProgress:SetPoint("TOP", lastShown, "BOTTOM", 0, 0);

		if dbLoaded then
			self.searchProgress.loading:Hide();
			self.searchProgress.bar:Show();
		else
			self.searchProgress.loading:Show();
			self.searchProgress.bar:Hide();
		end

		self.searchProgress:Show();
	elseif not self.searchButtons[numResults] then
		self.showAllResults.text:SetText(SEARCH_RESULTS_SHOW_COUNT:format(numResults));
		self.showAllResults:Show();
	end

	self:FixSearchPreviewBottomBorder();
	self.searchPreviewContainer:Show();
end

function SearchBoxListMixin:FixSearchPreviewBottomBorder()
	local lastShownButton = nil;
	if self.showAllResults:IsShown() then
		lastShownButton = self.showAllResults;
	elseif self.searchProgress:IsShown() then
		lastShownButton = self.searchProgress;
	else
		for index, button in ipairs(self:GetButtons()) do
			if button:IsShown() then
				lastShownButton = button;
			end
		end
	end

	if lastShownButton ~= nil then
		self.searchPreviewContainer.botRightCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8);
		self.searchPreviewContainer.botLeftCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8);
	else
		self:HideSearchPreview();
	end
end

function SearchBoxListMixin:SetSearchPreviewSelection(selectedIndex)
	local numShown = 0;
	for index, button in ipairs(self:GetButtons()) do
		button.selectedTexture:Hide();

		if button:IsShown() then
			numShown = numShown + 1;
		end
	end

	if self.showAllResults:IsShown() then
		numShown = numShown + 1;
	end
	self.showAllResults.selectedTexture:Hide();

	if numShown == 0 then
		selectedIndex = 1;
	elseif selectedIndex > numShown then
		-- Wrap under to the beginning.
		selectedIndex = 1;
	elseif selectedIndex < 1 then
		-- Wrap over to the end;
		selectedIndex = numShown;
	end

	self.selectedIndex = selectedIndex;

	if selectedIndex == self.allResultsIndex then
		self.showAllResults.selectedTexture:Show();
	else
		self.searchButtons[selectedIndex].selectedTexture:Show();
	end
end

function SearchBoxListMixin:SetSearchPreviewSelectionToAllResults()
	self:SetSearchPreviewSelection(self.allResultsIndex);
end

function SearchBoxListMixin:OnEnterPressed()
	if self.selectedIndex > self.allResultsIndex or self.selectedIndex < 0 then
		return;
	elseif self.selectedIndex == self.allResultsIndex then
		if self.showAllResults:IsShown() then
			self.showAllResults:Click();
		end
	else
		local preview = self.searchButtons[self.selectedIndex];
		if preview:IsShown() then
			preview:Click();
		end
	end

	self:HideSearchPreview();
end

function SearchBoxListMixin:OnKeyDown(key)
	if key == "UP" then
		self:SetSearchPreviewSelection(self.selectedIndex - 1);
	elseif key == "DOWN" then
		self:SetSearchPreviewSelection(self.selectedIndex + 1);
	end
end

function SearchBoxListMixin:OnFocusLost()
	SearchBoxTemplate_OnEditFocusLost(self);
	self:HideSearchPreview();
end

function SearchBoxListMixin:OnFocusGained()
	SearchBoxTemplate_OnEditFocusGained(self);

	if self.searchResultsFrame then
		self.searchResultsFrame:Hide();
	end

	self:SetSearchPreviewSelection(1);
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
		if self:IsMouseMotionFocus() then
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

MainMenuFrameMixin = {};

local function HideAndClearAnchorsAndLayoutIndex(framePool, frame)
	Pool_HideAndClearAnchors(framePool, frame);
	frame.layoutIndex = nil;
end

function MainMenuFrameMixin:OnLoad()
	if self.dialogHeaderFont then
		self.Header:SetHeaderFont(self.dialogHeaderFont);
	end

	self.buttonPool = CreateFramePool("BUTTON", self, self.buttonTemplate, HideAndClearAnchorsAndLayoutIndex);
	self:Reset();
end

function MainMenuFrameMixin:Reset()
	self.buttonPool:ReleaseAll();
	self.sectionSpacing = nil;
	self.nextLayoutIndex = 1;
end

function MainMenuFrameMixin:AddButton(text, callback, isDisabled, disabledText)
	local newButton = self.buttonPool:Acquire();

	newButton.layoutIndex = self.nextLayoutIndex;
	self.nextLayoutIndex = self.nextLayoutIndex + 1;
	newButton.topPadding = self.sectionSpacing;
	self.sectionSpacing = nil;

	newButton:SetText(text);
	newButton:SetScript("OnClick", callback);

	newButton:SetMotionScriptsWhileDisabled(true);
	newButton:SetEnabled(not isDisabled);
	if isDisabled and disabledText then
		newButton:SetScript("OnEnter", function()
			local tooltip = GetAppropriateTooltip();
			tooltip:SetOwner(newButton, "ANCHOR_RIGHT");
			tooltip:SetText(text);
			GameTooltip_AddErrorLine(tooltip, disabledText);
			tooltip:Show();
		end);

		newButton:SetScript("OnLeave", function()
			GetAppropriateTooltip():Hide();
		end);
	else
		newButton:SetScript("OnEnter", nil);
		newButton:SetScript("OnLeave", nil);
	end

	newButton:Show();

	self:MarkDirty();

	return newButton;
end

function MainMenuFrameMixin:AddSection(customSpacing)
	self.sectionSpacing = customSpacing or 20;
end

function MainMenuFrameMixin:AddCloseButton(customText, customSpacing)
	self:AddSection(customSpacing);
	self:AddButton(customText or CLOSE, function()
		PlaySound(SOUNDKIT.IG_MAINMENU_CONTINUE);
		self:CloseMenu();
	end);
end

function MainMenuFrameMixin:CloseMenu()
	self:Hide();
end

SquareExpandButtonMixin = {};

function SquareExpandButtonMixin:InitButton()
	self:SetExpandedState(true);

	local function OnClickHandler()
		if self.toggleCallback then
			self:SetExpandedState(self.toggleCallback())
		end
	end

	self:SetOnClickHandler(OnClickHandler, self.onClickSoundKit or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function SquareExpandButtonMixin:SetToggleCallback(toggleCallback)
	self.toggleCallback = toggleCallback;
end

function SquareExpandButtonMixin:SetExpandedState(isExpanded)
	self:SetHighlightAtlas(isExpanded and self.highlightExpandedAtlas or self.highlightCollapsedAtlas);
	self:SetNormalAtlas(isExpanded and self.normalExpandedAtlas or self.normalCollapsedAtlas);
	self:SetPushedAtlas(isExpanded and self.pushedExpandedAtlas or self.pushedCollapsedAtlas);
	self:SetDisabledAtlas(isExpanded and self.disabledExpandedAtlas or self.disabledCollapsedAtlas);
end

ExpandBarMixin = {};

function ExpandBarMixin:OnLoad()
	-- A callback from the expand button is always from user input.
	local isUserInput = true;
	self.ExpandButton:SetToggleCallback(GenerateFlatClosure(self.Toggle, self, isUserInput));
end

function ExpandBarMixin:OnEnter()
	self.ExpandButton:LockHighlight();
end

function ExpandBarMixin:OnLeave()
	self.ExpandButton:UnlockHighlight();
end

function ExpandBarMixin:OnClick()
	PlaySound(self.ExpandButton:GetOnClickSoundKit());

	local isUserInput = true;
	self:Toggle(isUserInput);
end

function ExpandBarMixin:Toggle(isUserInput)
	local shouldBeShown = not self.target:IsShown();
	self.target:SetShown(shouldBeShown);
	self:SetExpandedState(shouldBeShown);

	if self.onToggleCallback then
		self.onToggleCallback(shouldBeShown, isUserInput);
	end

	return shouldBeShown;
end

function ExpandBarMixin:SetExpanded(isExpanded, isUserInput)
	if isExpanded ~= self:IsExpanded() then
		self:Toggle(isUserInput);
	end
end

function ExpandBarMixin:IsExpanded()
	return self.target:IsShown();
end

function ExpandBarMixin:SetExpandedState(expanded)
	self.ExpandButton:SetExpandedState(expanded);
end

function ExpandBarMixin:UpdateExpandedState()
	self:SetExpandedState(self.target and self.target:IsShown());
end

function ExpandBarMixin:SetExpandTarget(target)
	self.target = target;
	self:UpdateExpandedState();
end

function ExpandBarMixin:SetOnToggleCallback(onToggleCallback)
	self.onToggleCallback = onToggleCallback;
end

function ExpandBarMixin:SetEnabledState(isEnabled)
	self:SetEnabled(isEnabled);
	self.ExpandButton:SetEnabled(isEnabled);
end

LevelRangeFrameMixin = {};

function LevelRangeFrameMixin:OnLoad()
	self.MinLevel.nextEditBox = self.MaxLevel;
	self.MaxLevel.nextEditBox = self.MinLevel;

	local function OnTextChanged(...)
		self:OnLevelRangeChanged();
	end
	self.MinLevel:SetScript("OnTextChanged", OnTextChanged);
	self.MaxLevel:SetScript("OnTextChanged", OnTextChanged);
end

function LevelRangeFrameMixin:OnHide()
	self:FixLevelRange();
end

function LevelRangeFrameMixin:SetLevelRangeChangedCallback(levelRangeChangedCallback)
	self.levelRangeChangedCallback = levelRangeChangedCallback;
end

function LevelRangeFrameMixin:OnLevelRangeChanged()
	if self.levelRangeChangedCallback then
		local minLevel, maxLevel = self:GetLevelRange();
		self.levelRangeChangedCallback(minLevel, maxLevel);
	end
end

function LevelRangeFrameMixin:FixLevelRange()
	local maxLevel = self.MaxLevel:GetNumber();
	if maxLevel == 0 then
		return;
	end

	local minLevel = self.MinLevel:GetNumber();
	if minLevel > maxLevel then
		self:SetMinLevel(maxLevel);
	end
end

function LevelRangeFrameMixin:SetMinLevel(minLevel)
	self.MinLevel:SetNumber(minLevel);
end

function LevelRangeFrameMixin:SetMaxLevel(maxLevel)
	self.MaxLevel:SetNumber(maxLevel);
end

function LevelRangeFrameMixin:Reset()
	self.MinLevel:SetText("");
	self.MaxLevel:SetText("");
end

function LevelRangeFrameMixin:GetLevelRange()
	return self.MinLevel:GetNumber(), self.MaxLevel:GetNumber();
end

function Main_HelpPlate_Button_OnEnter(self)
	Main_HelpPlate_Button_ShowTooltip(self);
	HelpPlateTooltip.LingerAndFade:Stop();
end

function Main_HelpPlate_Button_ShowTooltip(self)
	HelpPlateTooltip.ArrowRIGHT:Show();
	HelpPlateTooltip.ArrowGlowRIGHT:Show();
	HelpPlateTooltip:SetPoint("LEFT", self, "RIGHT", 10, 0);
	HelpPlateTooltip.Text:SetText(self.MainHelpPlateButtonTooltipText or MAIN_HELP_BUTTON_TOOLTIP);
	HelpPlateTooltip:Show();
end

function Main_HelpPlate_Button_OnLeave(self)
	HelpPlateTooltip.ArrowRIGHT:Hide();
	HelpPlateTooltip.ArrowGlowRIGHT:Hide();
	HelpPlateTooltip:ClearAllPoints();
	HelpPlateTooltip:Hide();
end