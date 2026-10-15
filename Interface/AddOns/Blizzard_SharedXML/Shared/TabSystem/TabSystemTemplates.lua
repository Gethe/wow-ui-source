
local TabSideExtraSpacingStandard = 20;
local TabSideExtraSpacingSquare = 8;
local TabSideExtraSpacing = TabSideExtraSpacingStandard;

TabSystemButtonArtMixin = {};

function TabSystemButtonArtMixin:HandleRotation()
	if self.isTabOnTop then
		for _, texture in ipairs(self.RotatedTextures) do
			texture:ClearAllPoints();
			texture:SetRotation(math.pi);
		end

		self.RightActive:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -7, 0);
		self.LeftActive:SetPoint("BOTTOMRIGHT");
		self.MiddleActive:SetPoint("LEFT", self.RightActive, "RIGHT");
		self.MiddleActive:SetPoint("RIGHT", self.LeftActive, "LEFT");

		self.Right:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -6, 0);
		self.Left:SetPoint("BOTTOMRIGHT");
		self.Middle:SetPoint("LEFT", self.Right, "RIGHT");
		self.Middle:SetPoint("RIGHT", self.Left, "LEFT");

		self.LeftHighlight:SetPoint("TOPRIGHT", self.Left);
		self.RightHighlight:SetPoint("TOPLEFT", self.Right);
		self.MiddleHighlight:SetPoint("LEFT", self.Middle, "LEFT");
		self.MiddleHighlight:SetPoint("RIGHT", self.Middle, "RIGHT");
	end
end

function TabSystemButtonArtMixin:GetTextYOffset(isSelected)
	local offset = self.textOffsetY or 0;
	if self.isTabOnTop then
		offset = offset + (isSelected and 0 or -3);
	else
		offset = offset + (isSelected and -3 or 2);
	end

	return offset;
end

function TabSystemButtonArtMixin:GetIconYOffset(isSelected)
	return 0;
end

function TabSystemButtonArtMixin:SetTabSelected(isSelected)
	self.isSelected = isSelected;

	if self.squareMode then
		self.SquareBackground:SetShown(not isSelected);
		self.SquareBackgroundActive:SetShown(isSelected);
		self.SquareBackgroundActiveGlow:SetShown(isSelected);
	else
		self.Left:SetShown(not isSelected);
		self.Middle:SetShown(not isSelected);
		self.Right:SetShown(not isSelected);
		self.LeftActive:SetShown(isSelected);
		self.MiddleActive:SetShown(isSelected);
		self.RightActive:SetShown(isSelected);
	end

	local selectedFontObject = self.selectedFontObject or GameFontHighlightSmall;
	local unselectedFontObject = self.unselectedFontObject or GameFontNormalSmall;
	self:SetNormalFontObject(isSelected and selectedFontObject or unselectedFontObject);

	self:SetEnabled(not isSelected and not self:IsForceDisabled());

	self.Text:SetPoint("CENTER", self, "CENTER", 0, self:GetTextYOffset(isSelected));
	self.Icon:SetPoint("CENTER", self, "CENTER", 0, self:GetIconYOffset(isSelected));

	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function TabSystemButtonArtMixin:SetTabWidth(width)
	self:SetWidth(width);
end

function TabSystemButtonArtMixin:SetTabHeight(height)
	for _, texture in ipairs(self.RotatedTextures) do
		texture:SetHeight(height);
	end
end

function TabSystemButtonArtMixin:IsForceDisabled()
	-- Override in your derived Mixin.
	return false, nil;
end

