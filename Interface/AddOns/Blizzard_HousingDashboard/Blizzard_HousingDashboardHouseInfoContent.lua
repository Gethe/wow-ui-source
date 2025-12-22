HousingDashboardHouseInfoMixin = {}
local HouseInfoLifetimeEvents =
{
	"PLAYER_HOUSE_LIST_UPDATED",
	"NEIGHBORHOOD_INITIATIVE_UPDATED",
	"INITIATIVE_TASKS_TRACKED_UPDATED",
	"INITIATIVE_TASKS_TRACKED_LIST_CHANGED",
	"INITIATIVE_ACTIVITY_LOG_UPDATED",
};

local HOUSE_DROPDOWN_WIDTH = 200;
local HOUSE_DROPDOWN_MAX_HOUSES_SHOWN = 8;
local HOUSE_DROPDOWN_EXTENT = 20;
local SCROLL_BOX_EDGE_FADE_LENGTH = 30;

---------------------Dashboard Frame-------------------------------
local function GetPlayerHouseList()
	return HousingDashboardFrame.HouseInfoContent.playerHouseList;
end

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

		if self.ContentFrame:GetTab() == self.ContentFrame.endeavorTabID then
			C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo();
		end
		self.LoadingSpinner:Hide();
	elseif event == "NEIGHBORHOOD_INITIATIVE_UPDATED" or event == "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" then
		if self.ContentFrame:GetTab() == self.ContentFrame.endeavorTabID then
			self.ContentFrame.InitiativesFrame:RefreshInitiativeTab();
		end
	elseif event == "INITIATIVE_ACTIVITY_LOG_UPDATED" then
		if self.ContentFrame:GetTab() == self.ContentFrame.endeavorTabID then
			self.ContentFrame.InitiativesFrame:RefreshActivityLog();
		end
	elseif ( event == "INITIATIVE_TASKS_TRACKED_UPDATED" ) then
		if self.ContentFrame:GetTab() == self.ContentFrame.endeavorTabID then
			self.ContentFrame.InitiativesFrame:RefreshInitiativeTab();
			self.ContentFrame.InitiativesFrame:RefreshTrackedTasks();
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
	if not playerMeetsReqLevel then
		local reqLevel = C_NeighborhoodInitiative.GetRequiredLevel();
		self.TabSystem:SetTabEnabled(self.endeavorTabID, playerMeetsReqLevel, HOUSING_ENDEAVORS_MIN_LEVEL:format(reqLevel));
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
---------------------Initiatives Tab-------------------------------
InitiativesTabMixin = {};

function InitiativesTabMixin:OnLoad()
	self.thresholdFrames = {};
	self.thresholdMax = 0;

	self:SetupTaskList();
	self:SetupActivityLog();
end

function InitiativesTabMixin:OnShow()
	C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo();
end

function InitiativesTabMixin:OnHide()
	local spinner = self:GetParent():GetParent().LoadingSpinner;

	if spinner and spinner:IsShown() then
		spinner:Hide();
	end
	if self.targetValue then
		self:SetCurrentPoints(self.targetValue);
	end
end

function InitiativesTabMixin:OnHouseListUpdated(playerHouseList)
	self.playerHouseList = playerHouseList;
end

