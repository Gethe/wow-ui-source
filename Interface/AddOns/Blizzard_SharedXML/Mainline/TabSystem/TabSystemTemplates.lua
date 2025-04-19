
local TabSideExtraSpacing = 20;

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
	if self.isTabOnTop then
		return isSelected and 0 or -3;
	else
		return isSelected and -3 or 2;
	end
end

function TabSystemButtonArtMixin:SetTabSelected(isSelected)
	self.isSelected = isSelected;

	self.Left:SetShown(not isSelected);
	self.Middle:SetShown(not isSelected);
	self.Right:SetShown(not isSelected);
	self.LeftActive:SetShown(isSelected);
	self.MiddleActive:SetShown(isSelected);
	self.RightActive:SetShown(isSelected);

	local selectedFontObject = self.selectedFontObject or GameFontHighlightSmall;
	local unselectedFontObject = self.unselectedFontObject or GameFontNormalSmall;
	self:SetNormalFontObject(isSelected and selectedFontObject or unselectedFontObject);

	self:SetEnabled(not isSelected and not self.forceDisabled);

	self.Text:SetPoint("CENTER", self, "CENTER", 0, self:GetTextYOffset(isSelected));

	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function TabSystemButtonArtMixin:SetTabWidth(width)
	self:SetWidth(width);
end

TabSystemButtonMixin = {};

function TabSystemButtonMixin:OnEnter()
	if not self:IsEnabled() and self.errorReason ~= nil then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -6);
		GameTooltip_AddErrorLine(GameTooltip, self.errorReason);
		if self.tooltipText then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
		end
		GameTooltip:Show();
	elseif self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -6);
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
		GameTooltip:Show();
	elseif self.Text:IsTruncated() then
		local text = self.Text:GetText();
		if text then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -6);
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
	tabSystem:PlayTabSelectSound();
	tabSystem:SetTab(self:GetTabID());
end

function TabSystemButtonMixin:Init(tabID, tabText)
	self.tabID = tabID;
	self:HandleRotation();
	self.tabText = tabText;
	self:SetText(tabText);
	self:UpdateTabWidth();
	self:SetTabSelected(false);
end

function TabSystemButtonMixin:SetTooltipText(tooltipText)
	self.tooltipText = tooltipText;
end

function TabSystemButtonMixin:SetTabEnabled(enabled, errorReason)
	self.forceDisabled = not enabled;
	self:SetEnabled(enabled and not self.isSelected);
	local text = enabled and self.tabText or DISABLED_FONT_COLOR:WrapTextInColorCode(self.tabText);
	self.Text:SetText(text);
	self.errorReason = errorReason;
end

function TabSystemButtonMixin:UpdateTabWidth()
	local sidesWidth = self.Left:GetWidth() + self.Right:GetWidth();
	local width = sidesWidth + TabSideExtraSpacing;
	local minTabWidth, maxTabWidth = self:GetTabSystem():GetTabWidthConstraints();
	local textWidth;

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

function TabSystemMixin:AddTab(tabText)
	local tabID = #self.tabs + 1;
	local newTab = self.tabPool:Acquire();
	table.insert(self.tabs, newTab);
	newTab.layoutIndex = tabID;
	newTab:Init(tabID, tabText);
	newTab:Show();
	self:MarkDirty();
	return tabID;
end

function TabSystemMixin:SetTabSelectedCallback(tabSelectedCallback)
	self.tabSelectedCallback = tabSelectedCallback;
end

function TabSystemMixin:SetTab(tabID)
	if not self.tabSelectedCallback(tabID) then
		self:SetTabVisuallySelected(tabID);
	end
end

function TabSystemMixin:SetTabVisuallySelected(tabID)
	self.selectedTabID = tabID;

	for i, tab in ipairs(self.tabs) do
		tab:SetTabSelected(tab:GetTabID() == tabID);
	end
end

function TabSystemMixin:SetTabShown(tabID, isShown)
	self.tabs[tabID]:SetShown(isShown);
	self:MarkDirty();
end

function TabSystemMixin:SetTabEnabled(tabID, enabled, errorReason)
	self.tabs[tabID]:SetTabEnabled(enabled, errorReason);
	self:MarkDirty();
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