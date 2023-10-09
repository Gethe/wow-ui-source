local tooltipButton;

QuestLogButtonTypes = EnumUtil.MakeEnum("None", "Any", "Header", "Quest");

QuestLogMixin = { };

function QuestLogMixin:GetCurrentMapID()
	if self:GetParent():IsShown() then
		return self:GetParent():GetMapID();
	end

	return C_Map.GetBestMapForUnit("player");
end

function QuestLogMixin:SyncQuestSystemWithCurrentMap()
	local mapID = self:GetCurrentMapID();
	if mapID then
		C_QuestLog.SetMapForQuestPOIs(mapID);
		return true;
	end

	return false;
end

function QuestLogMixin:Refresh()
	if QuestMapFrame.DetailsFrame.questMapID and self.DetailsFrame.questMapID ~= self:GetParent():GetMapID() then
		QuestMapFrame_CloseQuestDetails();
	end
	self:SyncQuestSystemWithCurrentMap();
	SortQuestSortTypes();
	SortQuests();
	local numPOIs = QuestMapUpdateAllQuests();
	QuestMapFrame_ResetFilters();
	QuestMapFrame_UpdateAll(numPOIs);
end

function QuestLogMixin:UpdatePOIs()
	if self:SyncQuestSystemWithCurrentMap() then
		QuestMapUpdateAllQuests();
		QuestPOIUpdateIcons();
	end
end

function QuestLogMixin:SetFrameLayoutIndex(frame)
	frame.layoutIndex = self.layoutIndex or 1;
	self.layoutIndex = frame.layoutIndex + 1;
end

function QuestLogMixin:ResetLayoutIndex()
	self.layoutIndex = 1;
end

function QuestLogMixin:OnHighlightedQuestPOIChange(questID)
	local poiButton = QuestPOI_FindButton(self.QuestsFrame.Contents, questID);
	if poiButton then
		QuestPOIButton_EvaluateManagedHighlight(poiButton);
	end
end

function QuestLogMixin:OnMapPinClick(pin, questID)
	if self.DetailsFrame.questID ~= questID then
		QuestMapFrame_ShowQuestDetails(questID);
	end
end

QuestLogHeaderCodeMixin = {};

function QuestLogHeaderCodeMixin:GetButtonType()
	return QuestLogButtonTypes.Header;
end

function QuestLogHeaderCodeMixin:OnLoad()
	local isMouseOver = false;
	self:CheckHighlightTitle(isMouseOver);
end

function QuestLogHeaderCodeMixin:OnClick(button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if button == "LeftButton" then
		local _, _, _, isHeader, isCollapsed = GetQuestLogTitle(self.questLogIndex);
		if isHeader then
			if isCollapsed then
				ExpandQuestHeader(self.questLogIndex);
			else
				CollapseQuestHeader(self.questLogIndex);
			end
		end
	end
end

function QuestLogHeaderCodeMixin:OnEnter()
	local isMouseOver = true;
	self:CheckHighlightTitle(isMouseOver);
	self:CheckUpdateTooltip(isMouseOver);
end

function QuestLogHeaderCodeMixin:OnLeave()
	local isMouseOver = false;
	self:CheckHighlightTitle(isMouseOver);
	self:CheckUpdateTooltip(isMouseOver);
end

function QuestLogHeaderCodeMixin:GetTitleRegion()
	return self.ButtonText or self.Text;
end

function QuestLogHeaderCodeMixin:GetTitleColor(useHighlight)
	return useHighlight and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
end

function QuestLogHeaderCodeMixin:IsTruncated()
	return self:GetTitleRegion():IsTruncated();
end

function QuestLogHeaderCodeMixin:CheckHighlightTitle(isMouseOver)
	local color = self:GetTitleColor(isMouseOver)
	self:GetTitleRegion():SetTextColor(color:GetRGB());
end

function QuestLogHeaderCodeMixin:CheckUpdateTooltip(isMouseOver)
	local tooltip = GetAppropriateTooltip();

	if self:IsTruncated() and isMouseOver then
		tooltip:ClearAllPoints();
		tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 239, 0);
		tooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip_SetTitle(tooltip, self:GetTitleRegion():GetText(), nil, true);
	else
		tooltip:Hide();
	end
end

function QuestMapFrame_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_LOG_CRITERIA_UPDATE");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("QUEST_WATCH_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("AJ_QUEST_LOG_OPEN");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("CVAR_UPDATE");

	EventRegistry:RegisterCallback("SetHighlightedQuestPOI", self.OnHighlightedQuestPOIChange, self);
	EventRegistry:RegisterCallback("ClearHighlightedQuestPOI", self.OnHighlightedQuestPOIChange, self);

	self.completedCriteria = {};
	local onCreateFunc = nil;
	local useHighlightManager = true;
	QuestPOI_Initialize(QuestScrollFrame.Contents, onCreateFunc, useHighlightManager);
end

local function QuestMapFrame_DoFullUpdate()

	local questDetailID = QuestMapFrame.DetailsFrame.questID;

	if ( questDetailID ) then
		if ( GetQuestLogIndexByID(questDetailID) == 0 ) then
			-- this will call QuestMapFrame_UpdateAll
			QuestMapFrame_CloseQuestDetails();
			return;
		end
	end

	QuestMapFrame_UpdateAll();
	QuestMapFrame_UpdateAllQuestCriteria();

	if ( tooltipButton ) then
		QuestMapLogTitleButton_OnEnter(tooltipButton);
	end