function InitiativesTabMixin:RefreshInitiativeTab()
	self.currentInitiative = C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo();
	self.isViewingActiveNeighborhood = C_NeighborhoodInitiative.IsViewingActiveNeighborhood();

	if self.currentInitiative then
		if self.currentInitiative.isLoaded then
			if self.currentInitiative.initiativeID ~= 0 then
				self:GetParent():GetParent().LoadingSpinner:Hide();
				self.NoInitiativeSetFrame:Hide();
				self.InitiativeSetFrame:Show();

				if self.isViewingActiveNeighborhood then
					self:RefreshTaskList();
					C_NeighborhoodInitiative.RequestInitiativeActivityLog();
					self.InitiativeSetFrame.InitiativeTasks:Show();
					self.InitiativeSetFrame.InitiativeActivity:Show();
					self.InitiativeSetFrame.InitiativeActiveNeighborhoodSwitcher:Hide();
				else
					self.InitiativeSetFrame.InitiativeTasks:Hide();
					self.InitiativeSetFrame.InitiativeActivity:Hide();
					self.InitiativeSetFrame.InitiativeActiveNeighborhoodSwitcher:Show();
				end

				self:SetProgressBarThresholds();

				self.InitiativeSetFrame.InitiativeName:SetText(self.currentInitiative.title);
				self.InitiativeSetFrame.InitiativeDescription:SetText(self.currentInitiative.description);

				local isInNeighborhoodGroup = C_NeighborhoodInitiative.IsPlayerInNeighborhoodGroup();

				if isInNeighborhoodGroup then
					self.InitiativeSetFrame.NeighborhoodGroupText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
					self.InitiativeSetFrame.NeighborhoodGroupText:SetText(BONUS_FAVOR_IN_NEIGHBORHOOD_PARTY);
				else
					self.InitiativeSetFrame.NeighborhoodGroupText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
					self.InitiativeSetFrame.NeighborhoodGroupText:SetText(BONUS_FAVOR_NOT_IN_NEIGHBORHOOD_PARTY);
				end

				if self.currentInitiative.duration and self.currentInitiative.duration > 0 then
					local timeLeftStr = SecondsToTime(self.currentInitiative.duration, false, true, 1); -- noSeconds, notAbbreviated, maxCount -> Show seconds, don't abbreviate units, only show one (largest) unit
					self.InitiativeSetFrame.InitiativeTimer.TimeRemaining:SetText(HOUSING_DASHBOARD_TIME_REMAINING:format(timeLeftStr));
					self.InitiativeSetFrame.InitiativeTimer:Show();
				else
					-- No duration, or the time is up, hide the timer.
					-- If there's no duration then we don't need one, if time is up we're probably picking a new one or waiting for the next cycle to start, so ignore the timer.
					self.InitiativeSetFrame.InitiativeTimer.TimeRemaining:SetText("");
					self.InitiativeSetFrame.InitiativeTimer:Hide();
				end
			else
				-- Loaded without a initiative ID, in choosing stage
				self.NoInitiativeSetFrame:Show();
				self.InitiativeSetFrame:Hide();
				self:GetParent():GetParent().LoadingSpinner:Hide();
			end
		else
			self.NoInitiativeSetFrame:Hide();
			self.InitiativeSetFrame:Hide();
			self:GetParent():GetParent().LoadingSpinner:Show();
		end
	else
		-- without a initiative ID, in choosing stage
		self.NoInitiativeSetFrame:Show();
		self.InitiativeSetFrame:Hide();
	end

	local lastPoints = GetCVarNumberOrDefault("endeavorInitiativesLastPoints");
	self:SetCurrentPoints(lastPoints);
	if self.currentInitiative.currentProgress ~= lastPoints then
		self.targetValue = self.currentInitiative.currentProgress;
	end
end

function InitiativesTabMixin:RefreshTrackedTasks()
	local initiativeTasksTracked = C_NeighborhoodInitiative.GetTrackedInitiativeTasks();
	local trackedTaskIDs = initiativeTasksTracked.trackedIDs;
	local excludeCollapsed = false;
	local dataProvider = self.InitiativeSetFrame.InitiativeTasks.TaskList:GetDataProvider();
	if davaProvider then
		dataProvider:ForEach(function(elementData)
		local data = elementData:GetData();
		data.tracked = tContains(trackedTaskIDs, data.ID);
			end, excludeCollapsed);
		self.InitiativeSetFrame.InitiativeTasks.TaskList:ForEachFrame(function(frame, elementData)
			frame:UpdateTracked();
		end);
	end
end