function TabSystemButtonArtMixin:SetSquareMode(enabled)
	self.squareMode = enabled;

	if (enabled) then
		self.Left:Hide();
		self.Middle:Hide();
		self.Right:Hide();
		self.LeftActive:Hide();
		self.MiddleActive:Hide();
		self.RightActive:Hide();
		self.LeftHighlight:Hide();
		self.MiddleHighlight:Hide();
		self.RightHighlight:Hide();

		TabSideExtraSpacing = TabSideExtraSpacingSquare;

		self.SquareBackground:SetAtlas("spellbook-Tab-Frame-C60", true);
		self.SquareBackgroundActive:SetAtlas("spellbook-Tab-Frame-Glow-C60", true);
		self.SquareBackgroundActiveGlow:SetAtlas("spellbook-Tab-Frame-glow-gradient-C60", true);
	else
		self.SquareBackground:Hide();
		self.SquareBackgroundActive:Hide();
		self.SquareBackgroundActiveGlow:Hide();

		TabSideExtraSpacing = TabSideExtraSpacingStandard;
	end

	-- This will show the proper frames.
	self:SetTabSelected(self.isSelected);
end

TabSystemButtonMixin = {};

function TabSystemButtonMixin:OnEnter()
	local showErrorText = not self:IsEnabled() and self.errorReason ~= nil and self:GetTabID() ~= self:GetTabSystem().selectedTabID;
	if showErrorText then
		GameTooltip:SetOwner(self, self.tooltipAnchor, self.tooltipAnchorX, self.tooltipAnchorY);
		GameTooltip_AddErrorLine(GameTooltip, self.errorReason);
		if self.tooltipText then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
		end
		GameTooltip:Show();
	elseif self.tooltipText then
		GameTooltip:SetOwner(self, self.tooltipAnchor, self.tooltipAnchorX, self.tooltipAnchorY);
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
		GameTooltip:Show();
	elseif self.Text:IsTruncated() then
		local text = self.Text:GetText();
		if text then
			GameTooltip:SetOwner(self, self.tooltipAnchor, self.tooltipAnchorX, self.tooltipAnchorY);
			GameTooltip_AddNormalLine(GameTooltip, text);
			GameTooltip:Show();
		end
	end
end

function TabSystemButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function TabSystemButtonMixin:OnClick()
	local tabSystem = self:GetTabSystem();

	local wasSelected = self.isSelected;
	local isUserAction = true;
	tabSystem:SetTab(self:GetTabID(), isUserAction);

	-- Only play the sound if the tab was actually selected
	if not wasSelected and self.isSelected then
		tabSystem:PlayTabSelectSound();
	end
end

function TabSystemButtonMixin:Init(tabID, tabText, tabIcon)
	self.tabID = tabID;
	self:HandleRotation();
	self.tabText = tabText;
	self.tabIcon = tabIcon;

	if tabIcon then
		self.Icon:SetTexture(tabIcon);
		self.Icon:Show();
		self.IconMask:Show();
		self:SetSquareMode(true);
	end

	if tabText then
		self:SetText(tabText);
	end

	self:UpdateTabWidth();
	self:SetTabSelected(false);
end

function TabSystemButtonMixin:GetTabText()
	return self.tabText;
end

function TabSystemButtonMixin:UpdateTabText()
	local tabText = self:GetTabText();
	local text = not self:IsForceDisabled() and tabText or DISABLED_FONT_COLOR:WrapTextInColorCode(tabText);
	self.Text:SetText(text);
end

function TabSystemButtonMixin:SetTooltipText(tooltipText)
	self.tooltipText = tooltipText;
end

function TabSystemButtonMixin:SetTabEnabled(enabled, errorReason)
	self.forceDisabled = not enabled;
	self:SetEnabled(not self:IsForceDisabled() and not self.isSelected);
	self:UpdateTabText();
	self.errorReason = errorReason;
end

function TabSystemButtonMixin:SetTabNotification(showNotification)
	if showNotification then
		if not self.notificationFrame then
			if self.isTabOnTop then
				self.notificationFrame = NotificationUtil.AcquireNotification("TOP", self, "TOP", 0, 10);
			else
				self.notificationFrame = NotificationUtil.AcquireNotification("BOTTOM", self, "BOTTOM", 0, -10);
			end
		end

	elseif self.notificationFrame then
		NotificationUtil.ReleaseNotification(self.notificationFrame);
		self.notificationFrame = nil;
	end
end