end

function QuestMapFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "QUEST_LOG_UPDATE" and not self.ignoreQuestLogUpdate ) then
		QuestMapFrame_DoFullUpdate();
		WatchFrame_Update();
	elseif ( (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") and not self.ignoreQuestLogUpdate ) then
		local prevQuest = QuestMapFrame.DetailsFrame.questID;
		QuestMapFrame_CloseQuestDetails();
		WatchFrame_GetCurrentMapQuests();
		QuestMapFrame_UpdateAll();
		if(prevQuest and self:IsVisible()) then
			QuestMapFrame.DetailsFrame.questID = prevQuest;
		end
	elseif ( event == "QUEST_LOG_CRITERIA_UPDATE" ) then
		local questID, criteriaID, description, fulfilled, required = ...;

		if (QuestMapFrame_CheckQuestCriteria(questID, criteriaID, description, fulfilled, required)) then
			UIErrorsFrame:AddMessage(ERR_QUEST_ADD_FOUND_SII:format(description, fulfilled, required), YELLOW_FONT_COLOR:GetRGB());
		end
	elseif ( event == "QUEST_WATCH_UPDATE" ) then
		local questID = select(8, GetQuestLogTitle(arg1));
		local questLogIndex = GetQuestLogIndexByID(questID);

		if (not IsTutorialFlagged(11) and TUTORIAL_QUEST_TO_WATCH) then
			if (questID == TUTORIAL_QUEST_TO_WATCH) then
				TriggerTutorial(11);
			end
		end
		if questLogIndex and GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questLogIndex) > 0 and C_QuestLog.GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
			C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Automatic);
		end
	elseif ( event == "QUEST_WATCH_LIST_CHANGED" ) then
		local prevQuest = QuestMapFrame.DetailsFrame.questID;
		QuestMapFrame_CloseQuestDetails();
		WatchFrame_GetCurrentMapQuests();
		QuestMapFrame_UpdateAll();
		if(prevQuest and self:IsVisible()) then
			QuestMapFrame.DetailsFrame.questID = prevQuest;
		end
	elseif ( event == "SUPER_TRACKING_CHANGED" ) then
		QuestMapFrame_UpdateSuperTrackedQuest(self);
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( QuestMapFrame.DetailsFrame.questID ) then
		end

		if ( self:IsVisible() ) then
			QuestMapFrame_UpdateAll();
		end
	elseif ( event == "QUEST_POI_UPDATE" ) then
		QuestMapFrame_UpdateAll();
	elseif ( event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
		if ( self:IsVisible() ) then
			QuestMapFrame_UpdateAll();
		end
	elseif ( event == "QUEST_ACCEPTED" ) then
		TUTORIAL_QUEST_ACCEPTED = arg2; -- questID
		self:Refresh();
	elseif ( event == "AJ_QUEST_LOG_OPEN" ) then
		OpenQuestMapLog();
		local questID = select(8, GetQuestLogTitle(arg1));
		local questIndex = GetQuestLogIndexByID(questID); 
		local mapID = GetQuestUiMapID(arg1);
		if questIndex then
			QuestMapFrame_OpenToQuestDetails(arg1);
		elseif ( mapID ~= 0 ) then
			QuestMapFrame:GetParent():SetMapID(mapID);
		elseif ( arg2 and arg2 > 0) then
			QuestMapFrame:GetParent():SetMapID(arg2);
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:Refresh();
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		-- Set to a new zone, update
		self:Refresh();
	elseif ( event == "CVAR_UPDATE" ) then
		local arg1 =...;
		if ( arg1 == "questPOI" ) then
			WatchFrame_Update();
			QuestLog_UpdateMapButton();
			QuestMapFrame:GetParent():HandleUserActionToggleQuestLog();
			QuestMapFrame_CloseQuestDetails();
			QuestMapFrame_UpdateAll();
		elseif ( arg1 == "questHelper" ) then
			if GetCVarBool("questHelper") then
				WorldMapQuestShowObjectives:Show();
				WatchFrame.showObjectives = GetCVarBool("questPOI");
			else
				WorldMapQuestShowObjectives:Hide();
				WatchFrame.showObjectives = false;
			end
			WatchFrame_Update();
			QuestLog_UpdateMapButton();
			QuestMapFrame:GetParent():HandleUserActionToggleQuestLog();
			QuestMapFrame_CloseQuestDetails();
			QuestMapFrame_UpdateAll();
		end
	end
end

function QuestMapFrame_OnHide(self)
	QuestMapFrame_CloseQuestDetails();
	WorldMapTrackQuest:Hide();
end

function QuestMapFrame_OnShow(self)
	WorldMapTrackQuest:Show();
end

-- opening/closing the quest frame is different from showing/hiding because of fullscreen map mode
-- opened indicates the quest frame should show in fullscreen map mode
-- in windowed map mode the quest frame could be opened but hidden
function QuestMapFrame_Open(userAction)
	if ( userAction ) then
		SetCVar("questLogOpen", 1);
	end
	if ( QuestMapFrame:GetParent():ShouldShowQuestLogPanel() ) then
		QuestMapFrame_Show();
	end
end

function QuestMapFrame_Close(userAction)
	if ( userAction ) then
		SetCVar("questLogOpen", 0);
	end
	QuestMapFrame_Hide();
end

function QuestMapFrame_Show()
	QuestMapFrame_UpdateAll();
	if ( not QuestMapFrame:IsShown() ) then
		QuestMapFrame:Show();
		QuestMapFrame:GetParent():OnQuestLogShow();
	end
end

function QuestMapFrame_Hide()
	if ( QuestMapFrame:IsShown() ) then
		QuestMapFrame:Hide();
		QuestMapFrame_UpdateAll();
		QuestMapFrame:GetParent():OnQuestLogHide();
	end
end

function QuestMapFrame_CheckTutorials()
	if (TUTORIAL_QUEST_ACCEPTED) then
		if (not IsTutorialFlagged(2)) then
			local _, raceName  = UnitRace("player");
			if ( strupper(raceName) ~= "PANDAREN" ) then
				TriggerTutorial(2);
			end
		end
		if (not IsTutorialFlagged(10) and (TUTORIAL_QUEST_ACCEPTED == TUTORIAL_QUEST_TO_WATCH)) then
			TriggerTutorial(10);
		end
		TUTORIAL_QUEST_ACCEPTED = nil;
	end
end

function QuestMapFrame_UpdateAll(numPOIs)
	QuestMapFrame:UpdatePOIs();

	numPOIs = numPOIs or QuestMapUpdateAllQuests();

	if ( QuestMapFrame:GetParent():IsShown() ) then
		local poiTable = { };
		if ( numPOIs > 0 and GetCVarBool("questPOI") and GetCVarBool("questHelper") ) then
			GetQuestPOIs(poiTable);
			WorldMapTrackQuest:Show();
		else
			WorldMapTrackQuest:Hide();
		end
		local questDetailID = QuestMapFrame.DetailsFrame.questID;
		if questDetailID then
			QuestMapFrame_ShowQuestDetails(questDetailID);
		else
			QuestLogQuests_Update(poiTable);
		end

		QuestMapFrame:GetParent():OnQuestLogUpdate();
	end
end

function QuestMapFrame_ResetFilters()
	local numEntries, numQuests = GetNumQuestLogEntries();
	QuestMapFrame.ignoreQuestLogUpdate = true;
	for questLogIndex = 1, numEntries do
		local title, _, _, isHeader, _, _, _, _, _, _, isOnMap = GetQuestLogTitle(questLogIndex);
		if isHeader then
			if isOnMap then
				ExpandQuestHeader(questLogIndex, true);
			else
				CollapseQuestHeader(questLogIndex, true);
			end
		end
	end
	QuestMapFrame.ignoreQuestLogUpdate = nil;
end

function QuestMapFrame_GetFocusedQuestID()
	return QuestMapFrame.DetailsFrame.questID;
end

function QuestMapFrame_ToggleShowDestination()
	local questID = QuestMapFrame.DetailsFrame.questID;
	QuestMapFrame_ShowQuestDetails(questID);
end

function QuestDetailsFrame_OnShow(self)

end

function QuestDetailsFrame_OnHide(self)

end

function QuestMapFrame_ShowQuestDetails(questID)

	local questLogIndex = GetQuestLogIndexByID(questID);
	SelectQuestLogEntry(questLogIndex);
	WorldMapTrackQuest:SetChecked(IsQuestWatched(questLogIndex));
	QuestMapFrame.DetailsFrame.questID = questID;
	QuestPOI_SelectButtonByQuestID(QuestScrollFrame.Contents, questID);
	QuestPOI_SelectButtonByQuestID(WatchFrameLines, questID);
	QuestMapFrame:GetParent():SetFocusedQuestID(questID);

	for frame in QuestScrollFrame.titleFramePool:EnumerateActive() do
		if ( frame.questID == questID ) then
			_QuestMap_HighlightSelectedQuest(frame);
		end
	end

	if(not GetCVarBool("miniWorldMap")) then
		QuestInfo_Display(QUEST_TEMPLATE_MAP_DETAILS, QuestMapFrame.DetailsFrame.ScrollFrame.Contents);
		QuestInfo_Display(QUEST_TEMPLATE_MAP_REWARDS, QuestMapFrame.DetailsFrame.RewardsFrame, nil);
		QuestInfoRewardsFrame:SetPoint("TOPLEFT", 8, -5);

		-- height
		local height;
		if ( MapQuestInfoRewardsFrame:IsShown() ) then
			height = MapQuestInfoRewardsFrame:GetHeight() + 49;
		else
			height = 59;
		end
		height = min(height, 275);
		QuestMapFrame.DetailsFrame.RewardsFrame:SetHeight(height);

		QuestMapFrame.DetailsFrame:Show();
	end
	-- save current view
	QuestMapFrame.DetailsFrame.returnMapID = QuestMapFrame:GetParent():GetMapID();

	-- destination/waypoint
	local mapID = GetQuestUiMapID(questID);
	QuestMapFrame.DetailsFrame.questMapID = mapID;
	if ( mapID ~= 0 ) then
		QuestMapFrame:GetParent():SetMapID(mapID);
	end

	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
end

function QuestMapFrame_CloseQuestDetails(optPortraitOwnerCheckFrame)
	QuestMapFrame.QuestsFrame:Show();
	QuestMapFrame.DetailsFrame:Hide();
	QuestMapFrame.DetailsFrame.questID = nil;
	QuestMapFrame:GetParent():ClearFocusedQuestID();
	QuestMapFrame.DetailsFrame.returnMapID = nil;
	QuestMapFrame.DetailsFrame.questMapID = nil;
	QuestMapFrame_UpdateAll();

	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
end

function QuestMapFrame_PingQuestID(questId)
	QuestMapFrame:GetParent():PingQuestID(questId);
end

function QuestMapFrame_OpenToQuestDetails(questID)
	local mapID = GetQuestUiMapID(questID);
	if ( mapID ~= 0 ) then
		OpenQuestMapLog(mapID);
		QuestMapFrame_ShowQuestDetails(questID);
	else
		OpenQuestMapLog();
	end
end

function QuestMapFrame_GetDetailQuestID()
	return QuestMapFrame.DetailsFrame.questID;
end

function QuestMapFrame_UpdateAllQuestCriteria()
	for questID, _ in pairs(QuestMapFrame.completedCriteria) do
		if not C_QuestLog.IsQuestTask(questID) and not C_QuestLog.GetLogIndexForQuestID(questID) then
			QuestMapFrame.completedCriteria[questID] = nil;
		end
	end
end

function QuestMapFrame_CheckQuestCriteria(questID, criteriaID, description, fulfilled, required)
	if (fulfilled == required) then
		if (QuestMapFrame.completedCriteria[questID] and QuestMapFrame.completedCriteria[questID][criteriaID]) then
			return false;
		end
		if (not QuestMapFrame.completedCriteria[questID]) then
			QuestMapFrame.completedCriteria[questID] = {};
		end
		QuestMapFrame.completedCriteria[questID][criteriaID] = true;
	end

	return true;
end

-- Quests Frame

function QuestsFrame_OnLoad(self)
	ScrollFrame_OnLoad(self);

	self.titleFramePool = CreateFramePool("BUTTON", QuestMapFrame.QuestsFrame.Contents, "QuestLogTitleTemplate", function(framePool, frame)
		FramePool_HideAndClearAnchors(framePool, frame);
		frame.info = nil;
	end);

	self.objectiveFramePool = CreateFramePool("FRAME", QuestMapFrame.QuestsFrame.Contents, "QuestLogObjectiveTemplate");
	self.headerFramePool = CreateFramePool("BUTTON", QuestMapFrame.QuestsFrame.Contents, "QuestLogHeaderTemplate");
end

-- *****************************************************************************************************
-- ***** QUEST LIST
-- *****************************************************************************************************

local function GetObjectiveTextColor(isDisabledQuest, isHighlighted)
	if isDisabledQuest then
		return isHighlighted and QUEST_OBJECTIVE_DISABLED_HIGHLIGHT_FONT_COLOR or QUEST_OBJECTIVE_DISABLED_FONT_COLOR;
	end

	return isHighlighted and QUEST_OBJECTIVE_HIGHLIGHT_FONT_COLOR or QUEST_OBJECTIVE_FONT_COLOR;
end

local function SetupObjectiveTextColor(text, isDisabledQuest, isHighlighted)
	local color = GetObjectiveTextColor(isDisabledQuest, isHighlighted);
	text:SetTextColor(color:GetRGB());
end

local function QuestLogQuests_GetPreviousButtonInfo(displayState)
	return displayState.prevButton, displayState.prevButtonInfo;
end

local function QuestLogQuests_IsPreviousButtonCollapsed(displayState)
	local _, info = QuestLogQuests_GetPreviousButtonInfo(displayState);
	if info then
		return info.isHeader and info.isCollapsed;
	end

	return false;
end

local function QuestLogQuests_SetPreviousButtonInfo(displayState, previousButton, previousButtonInfo)
	displayState.prevButton = previousButton;
	displayState.prevButtonInfo = previousButtonInfo;
end

local QuestLogQuests_UpdateButtonSpacing;
do
	local spacingData = {};
	local function AddSpacingPair(previousButtonType, currentButtonType, spacing)
		if not spacingData[currentButtonType] then
			spacingData[currentButtonType] = {};
		end

		spacingData[currentButtonType][previousButtonType] = spacing;
	end

	local function GetButtonType(button)
		return button and button:GetButtonType() or QuestLogButtonTypes.None;
	end

	local function GetSpacingData(dataTable, buttonType)
		local data = dataTable[buttonType];
		if data then
			return data;
		end

		if buttonType ~= QuestLogButtonTypes.None then
			return dataTable[QuestLogButtonTypes.Any];
		end

		return nil;
	end

	local function GetSpacing(displayState, previousButton, currentButton)
		local currentButtonType = GetButtonType(currentButton);
		local currentSpacingData = GetSpacingData(spacingData, currentButtonType);

		if not currentSpacingData then
			return 0;
		end

		local previousButtonType = GetButtonType(previousButton);
		local spacing = GetSpacingData(currentSpacingData, previousButtonType);

		if not spacing then
			return 0;
		end

		if type(spacing) == "function" then
			return spacing(displayState, previousButton, currentButton);
		end

		return spacing or 0;
	end

	AddSpacingPair(QuestLogButtonTypes.None, QuestLogButtonTypes.Header, 8);
	AddSpacingPair(QuestLogButtonTypes.Header, QuestLogButtonTypes.Quest, 8);

	QuestLogQuests_UpdateButtonSpacing = function(displayState, button)
		local previousButton = QuestLogQuests_GetPreviousButtonInfo(displayState);
		button.topPadding = GetSpacing(displayState, previousButton, button);
	end
end

local function QuestLogQuests_GetTitle(displayState, index)
	local title, level = GetQuestLogTitle(index);
	local questID = select(8, GetQuestLogTitle(index));

	if displayState.displayQuestID then
		title = questID.." - "..title;
	end

	if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") ) then
		title = "["..level.."] "..title;
	end

	return title;
end

local function QuestLogQuests_ShouldShowQuestButton(info, index)
	-- If it's not a quest, then it shouldn't show as a quest button
	local title, _, _, isHeader, isCollapsed, isComplete, _, questID, _, _, isOnMap, _, isTask, isBounty, _, isHidden = GetQuestLogTitle(index);

	if isHeader or not questID then
		return false;
	end

	local mapID = QuestMapFrame:GetParent():GetMapID();	
	local questID = select(8, GetQuestLogTitle(index));
	local questMapID = GetQuestUiMapID(questID);
	if(not(mapID == questMapID)) then
		return false;
	end

	-- Normal rules about quest visibility.
	-- NOTE: IsComplete checks should be cached if possible...coming soon...
	return not isTask and not isHidden and (not isBounty or isComplete);
end

local function QuestLogQuests_ShouldShowHeaderButton(info, index)
	-- NOTE: Info must refer to a header and it shouldDisplay must have been determined in advance.
	local isHeader = select(4, GetQuestLogTitle(index));
	return isHeader;
end

local function QuestLogQuests_BuildSingleQuestInfo(questLogIndex, questInfoContainer)-- lastHeader)
	local questID, questWatchIndex = QuestPOIGetQuestIDByVisibleIndex(questLogIndex);	
	local title, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questWatchIndex);
	if not title then return end

	questInfoContainer[questLogIndex] = {title, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling};

	-- Precompute whether or not the headers should display so that it's easier to add them later.
	-- We don't care about collapsed states, we only care about the fact that there are any quests
	-- to display under the header.
	if isHeader then
		lastHeader = questInfoContainer[questLogIndex];
	end

	return lastHeader;