function InitiativesTabMixin:SetProgressBarThresholds()
	local maxNumRewards = self.currentInitiative.milestones and #self.currentInitiative.milestones or 1;
	local maxProgressValue = self.currentInitiative.milestones and self.currentInitiative.milestones[maxNumRewards].requiredContributionAmount or 1;

	self.InitiativeSetFrame.ProgressBar:SetMinMaxValues(0, maxProgressValue);
	self.InitiativeSetFrame.ProgressBar:SetValue(self.currentInitiative.currentProgress);
	self.thresholdMax = maxProgressValue;


	if self.InitiativeSetFrame.ProgressBar:GetValue() > 0 then
		self.InitiativeSetFrame.ProgressBar.BarEnd:Show();
		self.InitiativeSetFrame.ProgressBar.BarEnd:SetPoint("LEFT", self.InitiativeSetFrame.ProgressBar.BarFill, "LEFT", 0, 0);
		self.InitiativeSetFrame.ProgressBar.BarEnd:SetPoint("RIGHT", self.InitiativeSetFrame.ProgressBar.BarFill, "RIGHT", 0, 0);
	else
		self.InitiativeSetFrame.ProgressBar.BarEnd:Hide();
		self.InitiativeSetFrame.ProgressBar.BarEnd:ClearAllPoints();
	end

	local currentThreshold = 1;
	for i, thresholdInfo in pairs(self.currentInitiative.milestones) do
		local thresholdName = "Threshold" .. currentThreshold;
		local thresholdFrame = self.InitiativeSetFrame.ProgressBar[thresholdName];

		local template = "ProgressThresholdTemplate";
		if i == maxNumRewards then
			template = "ProgressThresholdLargeTemplate";
		end

		if not thresholdFrame then
			thresholdFrame = CreateFrame("Frame", nil, self.InitiativeSetFrame.ProgressBar, template);
			self.InitiativeSetFrame.ProgressBar[thresholdName] = thresholdFrame;
			table.insert(self.thresholdFrames, thresholdFrame);
		end

		local xOffset = i * self.InitiativeSetFrame.ProgressBar:GetWidth() / maxNumRewards;

		if i < maxNumRewards then
			thresholdFrame:SetPoint("CENTER", self.InitiativeSetFrame.ProgressBar, "BOTTOMLEFT", xOffset, 0);
		elseif i == maxNumRewards then
			thresholdFrame:SetPoint("CENTER", self.InitiativeSetFrame.ProgressBar, "BOTTOMRIGHT", 20, 9);
		end

		local isFinalReward = template == "ProgressThresholdLargeTemplate";
		thresholdFrame:Setup(thresholdInfo, self.currentInitiative.currentProgress or 0, isFinalReward);
		currentThreshold = currentThreshold + 1;
	end
end

function InitiativesTabMixin:UpdateBackground(selectedHouseInfo)
	if selectedHouseInfo and selectedHouseInfo.neighborhoodGUID then
		local atlas = "housing-dashboard-bg-" .. C_Housing.GetNeighborhoodTextureSuffix(selectedHouseInfo.neighborhoodGUID);
		self.InitiativesArt.InitiativesBG:SetAtlas(atlas);
	end
end

function InitiativesTabMixin:RefreshHouseDropdown()
	--TODO: remove this.
end

function InitiativesTabMixin:OnHouseSelected(houseInfoID)
	if not self.playerHouseList then
		self:RefreshHouseDropdown();
	end
	local neighborhoodGUID = self.playerHouseList[houseInfoID].neighborhoodGUID;
	C_NeighborhoodInitiative.SetViewingNeighborhood(neighborhoodGUID);
	self:UpdateBackground(self.playerHouseList[houseInfoID]);
	C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo();
end