function TabSystemButtonMixin:UpdateTabWidth()
	local sidesWidth = self.Left:GetWidth() + self.Right:GetWidth();
	local width = sidesWidth + TabSideExtraSpacing;
	local minTabWidth, maxTabWidth = self:GetTabSystem():GetTabWidthConstraints();
	local textWidth = self.Text:GetWidth() + (self.textPadding or 0);
	local height = self:GetHeight(); 

	if width < textWidth then
		width = textWidth + 10;
	end

	if self.tabIcon then
		width = self.Icon:GetWidth() + TabSideExtraSpacing;
	end
	if maxTabWidth and width > maxTabWidth then
		width = maxTabWidth;
		textWidth = width - 10;
	end

	if minTabWidth and width < minTabWidth then
		width = minTabWidth;
		textWidth = width - 10;
	end

	self.Text:SetWidth(textWidth or 0);

	self:SetTabWidth(width);
	self:SetTabHeight(height);
end

function TabSystemButtonMixin:IsSelected()
	return not not self.isSelected;
end

function TabSystemButtonMixin:IsForceDisabled()
	-- Note: this will intentionally override TabSystemButtonArtMixin.
	return self.forceDisabled, self.errorReason;
end

function TabSystemButtonMixin:GetTooltipText()
	return self.tooltipText;
end

function TabSystemButtonMixin:GetNotificationFrame()
	return self.notificationFrame;
end

function TabSystemButtonMixin:GetTabID()
	return self.tabID;
end

function TabSystemButtonMixin:GetTabSystem()
	return self:GetParent();
end


TabSystemMixin = {};

function TabSystemMixin:OnLoad()
	self.tabs = {};
	self.tabPool = CreateFramePool("BUTTON", self, self.tabTemplate);
end

function TabSystemMixin:AddTab(tabText, tabIcon)
	local tabID = #self.tabs + 1;
	local newTab = self.tabPool:Acquire();
	table.insert(self.tabs, newTab);
	newTab.layoutIndex = tabID;
	newTab:Init(tabID, tabText, tabIcon);
	newTab:Show();
	self:MarkDirty();
	return tabID;
end

function TabSystemMixin:RemoveAllTabs()
	table.wipe(self.tabs);
	self.tabPool:ReleaseAll();
	self:MarkDirty();
end

-- tabSelectedCallback: function (tabID, isUserAction) -> suppressVisualSelection
function TabSystemMixin:SetTabSelectedCallback(tabSelectedCallback)
	self.tabSelectedCallback = tabSelectedCallback;
end

function TabSystemMixin:SetTab(tabID, isUserAction)
	if not self.tabSelectedCallback(tabID, isUserAction) then
		self:SetTabVisuallySelected(tabID);
	end
end

function TabSystemMixin:SetTabVisuallySelected(tabID)
	self.selectedTabID = tabID;

	for i, tab in ipairs(self.tabs) do
		tab:SetTabSelected(tab:GetTabID() == tabID);
	end
end

function TabSystemMixin:SetTabNotification(tabID, showNotification)
	self.tabs[tabID]:SetTabNotification(showNotification);
end

function TabSystemMixin:SetTabShown(tabID, isShown)
	self.tabs[tabID]:SetShown(isShown);
	self:MarkDirty();
end

function TabSystemMixin:IsTabShown(tabID)
	return self.tabs[tabID]:IsShown();
end

function TabSystemMixin:SetTabEnabled(tabID, enabled, errorReason)
	self.tabs[tabID]:SetTabEnabled(enabled, errorReason);
	self:MarkDirty();
end

function TabSystemMixin:IsTabEnabled(tabID)
	return not self.tabs[tabID]:IsForceDisabled();
end

function TabSystemMixin:GetTabWidthConstraints()
	return self.minTabWidth, self.maxTabWidth;
end

function TabSystemMixin:GetTabButton(tabID)
	return self.tabs[tabID];
end

function TabSystemMixin:PlayTabSelectSound()
	if self.tabSelectSound then
		PlaySound(self.tabSelectSound);
	end
end