end

local function QuestLogQuests_BuildQuestInfoContainer()
	local questInfoContainer = {};
	local numEntries = QuestMapUpdateAllQuests();
	local lastHeader;

	for questLogIndex = 1, numEntries do
		lastHeader = QuestLogQuests_BuildSingleQuestInfo(questLogIndex, questInfoContainer, lastHeader);
	end

	return questInfoContainer;
end

local function QuestLogQuests_GetQuestInfos(questInfoContainer)
	local infos = {};

	for index, info in ipairs(questInfoContainer) do
			table.insert(infos, info);
	end

	return infos;
end

local function QuestLogQuests_ShouldDisplayPOIButton(displayState, info, isDisabledQuest, hasLocalPOI)
	return (hasLocalPOI or isDisabledQuest) and displayState.questPOI;
end

local numQuestComplete = 0;
local function QuestLogQuests_GetPOIButton(displayState, info, isDisabledQuest, isComplete, questID, questIndex)
	if isDisabledQuest then
		return QuestPOI_GetButton(QuestScrollFrame.Contents, questID, "disabled", nil);
	elseif isComplete then
	 numQuestComplete =  numQuestComplete + 1;
		return QuestPOI_GetButton(QuestScrollFrame.Contents, questID, "normal", nil);
	else
		return QuestPOI_GetButton(QuestScrollFrame.Contents, questID, "numeric", questIndex -  numQuestComplete);
	end
