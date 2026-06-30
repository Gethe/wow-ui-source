HousingDashboardHouseInfoMixin = {}
local HouseInfoLifetimeEvents =
{
	"PLAYER_HOUSE_LIST_UPDATED",
	"PLAYER_LEVEL_CHANGED",
};

local HOUSE_DROPDOWN_WIDTH = 200;
local HOUSE_DROPDOWN_MAX_HOUSES_SHOWN = 8;
local HOUSE_DROPDOWN_EXTENT = 20;

function HousingDashboardHouseInfoMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, HouseInfoLifetimeEvents);

	self:UpdateNoHousesDashboard();

	self.HouseFinderButton:SetTextToFit(HOUSING_DASHBOARD_HOUSEFINDERBUTTON);
	self.HouseFinderButton:SetScript("OnClick", self.OnHouseFinderButtonClicked);
end

function HousingDashboardHouseInfoMixin:OnShow()
	self:LoadHouses();
end

function HousingDashboardHouseInfoMixin:UpdateNoHousesDashboard()
	local backgroundAtlas = "housing-dashboard-bg-empty";

	local noHouseButtonText = HOUSING_DASHBOARD_HOUSEFINDERBUTTON;
	local noHouseButtonScript = self.OnHouseFinderButtonClicked;
	local noHouseButtonAnchor = {point = "TOP", parent = self.DashboardNoHousesFrame.TitleText, relativePoint = "BOTTOM", xOffset = 0, yOffset = -24};
	local noHouseButtonShown = true;

	local titleText = HOUSING_DASHBOARD_NO_HOUSE_TEXT;
	local titleMaxLines = 0;
	local titleFont = "Game15Font_Shadow";
	local titleAnchor = { point = "CENTER", parent = self, relativePoint = "CENTER", xOffset = 0, yOffset = 34 };
	local titleJustifyH = "CENTER";

	local subtitleShown = false;
	local subtitleAnchor = { point = "LEFT", parent = self, relativePoint = "LEFT", xOffset = 53, yOffset = 0 };
	local subtitleText = HOUSING_DASHBOARD_START_TUTORIAL_DESCRIPTION_TEXT;

	local textMaxWidth = 540;

	if (C_Housing.HasHousingExpansionAccess() == false) then
		noHouseButtonShown = false;
		titleText = HOUSING_DASHBOARD_NO_EXPANSION_TEXT;
		titleAnchor = { point = "CENTER", parent = self, relativePoint = "CENTER", xOffset = 0, yOffset = 0 };
	-- Using quest bits here since account cvars don't scope BNet account
	elseif not HousingTutorialUtil.BoughtHouseQuestComplete() then
		backgroundAtlas = "housing-dashboard-bg-welcome";
		noHouseButtonText = HOUSING_DASHBOARD_START_TUTORIAL_BUTTON_TEXT;
		noHouseButtonScript = self.OnTutorialButtonClicked;
		noHouseButtonAnchor = { point = "TOPLEFT", parent = self.DashboardNoHousesFrame.SubtitleText, relativePoint = "BOTTOMLEFT", xOffset = 0, yOffset = -24 };
		titleText = HOUSING_DASHBOARD_START_TUTORIAL_TEXT;
		titleMaxLines = 2;
		titleFont = "GameFontHighlightHuge2";
		titleAnchor = { point = "BOTTOMLEFT", parent = self.DashboardNoHousesFrame.SubtitleText, relativePoint = "TOPLEFT", xOffset = 0, yOffset = 16 };
		titleJustifyH = "LEFT";
		subtitleShown = true;
		subtitleText = HOUSING_DASHBOARD_START_TUTORIAL_DESCRIPTION_TEXT;
		textMaxWidth = 320;
	end

	local noHousesFrame = self.DashboardNoHousesFrame;
	noHousesFrame.TitleText:ClearAllPoints();
	noHousesFrame.SubtitleText:ClearAllPoints();

	noHousesFrame.Background:SetAtlas(backgroundAtlas, TextureKitConstants.UseAtlasSize);

	noHousesFrame.NoHouseButton:SetText(noHouseButtonText);
	noHousesFrame.NoHouseButton:SetScript("OnClick", function() noHouseButtonScript(self) end);
	noHousesFrame.NoHouseButton:ClearAllPoints();
	noHousesFrame.NoHouseButton:SetPoint(noHouseButtonAnchor.point, noHouseButtonAnchor.parent, noHouseButtonAnchor.relativePoint, noHouseButtonAnchor.xOffset, noHouseButtonAnchor.yOffset);
	noHousesFrame.NoHouseButton:SetShown(noHouseButtonShown);

	noHousesFrame.TitleText:SetText(titleText);
	noHousesFrame.TitleText:SetMaxLines(titleMaxLines);
	noHousesFrame.TitleText:SetFontObject(titleFont);
	noHousesFrame.TitleText:SetPoint(titleAnchor.point, titleAnchor.parent, titleAnchor.relativePoint, titleAnchor.xOffset, titleAnchor.yOffset);
	noHousesFrame.TitleText:SetJustifyH(titleJustifyH);
	noHousesFrame.TitleText:SetWidth(textMaxWidth);

	noHousesFrame.SubtitleText:SetShown(subtitleShown);
	noHousesFrame.SubtitleText:SetPoint(subtitleAnchor.point, subtitleAnchor.parent, subtitleAnchor.relativePoint, subtitleAnchor.xOffset, subtitleAnchor.yOffset);
	noHousesFrame.SubtitleText:SetText(subtitleText);
	noHousesFrame.SubtitleText:SetWidth(textMaxWidth);