function InitiativesTabMixin:SetupTaskList()
	local indent = 15;
	local defaultPadding = 0;
	local topPadding = 30;
	local bottomPadding = 20;
	local elementSpacing = 5;
	local view = CreateScrollBoxListTreeListView(indent, topPadding, bottomPadding, defaultPadding, defaultPadding, elementSpacing);

	view:SetElementFactory(function(factory, node)
		local data = node:GetData();

		local function TaskInitializer(button)
			if data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite then
				button.CollapseIcon:Hide();
				button.CollapseIconAlphaAdd:Hide();
			elseif data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableFinite then
				if data.topLevel then
					button.CollapseIcon:Show();
					button.CollapseIconAlphaAdd:Show();
					button:SetCollapseState(node:IsCollapsed());
				else
					button.CollapseIcon:Hide();
					button.CollapseIconAlphaAdd:Hide();
				end
			else
				button.CollapseIcon:Hide();
				button.CollapseIconAlphaAdd:Hide();
			end

			if data.timesCompleted and data.timesCompleted > 0 and data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite then
				button.Title:SetText(HOUSING_DASHBOARD_REPEATABLE_TASK_TITLE_FORMAT:format(data.taskName, data.timesCompleted));
			else
				button.Title:SetText(data.taskName);
			end

			-- TODO: fix supercede (repeatableFinite) 
			if data.completed and data.taskType ~= Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite then
				button.ActivityXP:Hide();
				button.Checkmark:Show();
				button.BGAlphaAdd:Show();
			else
				button.ActivityXP:SetText(data.progressContributionAmount);
				button.ActivityXP:Show();
				button.Checkmark:Hide();
				button.BGAlphaAdd:Hide();
			end

			button:UpdateTracked();
		end

		local function SubtaskInitializer(button)
			button.Title:SetText(data.taskName);
			button.ActivityXP:SetText(data.progressContributionAmount);
		end

		if not data.isSubtask then
			factory("HousingDashboard_InitiativeTaskTemplate", TaskInitializer);
		else
			factory("HousingDashboard_InitiativeSubtaskTemplate", SubtaskInitializer);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.InitiativeSetFrame.InitiativeTasks.TaskList, self.InitiativeSetFrame.InitiativeTasks.ScrollBar, view);
end

function InitiativesTabMixin:SetupActivityLog()
	local topPadding = 35;
	local view = CreateScrollBoxListLinearView(topPadding);

	view:SetElementFactory(function(factory, data)
		local function Initializer(frame)
			frame.ActivityMessage:SetText(HOUSING_DASHBOARD_ACTIVITY_LOG_ENTRY:format(data.playerName, data.taskName));
		end

		factory("HousingDashboard_InitiativeTaskActivityEntryTemplate", Initializer);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.InitiativeSetFrame.InitiativeActivity.ActivityLog, self.InitiativeSetFrame.InitiativeActivity.ScrollBar, view);
end