end

local function QuestLogQuests_GetBestTagID(questID, info, isComplete)
	if ( isComplete and isComplete > 0 ) then
		return "COMPLETED";
	elseif ( isComplete and isComplete < 0 ) then
		return "FAILED";
	end

	-- At this point, we know the quest is not complete, no need to check it any more.
	if C_QuestLog.IsFailed(questID) then
		return "FAILED";
	end

	if questTagID == Enum.QuestTag.Account then
		local factionGroup = GetQuestFactionGroup(questID);
		if factionGroup then
			return factionGroup == LE_QUEST_FACTION_HORDE and "HORDE" or "ALLIANCE";
		else
			return Enum.QuestTag.Account;
		end
	end

	if info.frequency == Enum.QuestFrequency.Daily then
		return "DAILY";
	end

	if info.frequency == Enum.QuestFrequency.Weekly then
		return "WEEKLY";
	end

	if questTagID then
		return questTagID;
	end

	return nil;	
end

local function QuestLogQuests_AddQuestButton(displayState, info, questWatch, index)	
	local button = QuestScrollFrame.titleFramePool:Acquire();
	local level = select(2, GetQuestLogTitle(questWatch));
	local questID = select(8, GetQuestLogTitle(questWatch));
	local hasLocalPOI = select(12, GetQuestLogTitle(questWatch));
	local questLogIndex = GetQuestLogIndexByID(questID);

	button.info = info;
	button.questID = questID;
	button.questLogIndex = index;

	QuestMapFrame:SetFrameLayoutIndex(button);

	local title = QuestLogQuests_GetTitle(displayState, questWatch);

	if(QuestMapFrame.DetailsFrame.questID == nil) then
		QuestMapFrame.DetailsFrame.questID = questID;
	end

	local ignoreReplayable = false;
	local ignoreDisabled = true;
	local useLargeIcon = false;
	button.Text:SetText(title);

	local difficultyColor = GetQuestDifficultyColor(level);
	button.Text:SetTextColor(difficultyColor.r, difficultyColor.g, difficultyColor.b);

	if IsQuestWatched(questLogIndex) then
		button.Check:Show();
	else
		button.Check:Hide();
	end

	local isComplete = IsQuestComplete(questID);

	-- POI/objectives
	local requiredMoney = GetQuestLogRequiredMoney(questID);
	local playerMoney = GetMoney();
	local numObjectives = GetNumQuestLeaderBoards(questWatch);
	local isDisabledQuest = false;
	local totalHeight = 8 + button.Text:GetHeight();

	-- objectives
	if isComplete then
		local objectiveFrame = QuestScrollFrame.objectiveFramePool:Acquire();
		objectiveFrame.questID = questID;
		objectiveFrame:Show();
		local completionText = GetQuestLogCompletionText(questWatch) or QUEST_WATCH_QUEST_READY;
		objectiveFrame.Text:SetText(completionText);
		local height = objectiveFrame.Text:GetStringHeight();
		objectiveFrame:SetHeight(height);
		objectiveFrame:SetPoint("TOPLEFT", button.Text, "BOTTOMLEFT", 0, -3);
		totalHeight = totalHeight + height + 3;
	else
		local prevObjective;
		for i = 1, numObjectives do
			local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questWatch);
			if text and not finished then
				local objectiveFrame = QuestScrollFrame.objectiveFramePool:Acquire();
				objectiveFrame.questID = questID;
				objectiveFrame:Show();
				objectiveFrame.Text:SetText(text);
				local height = objectiveFrame.Text:GetStringHeight();
				objectiveFrame:SetHeight(height);

				if prevObjective then
					objectiveFrame:SetPoint("TOPLEFT", prevObjective, "BOTTOMLEFT", 0, -2);
					height = height + 2;
				else
					objectiveFrame:SetPoint("TOPLEFT", button.Text, "BOTTOMLEFT", 0, -3);
					height = height + 3;
				end

				totalHeight = totalHeight + height;
				prevObjective = objectiveFrame;
			end
		end

		if requiredMoney > playerMoney then
			local objectiveFrame = QuestScrollFrame.objectiveFramePool:Acquire();
			objectiveFrame.questID = questID;
			objectiveFrame:Show();
			objectiveFrame.Text:SetText(GetMoneyString(playerMoney).." / "..GetMoneyString(requiredMoney));
			SetupObjectiveTextColor(objectiveFrame.Text, isDisabledQuest, false);
			local height = objectiveFrame.Text:GetStringHeight();
			objectiveFrame:SetHeight(height);

			if prevObjective then
				objectiveFrame:SetPoint("TOPLEFT", prevObjective, "BOTTOMLEFT", 0, -2);
				height = height + 2;
			else
				objectiveFrame:SetPoint("TOPLEFT", button.Text, "BOTTOMLEFT", 0, -3);
				height = height + 3;
			end

			totalHeight = totalHeight + height;
		end
	end

	if QuestLogQuests_ShouldDisplayPOIButton(displayState, info, isDisabledQuest, hasLocalPOI) then
		local poiButton = QuestLogQuests_GetPOIButton(displayState, info, isDisabledQuest, isComplete, questID, index);
		if poiButton then
			poiButton:SetPoint("TOPLEFT", button, 6, -4);
			poiButton.parent = button;
		end

		-- extra room because of POI icon
		totalHeight = totalHeight + 6;
		button.Text:SetPoint("TOPLEFT", 31, -8);
	else
		button.Text:SetPoint("TOPLEFT", 31, -4);
	end

	button:SetHeight(totalHeight);

	return button;