end

function HousingDashboardHouseInfoMixin:LoadHouses()
	self.LoadingSpinner:Show();
	C_Housing.GetPlayerOwnedHouses();
end

function HousingDashboardHouseInfoMixin:OnEvent(event, ...)
	if event == "PLAYER_HOUSE_LIST_UPDATED" then
		local houseInfoList = ...;
		self:OnHouseListUpdated(houseInfoList);

		C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo();
		self.LoadingSpinner:Hide();
	elseif event == "PLAYER_LEVEL_CHANGED" then
		if self.tabsInitialized then
			self.ContentFrame:UpdateTabs();
		end
	end
end

function HousingDashboardHouseInfoMixin:OnHouseListUpdated(houseInfoList)
	-- Don't bother thrashing everything if nothing in the list has changed
	-- Which is likely since we re-request this list on every OnShow
	if self.playerHouseList and tCompare(self.playerHouseList, houseInfoList, 2) then
		return;
	end

	self.playerHouseList = houseInfoList;

	self.ContentFrame.InitiativesFrame:OnHouseListUpdated(houseInfoList)
	self.ContentFrame.HouseUpgradeFrame:OnHouseListUpdated(houseInfoList);

	if #houseInfoList > 0 then
		self.DashboardNoHousesFrame:Hide();
		self.HouseDropdown:Show();
		self.HouseFinderButton:Show();
		self.ContentFrame:Initialize();
		self.ContentFrame:Show();
		self:RefreshHouseDropdown(houseInfoList);
	else
		self.DashboardNoHousesFrame:Show();
		self.HouseDropdown:Hide();
		self.HouseFinderButton:Hide();
		self.ContentFrame:Hide();
	end

	self:GetParent():UpdateSizeToContent(self);
end

function HousingDashboardHouseInfoMixin:RefreshHouseDropdown(houseInfoList)
	local oldSelectedHouseID = self.selectedHouseID;
	local oldSelectedHouseInfo = self.selectedHouseInfo;
	self.selectedHouseID = nil;
	self.selectedHouseInfo = nil;

	if oldSelectedHouseID and oldSelectedHouseInfo then
		local newSelectedHouseInfo = houseInfoList[oldSelectedHouseID];
		-- If we had something previously selected, and it still exists in the updated list, maintain that selection
		if newSelectedHouseInfo and oldSelectedHouseInfo.houseGUID == newSelectedHouseInfo.houseGUID then
			self.selectedHouseID = oldSelectedHouseID;
		end
	end

	if not self.selectedHouseID then
		-- If we don't have a previous selection, check if we're in a neighborhood and default to a house that belongs there.
		local currentNeighborhoodGUID = C_Housing.GetCurrentNeighborhoodGUID();
		if currentNeighborhoodGUID then
			for houseInfoIndex, houseInfo in ipairs(houseInfoList) do
				if houseInfo.neighborhoodGUID == currentNeighborhoodGUID then
					self.selectedHouseID = houseInfoIndex;
					break;
				end
			end
		end
	end

	if not self.selectedHouseID then
		-- If we still don't have a selection, then default to a house in your active neighborhood
		local activeNeighborhoodGUID = C_NeighborhoodInitiative.GetActiveNeighborhood();
		if activeNeighborhoodGUID then
			for houseInfoIndex, houseInfo in ipairs(houseInfoList) do
				if houseInfo.neighborhoodGUID == activeNeighborhoodGUID then
					self.selectedHouseID = houseInfoIndex;
					break;
				end
			end
		end
	end

	-- Fallback to just using the first one in the list
	if not self.selectedHouseID then
		self.selectedHouseID = 1;
	end

	local function OnHouseSelected(houseInfoID)
		self.ContentFrame.InitiativesFrame:OnHouseSelected(houseInfoID);
		self.selectedHouseID = houseInfoID;
		self.selectedHouseInfo = self.playerHouseList[houseInfoID];
		self.ContentFrame.HouseUpgradeFrame:OnHouseSelected(houseInfoID);
	end

	self.HouseDropdown:SetupMenu(function(dropdown, rootDescription)
		local extent = 20;
		local maxHousesShown = 8;
		local maxScrollExtent = extent * maxHousesShown;
		rootDescription:SetScrollMode(maxScrollExtent);

		local function IsSelected(houseInfoID)
			return houseInfoID == self.selectedHouseID;
		end;

		local function SetSelected(houseInfoID)
			OnHouseSelected(houseInfoID);
		end;

		for houseInfoIndex, houseInfo in ipairs(houseInfoList) do
			rootDescription:CreateRadio(houseInfo.houseName, IsSelected, SetSelected, houseInfoIndex);
		end
	end);

	OnHouseSelected(self.selectedHouseID);
