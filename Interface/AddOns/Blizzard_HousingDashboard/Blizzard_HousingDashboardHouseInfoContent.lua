HousingDashboardHouseInfoMixin = {}
local HouseInfoLifetimeEvents =
{
	"PLAYER_HOUSE_LIST_UPDATED",
	"NEIGHBORHOOD_INITIATIVE_UPDATED",
	"INITIATIVE_TASK_COMPLETED",
	"INITIATIVE_TASKS_TRACKED_UPDATED",
	"INITIATIVE_TASKS_TRACKED_LIST_CHANGED",
	--"INITIATIVE_ACTIVITY_LOG_UPDATED", --! Task history / activity still WIP
};

local HOUSE_DROPDOWN_WIDTH = 200;
local HOUSE_DROPDOWN_MAX_HOUSES_SHOWN = 8;
local HOUSE_DROPDOWN_EXTENT = 20;
local SCROLL_BOX_EDGE_FADE_LENGTH = 50;

---------------------Dashboard Frame-------------------------------
local function GetPlayerHouseList()
	return HousingDashboardFrame.HouseInfoContent.playerHouseList;
end

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
		self:OnHouseListUpdated(houseInfoList);

		if self.ContentFrame:GetTab() == self.ContentFrame.endeavorTabID then
			C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo();
		end
		self.LoadingSpinner:Hide();
	elseif event == "NEIGHBORHOOD_INITIATIVE_UPDATED" or event == "INITIATIVE_ACTIVITY_LOG_UPDATED" or event == "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" then
		-- TODO: should separate out activity log from initiative
		if self.ContentFrame:GetTab() == self.ContentFrame.endeavorTabID then
			self.ContentFrame.InitiativesFrame:RefreshInitiativeTab();
		end
	elseif ( event == "INITIATIVE_TASKS_TRACKED_UPDATED" ) then
		if self.ContentFrame:GetTab() == self.ContentFrame.endeavorTabID then
			self.ContentFrame.InitiativesFrame:RefreshInitiativeTab();
			local initiativeTasksTracked = C_NeighborhoodInitiative.GetTrackedInitiativeTasks();
			local trackedTaskIDs = initiativeTasksTracked.trackedIDs;
			local excludeCollapsed = false;
			local dataProvider = self.ContentFrame.InitiativesFrame.InitiativeSetFrame.InitiativeTasks.TaskList:GetDataProvider();
				if davaProvider then
				dataProvider:ForEach(function(elementData)
				local data = elementData:GetData();
				data.tracked = tContains(trackedTaskIDs, data.ID);
					end, excludeCollapsed);
				self.ContentFrame.InitiativesFrame.InitiativeSetFrame.InitiativeTasks.TaskList:ForEachFrame(function(frame, elementData)
					frame:UpdateTracked();
				end);
				end
				
		end

	end
end

function HousingDashboardHouseInfoMixin:OnHouseListUpdated(houseInfoList)
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
end

function HousingDashboardHouseInfoMixin:RefreshHouseDropdown(houseInfoList)
	self.selectedHouseID = 1;

	local function OnHouseSelected(houseInfoID)
		self.ContentFrame.InitiativesFrame:OnHouseSelected(houseInfoID);
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
end

function InitiativesTabMixin:OnHouseListUpdated(playerHouseList)
	self.playerHouseList = playerHouseList;
end

function InitiativesTabMixin:RefreshInitiativeTab()
	self.currentInitiative = C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo();
	self.initiativeActivityLog = C_NeighborhoodInitiative.GetInitiativeActivityLogInfo();
	self.isViewingActiveNeighborhood = C_NeighborhoodInitiative.IsViewingActiveNeighborhood();

	if self.currentInitiative then
		if self.currentInitiative.isLoaded then
			if self.currentInitiative.initiativeID ~= 0 then
				self:GetParent():GetParent().LoadingSpinner:Hide();
				self.NoInitiativeSetFrame:Hide();
				self.InitiativeSetFrame:Show();

				if self.isViewingActiveNeighborhood then
					self:RefreshTaskList();
					self:RefreshActivityLog();
					self.InitiativeSetFrame.InitiativeTasks:Show();
					self.InitiativeSetFrame.InitiativeActivity:Show();
					self.InitiativeSetFrame.InitiativeActiveNeighborhoodSwitcher:Hide();
				else
					self.InitiativeSetFrame.InitiativeTasks:Hide();
					self.InitiativeSetFrame.InitiativeActivity:Hide();
					self.InitiativeSetFrame.InitiativeActiveNeighborhoodSwitcher:Show();
					--! TODO Will need to set the info for the active initiative, once API provided by GP (CurrentlyActive, ActiveName, ActiveNeighborhoodName)
				end

				self:SetProgressBarThresholds();

				self.InitiativeSetFrame.InitiativeName:SetText(self.currentInitiative.title);
				self.InitiativeSetFrame.InitiativeDescription:SetText(self.currentInitiative.description);

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
end

