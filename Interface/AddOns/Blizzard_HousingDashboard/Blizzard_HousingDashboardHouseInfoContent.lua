
HousingDashboardHouseInfoMixin = {}

local HouseInfoLifetimeEvents =
{
	"PLAYER_HOUSE_LIST_UPDATED",
};

function HousingDashboardHouseInfoMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, HouseInfoLifetimeEvents);

	self:LoadHouses();

	self:UpdateNoHousesDashboard();

	self.HouseFinderButton:SetText(HOUSING_DASHBOARD_HOUSEFINDERBUTTON);
	self.HouseFinderButton:SetScript("OnClick", self.OnHouseFinderButtonClicked);
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
		self.LoadingSpinner:Hide();
		self:OnHouseListUpdated(houseInfoList);
	end
end

function HousingDashboardHouseInfoMixin:OnHouseListUpdated(houseInfoList)
	self.playerHouseList = houseInfoList;

	self.ContentFrame.HouseUpgradeFrame:OnHouseListUpdated(houseInfoList);

	if #houseInfoList > 0 then
		self.DashboardNoHousesFrame:Hide();
		self.HouseDropdown:Show();
		self.HouseFinderButton:Show();

		self.ContentFrame:Initialize();
		self:RefreshHouseDropdown(houseInfoList);
	else
		self.DashboardNoHousesFrame:Show();
		self.HouseDropdown:Hide();
		self.HouseFinderButton:Hide();
	end
end

function HousingDashboardHouseInfoMixin:RefreshHouseDropdown(houseInfoList)
	self.selectedHouseID = 1;

	local function OnHouseSelected(houseInfoID)
		--TODO: update endeavors
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
			self.selectedHouseID = houseInfoID;
			OnHouseSelected(houseInfoID);
		end;

		for houseInfoID = 1, #houseInfoList do
			local houseInfo = houseInfoList[houseInfoID];
			rootDescription:CreateRadio(houseInfo.houseName, IsSelected, SetSelected, houseInfoID);
		end
	end);
	OnHouseSelected(1);
end

function HousingDashboardHouseInfoMixin:OnHouseFinderButtonClicked()
	if not HouseFinderFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingHouseFinder");
	end
	ShowUIPanel(HouseFinderFrame);
	HideUIPanel(HousingDashboardFrame);

	PlaySound(SOUNDKIT.HOUSING_DASHBOARD_BUTTON_CLICK);
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
		self.endeavorTabID = self:AddNamedTab(HOUSING_DASHBOARD_ENDEAVOR, self.EndeavorFrame);
		self.tabsInitialized = true;
	end

	self:UpdateTabs();
end

function HousingDashboardHouseInfoContentFrameMixin:UpdateTabs()
	local houseUpgradeAvailable = self:IsTabAvailable(self.houseUpgradeTabID);
	local endeavorTabAvailable = self:IsTabAvailable(self.endeavorTabID);

	self.TabSystem:SetTabShown(self.houseUpgradeTabID, houseUpgradeAvailable);
	self.TabSystem:SetTabShown(self.endeavorTabID, endeavorTabAvailable);
	self.TabSystem:SetTabEnabled(self.endeavorTabID, false, HOUSING_ENDEAVORS_COMING_SOON);

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

---------------------this may be useful for the future------------------------
local moveOutTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
moveOutTimeFormatter:Init(
	60, --format with approximate under 1 minute ( < 1 minute )
	SecondsFormatter.Abbreviation.None,
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower);
moveOutTimeFormatter:SetMinInterval(SecondsFormatter.Interval.Minutes);