end

local function QuestLogQuests_SetupStandardHeaderButton(button, displayState, info, index)
	local isCollapsed = select(5, GetQuestLogTitle(index));
	button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
	button:SetHitRectInsets(0, -button.ButtonText:GetWidth(), 0, 0);

	button.questLogIndex = index;
	QuestMapFrame:SetFrameLayoutIndex(button);

	return button;
end

local function QuestLogQuests_AddStandardHeaderButton(displayState, info, index)
	local button = QuestScrollFrame.headerFramePool:Acquire();
	local title = GetQuestLogTitle(index);
	QuestLogQuests_SetupStandardHeaderButton(button, displayState, info, index);
	button:SetText(title);
	return button;
end

local function QuestLogQuests_AddHeaderButton(displayState, info, index)
	displayState.hasShownAnyHeader = true;

	local button;
	button = QuestLogQuests_AddStandardHeaderButton(displayState, info, index);

	return button;
end

local function QuestLogQuests_DisplayQuestButton(displayState, info, index)
	-- TODO: This is a work-around for quest sharing potentially signalling a UI update when nothing is actually in the quest log.
	-- Figure out the real fix (probably related to waiting until quests have stablized)
	if not (info ) then
		return;
	end

	local questID, questWatch = QuestPOIGetQuestIDByVisibleIndex(index);

	if QuestLogQuests_ShouldShowQuestButton(info,  questWatch) then
		return QuestLogQuests_AddQuestButton(displayState, info,  questWatch, index);
	else
		numQuestComplete =  numQuestComplete + 1;
	end