function InitiativesTabMixin:RefreshTaskList()
	local taskList = {};
	local dataProvider = CreateTreeDataProvider();

	-- Task list from data is flat, traverse and build the task tree for the UI
	for idx, task in ipairs(self.currentInitiative.tasks) do
		if not task.supersedes or task.supersedes == 0 then
			-- toplevel task
			task.children = {};
			taskList[task.ID] = task;
		else
			-- child task
			if taskList[task.supersedes] then
				-- First child, insert into parent's children list if parent incomplete, otherwise make it the new parent
				if taskList[task.supersedes].completed then
					task.children = {};
					taskList[task.ID] = task;
				else
					tinsert(taskList[task.supersedes].children, task);
				end
			else
				-- Nth child, gotta find the parent then insert into children list
				for _, parent in pairs(taskList) do
					if #parent.children > 0 then
						for _, child in pairs(parent.children) do
							if task.supersedes == child.ID then
								tinsert(parent.children, task);
							end
						end
					end
				end
			end
		end
	end

	-- Now insert data into provider with our tree
	for _, task in pairs(taskList) do
		if #task.children > 0 then
			local topLevelTaskData = { ID = task.ID, taskType = Enum.NeighborhoodInitiativeTaskType.RepeatableFinite, taskName = task.taskName, description = task.description, progressContributionAmount = task.progressContributionAmount, topLevel = true, sortOrder = task.sortOrder, completed = task.completed, requirementsList = task.requirementsList, tracked = task.tracked, hasChild = true};
			local topLevelTask = dataProvider:Insert(topLevelTaskData);
			for _, child in pairs(task.children) do
				child.isSubtask = true;
				topLevelTask:Insert(child);
			end
		else
			dataProvider:Insert(task);
		end
	end

	dataProvider:SetSortComparator(function(a, b)
		local aData = a.data;
		local bData = b.data;

		-- if one of them is complete, return the incomplete first, else use sort order
		if aData.completed ~= bData.completed then
			return not aData.completed;
		end
		if aData.sortOrder and bData.sortOrder then
			if aData.sortOrder < bData.sortOrder then
				return true;
			elseif aData.sortOrder > bData.sortOrder then
				return false;
			end
		end
	end);
	dataProvider:Sort();

	dataProvider:CollapseAll();
	self.InitiativeSetFrame.InitiativeTasks.TaskList:SetEdgeFadeLength(SCROLL_BOX_EDGE_FADE_LENGTH);
	self.InitiativeSetFrame.InitiativeTasks.TaskList:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function InitiativesTabMixin:RefreshActivityLog()
	if not self.isViewingActiveNeighborhood then
		self.InitiativeSetFrame.InitiativeActivity:Hide();
		return;
	end

	self.InitiativeSetFrame.InitiativeActivity:Show();
	self.initiativeActivityLog = C_NeighborhoodInitiative.GetInitiativeActivityLogInfo();

	if self.initiativeActivityLog and self.initiativeActivityLog.taskActivity then
		local dataProvider = CreateDataProvider();

		for _, activity in ipairs(self.initiativeActivityLog.taskActivity) do
			dataProvider:Insert(activity);
		end

		self.InitiativeSetFrame.InitiativeActivity.ActivityLog:SetEdgeFadeLength(SCROLL_BOX_EDGE_FADE_LENGTH);
		self.InitiativeSetFrame.InitiativeActivity.ActivityLog:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
		self.InitiativeSetFrame.InitiativeActivity.NoActivityText:SetShown(#self.initiativeActivityLog.taskActivity == 0);
	end
end

function InitiativesTabMixin:ScrollToInitiativeTaskID(taskID)
	local scrollBox = self.InitiativeSetFrame.InitiativeTasks.TaskList;
	local function FindNode(ID)
		local dataProvider = scrollBox:GetDataProvider();
		if dataProvider then
			return dataProvider:FindElementDataByPredicate(function(node)
				local data = node:GetData();
				return data.ID == ID;
			end, TreeDataProviderConstants.IncludeCollapsed);
		end
	end
	local selectedNode = FindNode(taskID);
	if selectedNode then
		scrollBox:ScrollToElementData(selectedNode, ScrollBoxConstants.AlignCenter);
	end
end

function InitiativesTabMixin:OnUpdate()
	if not self.targetValue then
		return;
	end

	local curValue = self.InitiativeSetFrame.ProgressBar:GetValue();
	local barValue = math.min(curValue + math.floor(self.thresholdMax * 0.005), self.targetValue);
	if barValue >= self.targetValue then
		if self.loopSoundHandle then
			StopSound(self.loopSoundHandle);
			self.loopSoundHandle = nil;
		end
		PlaySound(SOUNDKIT.HOUSING_ENDEAVORS_REWARD_BAR_STOP);
		self.InitiativeSetFrame.ProgressBar.BarEnd.Sparkles:Play();
	else
		if not self.loopSoundHandle then
			local _, soundHandle = PlaySound(SOUNDKIT.HOUSING_ENDEAVORS_REWARD_BAR_LOOP);
			self.loopSoundHandle = soundHandle;
		end
	end

	self:SetCurrentPoints(barValue);
end

function InitiativesTabMixin:SetCurrentPoints(barValue)
	self.InitiativeSetFrame.ProgressBar:SetValue(barValue);

	for _, thresholdFrame in pairs(self.thresholdFrames) do
		thresholdFrame:SetCurrentPoints(barValue);
	end

	self.InitiativeSetFrame.ProgressBar.TextContainer.ProgressText:SetFormattedText(ENDEAVOR_INITIATIVES_PROGRESS_TEXT, barValue, self.thresholdMax);
	self.InitiativeSetFrame.ProgressBar.BarEnd:SetShown(barValue > 0);

	if self.targetValue and barValue >= self.targetValue then
		SetCVar("endeavorInitiativesLastPoints", self.targetValue);
		self.targetValue = nil;
	end
end

---------------------Initiatives Tab: Task Button-------------------------------
InitiativeTaskButtonMixin = {};

function InitiativeTaskButtonMixin:Init()
	self:GetElementData():SetCollapsed(true);
end

function InitiativeTaskButtonMixin:SetCollapseState(isCollapsed)
	local atlas = isCollapsed and "ui-questtrackerbutton-expand-all" or "UI-QuestTrackerButton-Collapse-All";
	self.CollapseIcon:SetAtlas(atlas);
	self.CollapseIconAlphaAdd:SetAtlas(atlas);
end

function InitiativeTaskButtonMixin:UpdateTracked()
	local data = self:GetData();
	self.TrackingCheckmark:SetShown(data and data.tracked);
end

function InitiativeTaskButtonMixin:OnEnter()
	local data = self:GetData();
	if not data then
		return;
	end

	if data.requirementsList then
		self.showingTooltip = true;
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		self:ShowTooltip();
	end
end

-- Returns true if this method acted on the click
-- This may be needed since if the internal method handles the click in a way which leads to the button being released back to the pool then we won't want to continue after
function InitiativeTaskButtonMixin:OnClick_Internal(button)
	local data = self:GetData();
	if not data then
		return false;
	end

	if ( IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() ) then
		local initiativeTaskLink = C_NeighborhoodInitiative.GetInitiativeTaskChatLink(data.ID);
		ChatFrameUtil.InsertLink(initiativeTaskLink);
		return true;
	end

	if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
		if data.tracked then
			C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(data.ID);
		else
			C_NeighborhoodInitiative.AddTrackedInitiativeTask(data.ID);
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		return true;
	end

	if button == "RightButton" and not data.completed then
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("ENDEAVORS_TASK_BTN_TRACKER_MENU");

			rootDescription:CreateButton(data.tracked and HOUSING_DASHBOARD_UNTRACK_ENDEAVOR_LABEL or HOUSING_DASHBOARD_TRACK_ENDEAVOR_LABEL, function()
				if data.tracked then
					C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(data.ID);
				else
					C_NeighborhoodInitiative.AddTrackedInitiativeTask(data.ID);
				end
			end);
		end);
		return true;
	end

	return false;