--! TODO still using fake data, GP/Server/Rewards work still WIP
function InitiativesTabMixin:SetProgressBarThresholds()
	self.InitiativeSetFrame.ProgressBar:SetMinMaxValues(PROGRESS_BAR_MIN, self.currentInitiative.progressRequired);
	self.InitiativeSetFrame.ProgressBar:SetValue(self.currentInitiative.currentProgress);

	if self.InitiativeSetFrame.ProgressBar:GetValue() > PROGRESS_BAR_MIN then
		self.InitiativeSetFrame.ProgressBar.BarEnd:Show();
		self.InitiativeSetFrame.ProgressBar.BarEnd:SetPoint("LEFT", self.InitiativeSetFrame.ProgressBar.BarFill, "LEFT", 0, 0);
		self.InitiativeSetFrame.ProgressBar.BarEnd:SetPoint("RIGHT", self.InitiativeSetFrame.ProgressBar.BarFill, "RIGHT", 0, 0);
	else
		self.InitiativeSetFrame.ProgressBar.BarEnd:Hide();
		self.InitiativeSetFrame.ProgressBar.BarEnd:ClearAllPoints();
	end

	if not self.thresholdFrames then
		self.thresholdFrames = {};
	end

	local currentThreshold = PROGRESS_BAR_FIRST_THRESHOLD;
	for i, thresholdInfo in pairs(PROGRESS_BAR_REWARDS) do
		local thresholdName = "Threshold" .. currentThreshold;
		local thresholdFrame = self.InitiativeSetFrame.ProgressBar[thresholdName];

		local template = "ProgressThresholdTemplate";
		if i == PROGRESS_BAR_MAX_NUM_REWARDS then
			template = "ProgressThresholdLargeTemplate";
		end

		if not thresholdFrame then
			thresholdFrame = CreateFrame("Frame", nil, self.InitiativeSetFrame.ProgressBar, template);
			self.InitiativeSetFrame.ProgressBar[thresholdName] = thresholdFrame;
			table.insert(self.thresholdFrames, thresholdFrame);
		end

		local xOffset = i * self.InitiativeSetFrame.ProgressBar:GetWidth() / PROGRESS_BAR_MAX_NUM_REWARDS;

		if i < PROGRESS_BAR_MAX_NUM_REWARDS then
			thresholdFrame:SetPoint("CENTER", self.InitiativeSetFrame.ProgressBar, "BOTTOMLEFT", xOffset, 0);
		elseif i == PROGRESS_BAR_MAX_NUM_REWARDS then
			thresholdFrame:SetPoint("CENTER", self.InitiativeSetFrame.ProgressBar, "BOTTOMRIGHT", 2, 11);
		end

		local isFinalReward = template == "ProgressThresholdLargeTemplate";
		thresholdFrame:Setup(thresholdInfo, PROGRESS_BAR_CURR_VAL, currentThreshold, isFinalReward);
		currentThreshold = currentThreshold + 1;
	end
end

function InitiativesTabMixin:UpdateBackground(selectedHouseInfo)
	if selectedHouseInfo and selectedHouseInfo.neighborhoodGUID then
		local atlas = "housing-dashboard-bg-" .. C_Housing.GetNeighborhoodTextureSuffix(selectedHouseInfo.neighborhoodGUID);
		self.InitiativeSetFrame.InitiativesBG:SetAtlas(atlas);
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

--! TODO:
--! repeatable finites need a complete state done, but I can't complete init tasks at the moment, pending GP work. should be a dropdown just like the incomplete state.
--! tooltips are going to be needed, but I'm going to wait until data provided by gameplay to implement
--! Tasks need to be trackable, see travelers log for more info, waiting until we have data to impl
--! "Additional Rewards" are still being faked since rewards still WIP
--! Progress, and task completion aren't 100% done from GP yet, so I need to circle back and implement that then verify
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
				button.RepeatableIcon:Show();
				button.Title:ClearAllPoints();
				button.Title:SetPoint("LEFT", button.RepeatableIcon, "RIGHT", 4, -12);
				button.CollapseIcon:Hide();
				button.CollapseIconAlphaAdd:Hide();
			elseif data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableFinite then
				button.RepeatableIcon:Hide();
				button.Title:ClearAllPoints();
				button.Title:SetPoint("LEFT", button, "LEFT", 30, 15);

				if data.topLevel then
					button.CollapseIcon:Show();
					button.CollapseIconAlphaAdd:Show();
					button:SetCollapseState(node:IsCollapsed());
				else
					button.CollapseIcon:Hide();
					button.CollapseIconAlphaAdd:Hide();
				end
			else
				button.RepeatableIcon:Hide();
				button.Title:ClearAllPoints();
				button.Title:SetPoint("LEFT", button, "LEFT", 30, 15);
				button.CollapseIcon:Hide();
				button.CollapseIconAlphaAdd:Hide();
			end

			if data.completed and data.timesCompleted and data.timesCompleted > 0 then
				button.Title:SetText(HOUSING_DASHBOARD_REPEATABLE_TASK_TITLE_FORMAT:format(data.taskName, data.timesCompleted));
			else
				button.Title:SetText(data.taskName);
			end

			if data.completed then
				button.ActivityXP:Hide();
				button.Checkmark:Show();
			else
				button.ActivityXP:SetText(data.progressContributionAmount);
				button.ActivityXP:Show();
				button.Checkmark:Hide();
			end
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
			frame.ActivityXP:SetText(data.amount);
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
			-- task.sortOrder = idx; -- To preserve the original sort order...
			task.children = {};
			taskList[task.ID] = task;
		else
			-- child task
			if taskList[task.supersedes] then
				-- First child, insert into parent's children list
				tinsert(taskList[task.supersedes].children, task);
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
			local topLevelTaskData = { ID = task.ID, taskType = Enum.NeighborhoodInitiativeTaskType.RepeatableFinite, taskName = task.taskName, description = task.description, progressContributionAmount = task.progressContributionAmount, topLevel = true, sortOrder = task.sortOrder, completed = task.completed, requirementsList = task.requirementsList, tracked = task.tracked};
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
	if self.initiativeActivityLog and self.initiativeActivityLog.taskActivity then
		local dataProvider = CreateDataProvider();

		for _, activity in ipairs(self.initiativeActivityLog.taskActivity) do
			dataProvider:Insert(activity);
		end

		self.InitiativeSetFrame.InitiativeActivity.ActivityLog:SetEdgeFadeLength(SCROLL_BOX_EDGE_FADE_LENGTH);
		self.InitiativeSetFrame.InitiativeActivity.ActivityLog:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end