end

local function QuestLogQuests_IsDisplayEmpty(displayState)
	return not displayState.hasShownAnyHeader and QuestScrollFrame.titleFramePool:GetNumActive() == 0;
end

local function QuestLogQuests_UpdateBackground(displayState)
	local atlas = QuestLogQuests_IsDisplayEmpty(displayState) and "NoQuestsBackground" or "QuestLogBackground";
end

local function QuestLogQuests_BuildInitialDisplayState(poiTable, questInfoContainer)
	return {
		questInfoContainer = questInfoContainer,
		poiTable = poiTable,
		displayQuestID = GetCVarBool("displayQuestID"),
		showReadyToRecord = GetCVarBool("showReadyToRecord"),
		questPOI = GetCVarBool("questPOI") and GetCVarBool("questHelper"),
	};
end

local function QuestLogQuests_DisplayQuestsFromIndices(displayState, infos)	
	for index, info in ipairs(infos) do
		local button = QuestLogQuests_DisplayQuestButton(displayState, info, index);
		if button then
			button:Show();
			QuestLogQuests_UpdateButtonSpacing(displayState, button);
			QuestLogQuests_SetPreviousButtonInfo(displayState, button, info);
		end
	end
end

function QuestLogQuests_Update(poiTable)
	QuestScrollFrame.titleFramePool:ReleaseAll();
	QuestScrollFrame.objectiveFramePool:ReleaseAll();
	QuestScrollFrame.headerFramePool:ReleaseAll();
	QuestPOI_ResetUsage(QuestScrollFrame.Contents);
	QuestMapFrame:ResetLayoutIndex();
	numQuestComplete = 0;

	-- Build the info table, to determine what needs to be displayed
	local questInfoContainer = QuestLogQuests_BuildQuestInfoContainer();
	local questInfos = QuestLogQuests_GetQuestInfos(questInfoContainer);
	local displayState = QuestLogQuests_BuildInitialDisplayState(poiTable, questInfoContainer);

	-- Display the rest of the normal quests and their headers.
	QuestLogQuests_DisplayQuestsFromIndices(displayState, questInfos);
	
	QuestPOI_HideUnusedButtons(QuestScrollFrame.Contents);
	QuestScrollFrame.Contents:Layout();

	if (QuestScrollFrame.titleFramePool:GetNumActive() == 0 ) then
		if(WorldMapFrame.QuestLog:IsShown()) then
			WorldMapFrame:HandleUserActionToggleQuestLog();
		end
		WorldMapTrackQuest:Hide();
	else
		WorldMapFrame:HandleUserActionOpenQuestLog();
	end