end

function InitiativeTaskButtonMixin:OnClick(button)
	if self:OnClick_Internal(button) then
		return;
	end

	local data = self:GetData();
	if data and data.hasChild then
		local node = self:GetElementData();
		if data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableFinite then
			node:ToggleCollapsed();
			self:SetCollapseState(node:IsCollapsed());
		end
	end
end

function InitiativeTaskButtonMixin:ShowTooltip()
	local data = self:GetData();
	if not data then
		return;
	end

	if data.timesCompleted and data.timesCompleted > 0 and data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite then
		GameTooltip_SetTitle(GameTooltip, HOUSING_DASHBOARD_REPEATABLE_TASK_TITLE_TOOLTIP_FORMAT:format(data.taskName, data.timesCompleted), NORMAL_FONT_COLOR);
	else
		GameTooltip_SetTitle(GameTooltip, data.taskName, NORMAL_FONT_COLOR);
	end

	if data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite then
		GameTooltip_AddNormalLine(GameTooltip, HOUSING_ENDEAVOR_REPEATABLE_TASK)
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	if #data.description > 0 then
		GameTooltip_AddHighlightLine(GameTooltip, data.description)
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end

	for _, requirement in ipairs(data.requirementsList) do
		local tooltipLine = requirement.requirementText;
		tooltipLine = string.gsub(tooltipLine, " / ", "/");
		local color = not requirement.completed and WHITE_FONT_COLOR or DISABLED_FONT_COLOR;
		GameTooltip_AddColoredLine(GameTooltip, tooltipLine, color);
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	local rewardQuestID = data.rewardQuestID;
	if rewardQuestID then
		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, data.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_INITIATIVE_TASK);
	end

	if data.tracked and not data.completed then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddInstructionLine(GameTooltip, MONTHLY_ACTIVITIES_UNTRACK);
	elseif not data.completed then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddInstructionLine(GameTooltip, MONTHLY_ACTIVITIES_TRACK);
	end

	EventRegistry:TriggerEvent("HousingDashboardInitiativeTask.MouseOver", data);

	GameTooltip:Show();