end

---------------------Initiatives Tab: Task Button-------------------------------
InitiativeTaskButtonMixin = {};

function InitiativeTaskButtonMixin:Init()
	self:GetElementData():SetCollapsed(true);
	self:UpdateButtonState();
end

function InitiativeTaskButtonMixin:SetCollapseState(isCollapsed)
	local atlas = isCollapsed and "ui-questtrackerbutton-expand-all" or "UI-QuestTrackerButton-Collapse-All";
	self.CollapseIcon:SetAtlas(atlas);
	self.CollapseIconAlphaAdd:SetAtlas(atlas);
end

function InitiativeTaskButtonMixin:UpdateTracked()
	local data = self:GetData();
	-- TODO UI: Add tracking check mark WOW12-33999
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
function InitiativeTaskButtonMixin:OnClick_Internal()
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

	return false;
end

function InitiativeTaskButtonMixin:OnClick()
	if self:OnClick_Internal() then
		return;
	end

	local data = self:GetData();
	if data and data.hasChild then
		local node = self:GetElementData();
		if data.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableFinite then
			node:ToggleCollapsed();
			self:SetCollapseState(node:IsCollapsed());
			self:UpdateButtonState();
		end
	end
end

function InitiativeTaskButtonMixin:ShowTooltip()
	local data = self:GetData();
	if not data then
		return;
	end

	GameTooltip_SetTitle(GameTooltip, data.taskName, NORMAL_FONT_COLOR, true);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	if #data.description > 0 then
		GameTooltip:AddLine(data.description, 1, 1, 1, true);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end

	for _, requirement in ipairs(data.requirementsList) do
		local tooltipLine = requirement.requirementText;
		tooltipLine = string.gsub(tooltipLine, " / ", "/");
		local color = not requirement.completed and WHITE_FONT_COLOR or DISABLED_FONT_COLOR;
		GameTooltip_AddColoredLine(GameTooltip, tooltipLine, color);
	end

	local conditionLines = {};
	local function AddConditionLine(text, r, g, b)
		table.insert(conditionLines, {
			text = text,
			r = r,
			g = g,
			b = b,
		});
	end

	if data.tracked then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddInstructionLine(GameTooltip, MONTHLY_ACTIVITIES_UNTRACK);
	else
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddInstructionLine(GameTooltip, MONTHLY_ACTIVITIES_TRACK);
	end

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

--! TODO will need to be revised once data provided by gameplay
function ProgressThresholdMixin:Setup(thresholdInfo, currentThresholdLevel, thresholdLevel, isFinalReward)
	--! TODO - implement once we get rewards data
	-- self.Reward.name = thresholdInfo.name;
	-- self.Reward.description = thresholdInfo.description;

	-- self.Reward.Icon:SetTexture(thresholdInfo.icon);

	if currentThresholdLevel >= thresholdLevel then
		if not isFinalReward then
			self.LineIncomplete:Hide();
			self.LineComplete:Show();
			self.Reward.IconBorder:SetAtlas("housing-dashboard-fillbar-pip-complete");
		end
		self.Reward.EarnedCheckmark:Show();
	else
		if not isFinalReward then
			self.LineIncomplete:Show();
			self.LineComplete:Hide();
			self.Reward.IconBorder:SetAtlas("housing-dashboard-fillbar-pip-incomplete");
		end
		self.Reward.EarnedCheckmark:Hide();
	end
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