end

function ToggleQuestMap()
	if ( QuestMapFrame:IsShown() and QuestMapFrame:IsVisible() ) then
		HideUIPanel(QuestMapFrame:GetParent());
	end
end

function OpenQuestMapLog(mapID)
	QuestMapFrame:GetParent():OnQuestLogOpen();
	ShowUIPanel(QuestMapFrame:GetParent());

	if mapID then
		QuestMapFrame:GetParent():SetMapID(mapID);
	end
	OpenWorldMap(mapID);

	if ( QuestLogDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogDetailFrame);
	end

	if ( QuestLogFrame:IsShown() ) then
		HideUIPanel(QuestLogFrame);
	end
end

function _QuestMap_HighlightQuest(questLogTitle)
	local prevParent = QuestMapHighlightFrame:GetParent();
	if ( prevParent and prevParent ~= questLogTitle ) then
		-- set prev quest's colors back to normal
		local prevName = prevParent:GetName();
		prevParent:UnlockHighlight();
	end
	local selectedQuest = QuestMapSelectFrame:GetParent();
	if ( questLogTitle ) then
		questLogTitle:LockHighlight();
		-- reposition highlight frames
		QuestMapHighlightFrame:SetParent(questLogTitle);
		QuestMapHighlightFrame:SetPoint("TOPLEFT", questLogTitle, "TOPLEFT", 0, 0);
		QuestMapHighlightFrame:SetPoint("BOTTOMRIGHT", questLogTitle, "BOTTOMRIGHT", 0, 0);
		QuestMapHighlightFrame:SetFrameStrata("MEDIUM");
		QuestMapHighlightFrame:Show();
		QuestMapFrame:GetParent():SetHighlightedQuestID(questLogTitle.questID);

		if(selectedQuest and questLogTitle == selectedQuest) then
			QuestMapHighlightFrame:Hide();
		end
	else
		QuestMapHighlightFrame:Hide();
	end
end

function _QuestMap_HighlightSelectedQuest(questLogTitle)
	local prevParent = QuestMapSelectFrame:GetParent();
	if ( prevParent and prevParent ~= questLogTitle ) then
		-- set prev quest's colors back to normal
		local prevName = prevParent:GetName();
		prevParent:UnlockHighlight();
	end
	local highlightedQuest = QuestMapHighlightFrame:GetParent();
	if ( questLogTitle ) then
		questLogTitle:LockHighlight();
		-- reposition highlight frames
		QuestMapSelectFrame:SetParent(questLogTitle);
		QuestMapSelectFrame:SetPoint("TOPLEFT", questLogTitle, "TOPLEFT", 0, 0);
		QuestMapSelectFrame:SetPoint("BOTTOMRIGHT", questLogTitle, "BOTTOMRIGHT", 0, 0);
		QuestMapSelectFrame:SetFrameStrata("MEDIUM");
		QuestMapSelectFrame:Show();
		QuestMapFrame:GetParent():SetFocusedQuestID(questLogTitle.questID);

		if(highlightedQuest and questLogTitle == highlightedQuest) then
			QuestMapHighlightFrame:Hide();
		end
	else
		QuestMapSelectFrame:Hide();
	end
