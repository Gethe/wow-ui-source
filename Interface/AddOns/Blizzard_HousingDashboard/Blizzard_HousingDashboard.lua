HousingDashboardFrameMixin = {};

function HousingDashboardFrameMixin:OnLoad()
	self:SetPortraitAtlasRaw("housing-dashboard-homestone-icon");

	local function TabHandler(tab, button, upInside)
		if button == "LeftButton" and upInside then
			self:OnTabButtonClicked(tab);
		end
	end

	for i, frame in ipairs(self.TabButtons) do
		frame:SetCustomOnMouseUpHandler(TabHandler);
	end

	self.tabs = {};
	self.houseInfoTab = {
		tabButton = self.HouseInfoTabButton,
		contentFrame = self.HouseInfoContent,
		titleText = HOUSING_DASHBOARD_HOUSEINFO_FRAMETITLE,
	};
	table.insert(self.tabs, self.houseInfoTab);
	self.catalogTab = {
		tabButton = self.CatalogTabButton,
		contentFrame = self.CatalogContent,
		titleText = HOUSING_DASHBOARD_CATALOG_FRAMETITLE,
	};
	table.insert(self.tabs, self.catalogTab);

	self.activeTab = self.houseInfoTab;
	self.baseWidth = self:GetWidth();
	self.baseHeight = self:GetHeight();
end

function HousingDashboardFrameMixin:OnShow()
	EventRegistry:TriggerEvent("HousingDashboard.Toggled");
	PlaySound(SOUNDKIT.HOUSING_DASHBOARD_OPEN);

	self:SetTab(self.activeTab);
end

function HousingDashboardFrameMixin:OnHide()
	EventRegistry:TriggerEvent("HousingDashboard.Toggled");
	PlaySound(SOUNDKIT.HOUSING_DASHBOARD_CLOSE);
end

function HousingDashboardFrameMixin:OnTabButtonClicked(tabButton)
	for _, tab in ipairs(self.tabs) do
		if tab.tabButton == tabButton then
			self:SetTab(tab);
			return;
		end
	end
end

function HousingDashboardFrameMixin:SetTab(activeTab)
	self.activeTab = activeTab;
	local activeTabInfo = nil;
	for _, tab in ipairs(self.tabs) do
		local isActive = tab == activeTab;
		tab.tabButton:SetChecked(isActive);
		tab.contentFrame:SetShown(isActive);
		if isActive then
			activeTabInfo = tab;
			self:UpdateSizeToContent(tab.contentFrame);
		end
	end

	self:SetTitle(activeTabInfo and activeTabInfo.titleText or HOUSING_DASHBOARD_HOUSEINFO_FRAMETITLE);
end

function HousingDashboardFrameMixin:GetPanelExtraWidth()
	local frame = self.TabButtons[1];
	return frame:GetWidth();
end

function HousingDashboardFrameMixin:OpenInitiativesFrameToTaskID(taskID)
	self.HouseInfoContent.ContentFrame:SetTab(self.HouseInfoContent.ContentFrame.endeavorTabID)
	self.HouseInfoContent.ContentFrame.InitiativesFrame:ScrollToInitiativeTaskID(taskID);
end

function HousingDashboardFrameMixin:UpdateSizeToContent(contentFrame)
	if contentFrame.DashboardNoHousesFrame and contentFrame.DashboardNoHousesFrame:IsShown() then
		local noHousesDashWidth = 800;
		local noHousesDashHeight = 498;
		self:SetSize(noHousesDashWidth, noHousesDashHeight);
	else
		self:SetSize(self.baseWidth, self.baseHeight);
	end
end