end

function HousingDashboardHouseInfoMixin:OnHouseFinderButtonClicked()
	if not HouseFinderFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingHouseFinder");
	end
	ShowUIPanel(HouseFinderFrame);
	HideUIPanel(HousingDashboardFrame);

	PlaySound(SOUNDKIT.HOUSING_DASHBOARD_HOUSEFINDER_CLICK);
end

function HousingDashboardHouseInfoMixin:OnTutorialButtonClicked()
	C_Housing.StartTutorial();

	PlaySound(SOUNDKIT.HOUSING_DASHBOARD_BUTTON_CLICK);
end

HousingDashboardHouseInfoContentFrameMixin = {};

function HousingDashboardHouseInfoContentFrameMixin:Initialize()
	if not self.tabsInitialized then
		TabSystemOwnerMixin.OnLoad(self);
		self:SetTabSystem(self.TabSystem);
		self.houseUpgradeTabID = self:AddNamedTab(HOUSING_DASHBOARD_HOUSEUPGRADE, self.HouseUpgradeFrame);
		self.endeavorTabID = self:AddNamedTab(HOUSING_DASHBOARD_ENDEAVOR, self.InitiativesFrame);
		self.tabsInitialized = true;
	end

	self:UpdateTabs();
end

function HousingDashboardHouseInfoContentFrameMixin:UpdateTabs()
	local houseUpgradeAvailable = self:IsTabAvailable(self.houseUpgradeTabID);
	local endeavorTabAvailable = self:IsTabAvailable(self.endeavorTabID);

	self.TabSystem:SetTabShown(self.houseUpgradeTabID, houseUpgradeAvailable);
	self.TabSystem:SetTabShown(self.endeavorTabID, endeavorTabAvailable);
	self.TabSystem:SetTabEnabled(self.endeavorTabID, C_NeighborhoodInitiative.IsInitiativeEnabled(), HOUSING_ENDEAVORS_DISABLED);

	local playerMeetsReqLevel = C_NeighborhoodInitiative.PlayerMeetsRequiredLevel();
	local playerHasInitiativeAccess = C_NeighborhoodInitiative.PlayerHasInitiativeAccess();
	if not playerMeetsReqLevel then
		local reqLevel = C_NeighborhoodInitiative.GetRequiredLevel();
		self.TabSystem:SetTabEnabled(self.endeavorTabID, playerMeetsReqLevel, HOUSING_ENDEAVORS_MIN_LEVEL:format(reqLevel));
	elseif not playerHasInitiativeAccess then
		self.TabSystem:SetTabEnabled(self.endeavorTabID, playerHasInitiativeAccess, HOUSING_ENDEAVORS_DISABLED);
	end

	local currentTab = self:GetTab();
	if not currentTab or not self:IsTabAvailable(currentTab) then
		self:SetToDefaultAvailableTab();
	end
end

function HousingDashboardHouseInfoContentFrameMixin:SetToDefaultAvailableTab()
	if self:IsTabAvailable(self.houseUpgradeTabID) then
		self:SetTab(self.houseUpgradeTabID);
	end
end

function HousingDashboardHouseInfoContentFrameMixin:SetTab(tabID)
	TabSystemOwnerMixin.SetTab(self, tabID);
end

function HousingDashboardHouseInfoContentFrameMixin:IsTabAvailable(tabID)
	return true;
end

---------------------House Finder-------------------------------
HouseFinderButtonMixin = {};

function HouseFinderButtonMixin:OnClick()
	if not HouseFinderFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingHouseFinder");
	end
	ShowUIPanel(HouseFinderFrame);
	HideUIPanel(HousingDashboardFrame);
	
	PlaySound(SOUNDKIT.HOUSING_DASHBOARD_BUTTON_CLICK);
end