end

function InitiativeTaskButtonMixin:GetData()
	local node = self:GetElementData();
	if not node then
		return nil;
	end
	return node:GetData();
end

---------------------Initiatives Tab: ProgressBar Threshold-------------------------------
ProgressThresholdMixin = {};

function ProgressThresholdMixin:Setup(thresholdInfo, currentThresholdProgress, isFinalReward)
	self.Reward.name = thresholdInfo.rewards[1].title;
	self.Reward.description = thresholdInfo.rewards[1].description;

	local rewardQuestID = thresholdInfo.rewards[1].rewardQuestID;
	if ( rewardQuestID > 0 ) then
		local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(rewardQuestID, 1, false);
		if ( currencyInfo and currencyInfo.texture ) then
			self.Reward.Icon:SetTexture(currencyInfo.texture);
		end
	end

	self.thresholdInfo = thresholdInfo
	self.isFinalReward = isFinalReward
	self.Reward.EarnedCheckmark:SetAlpha(1);
	self.Reward.CheckmarkFlipbook:SetAlpha(0);
end

function ProgressThresholdMixin:SetCurrentPoints(points)

	local aboveThreshold = points >= self.thresholdInfo.requiredContributionAmount;

	if not self.isFinalReward then
		self.LineIncomplete:SetShown(not aboveThreshold);
		self.LineComplete:SetShown(aboveThreshold);
		if not aboveThreshold then
			self.Reward.IconBorder:SetAtlas("housing-dashboard-fillbar-pip-incomplete");
		else
			self.Reward.IconBorder:SetAtlas("housing-dashboard-fillbar-pip-complete");
		end
	end

	local initialSet = self.aboveThreshold == nil;
	if self.aboveThreshold == aboveThreshold then
		return;
	end

	self.aboveThreshold = aboveThreshold;

	if not initialSet and aboveThreshold then
		self.Reward.ThresholdReached:Play();
		if not self.isFinalReward then
			PlaySound(SOUNDKIT.HOUSING_ENDEAVORS_REWARD_TIER_COMPLETE);
		else
			PlaySound(SOUNDKIT.HOUSING_ENDEAVORS_REWARD_BAR_COMPLETE);
		end
	end
	self.Reward.EarnedCheckmark:SetShown(aboveThreshold);
end

---------------------Initiatives Tab: Active Neighborhood Switcher -------------------------------
InitiativeActiveNeighborhoodSwitcherMixin = {};

function InitiativeActiveNeighborhoodSwitcherMixin:OnClick()

	local houseList = GetPlayerHouseList();
	local selectedHouseID = HousingDashboardFrame.HouseInfoContent.selectedHouseID;
	local houseInfo = houseList and houseList[selectedHouseID] or nil;
	local neighborhoodGUID = houseInfo and houseInfo.neighborhoodGUID or nil;

	if neighborhoodGUID then
		C_NeighborhoodInitiative.SetActiveNeighborhood(neighborhoodGUID);
	end
end
