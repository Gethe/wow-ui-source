
local TabSideExtraSpacing = 20;

TabSystemButtonArtMixin = {};

function TabSystemButtonArtMixin:HandleRotation()
	if self.isTabOnTop then
		for _, texture in ipairs(self.RotatedTextures) do
			texture:ClearAllPoints();
			texture:SetRotation(math.pi);
		end

		self.RightDisabled:SetPoint("TOPLEFT");
		self.Right:SetPoint("TOPLEFT");
		self.MiddleDisabled:SetPoint("LEFT", self.RightDisabled, "RIGHT");
		self.Middle:SetPoint("LEFT", self.Right, "RIGHT");
		self.LeftDisabled:SetPoint("LEFT", self.MiddleDisabled, "RIGHT");
		self.Left:SetPoint("LEFT", self.Middle, "RIGHT");

		self.HighlightTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 0);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -7);
	end
end

function TabSystemButtonArtMixin:GetTextYOffset(isSelected)
	if self.isTabOnTop then
		return isSelected and 0 or -5;
	else
		return isSelected and -3 or 2;
	end
end

function TabSystemButtonArtMixin:SetTabSelected(isSelected)
	self.Left:SetShown(not isSelected);
	self.Middle:SetShown(not isSelected);
	self.Right:SetShown(not isSelected);
	self.LeftDisabled:SetShown(isSelected);
	self.MiddleDisabled:SetShown(isSelected);
	self.RightDisabled:SetShown(isSelected);

	self:SetEnabled(not isSelected);

	self.Text:SetPoint("CENTER", self, "CENTER", 0, self:GetTextYOffset(isSelected));

	local tooltip = GetAppropriateTooltip();
	if tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function TabSystemButtonArtMixin:SetTabWidth(width)
	local sidesWidth = self.Left:GetWidth() + self.Right:GetWidth();
	local middleWidth = width - sidesWidth;

	self.Middle:SetWidth(middleWidth);
	self.MiddleDisabled:SetWidth(middleWidth);
	self:SetWidth(width);
end

TabSystemButtonMixin = {};

function TabSystemButtonMixin:OnEnter()
	if self.Text:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -6);
		GameTooltip:SetText(self.Text:GetText());
	end
end

function TabSystemButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function TabSystemButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	self:GetTabSystem():SetTab(self:GetTabID());
end

function TabSystemButtonMixin:Init(tabID, tabText)
	self.tabID = tabID;
	self:HandleRotation();
	self.Text:SetText(tabText);
	self:UpdateTabWidth();
	self:SetTabSelected(false);
end

function TabSystemButtonMixin:UpdateTabWidth()
	local sidesWidth = self.Left:GetWidth() + self.Right:GetWidth();
	local textWidth = self.Text:GetWidth();
	local minTabWidth, maxTabWidth = self:GetTabSystem():GetTabWidthConstraints();
	local middleWidth = textWidth + TabSideExtraSpacing;

	if maxTabWidth then
		middleWidth = math.min(middleWidth, (maxTabWidth - TabSideExtraSpacing) - sidesWidth);
		self.Text:SetWidth(middleWidth);
	end

	if minTabWidth then
		middleWidth = math.max(middleWidth, minTabWidth - sidesWidth);
	end

	self:SetTabWidth(sidesWidth + middleWidth);
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

function TabSystemMixin:GetTabWidthConstraints()
	return self.minTabWidth, self.maxTabWidth;
end