end

function QuestMapLogTitleButton_OnEnter(self)
	-- do block highlight
	local questID, questLogIndex = QuestPOIGetQuestIDByVisibleIndex(self.questLogIndex);
	local title, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questLogIndex);

	local difficultyHighlightColor;
	if isHeader then
		difficultyHighlightColor = QuestDifficultyHighlightColors["header"];
	else
		difficultyHighlightColor = GetQuestDifficultyColor(level);
	end

	self.Text:SetTextColor(difficultyHighlightColor.r, difficultyHighlightColor.g, difficultyHighlightColor.b);

	_QuestMap_HighlightQuest(self);

	if self:GetParent().useHighlightManager then
		QuestPOIHighlightManager:SetHighlight(questID);
	end

	-- description
	if isComplete then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		GameTooltip:AddLine(completionText, 1, 1, 1, true);
		GameTooltip:AddLine(" ");
	else
		local needsSeparator = false;
		local _, objectiveText = GetQuestLogQuestText(questLogIndex);
		GameTooltip:AddLine(objectiveText, 1, 1, 1, true);
		GameTooltip:AddLine(" ");
		local requiredMoney = GetQuestLogRequiredMoney(questLogIndex);
		local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
		for i = 1, numObjectives do
			local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
			if ( text ) then
				local color = HIGHLIGHT_FONT_COLOR;
				if ( finished ) then
					color = GRAY_FONT_COLOR;
				end
				GameTooltip:AddLine(QUEST_DASH..text, color.r, color.g, color.b, true);
				needsSeparator = true;
			end
		end
		if ( requiredMoney > 0 ) then
			local playerMoney = GetMoney();
			local color = HIGHLIGHT_FONT_COLOR;
			if ( requiredMoney <= playerMoney ) then
				playerMoney = requiredMoney;
				color = GRAY_FONT_COLOR;
			end
			GameTooltip:AddLine(QUEST_DASH..GetMoneyString(playerMoney).." / "..GetMoneyString(requiredMoney), color.r, color.g, color.b);
			needsSeparator = true;
		end

		if ( needsSeparator ) then
			GameTooltip:AddLine(" ");
		end
	end

	GameTooltip:AddLine(CLICK_QUEST_DETAILS, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);

	GameTooltip:Show();
	tooltipButton = self;
    EventRegistry:TriggerEvent("QuestMapLogTitleButton.OnEnter", self, questID);
	EventRegistry:TriggerEvent("SetHighlightedQuestPOI", self.questID);
end

function QuestMapLogTitleButton_OnLeave(self)
	-- remove block highlight
	local questID, questLogIndex = QuestPOIGetQuestIDByVisibleIndex(self.questLogIndex);
	local info, level, _, isHeader, _, _, _, questID = GetQuestLogTitle(questLogIndex);
	if info then
		local difficultyColor = isHeader and QuestDifficultyColors["header"] or GetQuestDifficultyColor(level);
		self.Text:SetTextColor( difficultyColor.r, difficultyColor.g, difficultyColor.b );
	end

	
	QuestMapFrame:GetParent():ClearHighlightedQuestID();
	if self:GetParent().useHighlightManager then
		QuestPOIHighlightManager:ClearHighlight();
	end
	EventRegistry:TriggerEvent("ClearHighlightedQuestPOI", questID);
	QuestMapHighlightFrame:Hide();
	GameTooltip:Hide();
	tooltipButton = nil;
end

QuestLogTitleMixin = {};

function QuestLogTitleMixin:GetButtonType()
	return QuestLogButtonTypes.Quest;
end

QuestLogObjectiveMixin = {};

function QuestLogObjectiveMixin:GetButtonType()
	return QuestLogButtonTypes.Quest;
end

function QuestMapLogTitleButton_OnClick(self, button)
	if ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if IsShiftKeyDown() then
		local questIndex = GetQuestLogIndexByID(self.questID);
		_QuestLog_ToggleQuestWatch(questIndex);
	else
		if button == "LeftButton" then
			QuestMapFrame_ShowQuestDetails(self.questID);
			_QuestMap_HighlightSelectedQuest(self);
		end
	end
end

function QuestMapLogTitleButton_OnMouseDown(self)
	local anchor, _, _, x, y = self.Text:GetPoint(1);
	self.Text:SetPoint(anchor, x + 1, y - 1);
	anchor, _, _, x, y = self.TagTexture:GetPoint(2);
	self.TagTexture:SetPoint(anchor, x + 1, y - 1);

	local poiButton = QuestPOI_FindButton(QuestScrollFrame.Contents, self.questID);
	if poiButton then
		poiButton:SetButtonState("PUSHED");
		poiButton.Display:SetPoint("CENTER", 1, -1);
	end
end

function QuestMapLogTitleButton_OnMouseUp(self)
	local anchor, _, _, x, y = self.Text:GetPoint(1);
	self.Text:SetPoint(anchor, x - 1, y + 1);
	anchor, _, _, x, y = self.TagTexture:GetPoint(2);
	self.TagTexture:SetPoint(anchor, x - 1, y + 1);
end