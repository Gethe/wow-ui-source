
local MIN_STORY_TOOLTIP_WIDTH = 240;

local tooltipButton;

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
		ObjectiveTracker_UpdatePOIs();
	end
end

function QuestLogMixin:SetFrameLayoutIndex(frame)
	frame.layoutIndex = self.layoutIndex or 1;
	self.layoutIndex = frame.layoutIndex + 1;
end

function QuestLogMixin:ResetLayoutIndex()
	self.layoutIndex = 1;
end

function QuestLogMixin:ShowCampaignOverview(campaignID)
	self.CampaignOverview:Show();
	self.CampaignOverview:SetCampaign(campaignID);
	QuestScrollFrame:Hide();
end

function QuestLogMixin:HideCampaignOverview(campaignID)
	self.CampaignOverview:Hide();
	QuestScrollFrame:Show();
end

QuestLogHeaderCodeMixin = {};

function QuestLogHeaderCodeMixin:OnClick(button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if button == "LeftButton" then
		local info = C_QuestLog.GetInfo(self.questLogIndex);
		if info then
			if info.isCollapsed then
				ExpandQuestHeader(self.questLogIndex);
			else
				CollapseQuestHeader(self.questLogIndex);
			end
		end
	end
end

function QuestLogHeaderCodeMixin:OnEnter()
	local text = self.ButtonText or self.Text;
	text:SetTextColor(1, 1, 1);
	if text:IsTruncated() then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 239, 0);
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:SetText(text:GetText(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, 1);
	end
end

function QuestLogHeaderCodeMixin:OnLeave()
	local text = self.ButtonText or self.Text;
	text:SetTextColor(0.7, 0.7, 0.7);
	GameTooltip:Hide();
end

QuestLogHeaderMixin = {};

function QuestLogHeaderMixin:OnLoad()
	self.ButtonText:SetTextColor(0.7, 0.7, 0.7);
end

function QuestMapFrame_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_LOG_CRITERIA_UPDATE");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("QUEST_WATCH_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("AJ_QUEST_LOG_OPEN");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CVAR_UPDATE");

	self.completedCriteria = {};
	QuestPOI_Initialize(QuestScrollFrame.Contents);
	QuestMapQuestOptionsDropDown.questID = 0;		-- for QuestMapQuestOptionsDropDown_Initialize
	UIDropDownMenu_SetInitializeFunction(QuestMapQuestOptionsDropDown, QuestMapQuestOptionsDropDown_Initialize);
	UIDropDownMenu_SetDisplayMode(QuestMapQuestOptionsDropDown, "MENU");
end

local function QuestMapFrame_DoFullUpdate()
	if (not IsTutorialFlagged(55) and TUTORIAL_QUEST_TO_WATCH) then
		if C_QuestLog.IsComplete(TUTORIAL_QUEST_TO_WATCH) then
			TriggerTutorial(55);
		end
	end

	local updateButtons = false;
	if ( QuestLogPopupDetailFrame.questID ) then
		if not C_QuestLog.GetLogIndexForQuestID(QuestLogPopupDetailFrame.questID) then
			HideUIPanel(QuestLogPopupDetailFrame);
		else
			QuestLogPopupDetailFrame_Update();
			updateButtons = true;
		end
	end

	local questDetailID = QuestMapFrame.DetailsFrame.questID;

	if ( questDetailID ) then
		if not C_QuestLog.GetLogIndexForQuestID(questDetailID) then
			-- this will call QuestMapFrame_UpdateAll
			QuestMapFrame_ReturnFromQuestDetails();
			return;
		else
			updateButtons = true;
		end
	end

	if ( updateButtons ) then
		QuestMapFrame_UpdateQuestDetailsButtons();
	end

	QuestMapFrame_UpdateAll();
	QuestMapFrame_UpdateAllQuestCriteria();

	if ( tooltipButton ) then
		QuestMapLogTitleButton_OnEnter(tooltipButton);
	end
end

function QuestMapFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( (event == "QUEST_LOG_UPDATE" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player")) and not self.ignoreQuestLogUpdate ) then
		QuestMapFrame_DoFullUpdate();
	elseif ( event == "QUEST_LOG_CRITERIA_UPDATE" ) then
		local questID, criteriaID, description, fulfilled, required = ...;

		if (QuestMapFrame_CheckQuestCriteria(questID, criteriaID, description, fulfilled, required)) then
			UIErrorsFrame:AddMessage(ERR_QUEST_ADD_FOUND_SII:format(description, fulfilled, required), YELLOW_FONT_COLOR:GetRGB());
		end
	elseif ( event == "QUEST_WATCH_UPDATE" ) then
		local questID = arg1;
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);

		if (not IsTutorialFlagged(11) and TUTORIAL_QUEST_TO_WATCH) then
			if (questID == TUTORIAL_QUEST_TO_WATCH) then
				TriggerTutorial(11);
			end
		end
		if questLogIndex and AUTO_QUEST_WATCH == "1" and GetNumQuestLeaderBoards(questLogIndex) > 0 and C_QuestLog.GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
			C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Automatic);
		end
	elseif ( event == "QUEST_WATCH_LIST_CHANGED" ) then
		QuestMapFrame_UpdateQuestDetailsButtons();
		QuestMapFrame_UpdateAll();
	elseif ( event == "SUPER_TRACKING_CHANGED" ) then
		QuestMapFrame_UpdateSuperTrackedQuest(self);
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( QuestMapFrame.DetailsFrame.questID ) then
			QuestMapFrame_UpdateQuestDetailsButtons();
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
		TUTORIAL_QUEST_ACCEPTED = arg1; -- questID
	elseif ( event == "AJ_QUEST_LOG_OPEN" ) then
		OpenQuestLog();
		local questIndex = C_QuestLog.GetLogIndexForQuestID(arg1);
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
	elseif ( event == "CVAR_UPDATE" ) then
		local arg1 =...;
		if ( arg1 == "QUEST_POI" ) then
			QuestMapFrame_UpdateAll();
		end
	end
end

function QuestMapFrame_OnHide(self)
	EventRegistry:TriggerEvent("QuestLog.HideCampaignOverview");
	QuestMapFrame_CloseQuestDetails(self:GetParent());
end

local sessionCommandToCommandName =
{
	[Enum.QuestSessionCommand.Start] = QUEST_SESSION_START_SESSION,
	[Enum.QuestSessionCommand.SessionActiveNoCommand] = QUEST_SESSION_SESSION_ACTIVE,
	[Enum.QuestSessionCommand.Stop] = QUEST_SESSION_SESSION_ACTIVE,
}

local sessionCommandToHelpText =
{
	[Enum.QuestSessionCommand.Start] = QUEST_SESSION_HELP_TEXT_START,
	[Enum.QuestSessionCommand.SessionActiveNoCommand] = QUEST_SESSION_HELP_TEXT_SESSION_ACTIVE,
	[Enum.QuestSessionCommand.Stop] = QUEST_SESSION_HELP_TEXT_SESSION_ACTIVE,
}

local function GetQuestSessionHelpText(command)
	if command == Enum.QuestSessionCommand.Start and C_QuestSession.Exists() then
		return QUEST_SESSION_HELP_TEXT_WAITING;
	end

	return sessionCommandToHelpText[command];
end

local sessionCommandToTooltipTitle =
{
	[Enum.QuestSessionCommand.Start] = QUEST_SESSION_START_SESSION,
	[Enum.QuestSessionCommand.Stop] = QUEST_SESSION_STOP_SESSION,
}

local sessionCommandToTooltipBody =
{
	[Enum.QuestSessionCommand.Start] = QUEST_SESSION_TOOLTIP_START_SESSION,
	[Enum.QuestSessionCommand.Stop] = QUEST_SESSION_TOOLTIP_STOP_SESSION,
}

local sessionCommandToButtonAtlases =
{
	[Enum.QuestSessionCommand.Start] = { normal = "QuestSharing-QuestLog-Button" , pushed = "QuestSharing-QuestLog-ButtonPressed", disabled = "QuestSharing-QuestLog-Button", },
	[Enum.QuestSessionCommand.Stop] = { normal = "QuestSharing-QuestLog-ButtonStop" , pushed = "QuestSharing-QuestLog-ButtonPressedStop", disabled = "QuestSharing-QuestLog-ButtonStop", },
}

QuestSessionManagementMixin = {};

function QuestSessionManagementMixin:OnLoad()
	EventRegistry:RegisterCallback("QuestSessionManager.Update", self.OnQuestSessionManagerUpdate, self);
	EventRegistry:RegisterCallback("QuestLog.ShowCampaignOverview", self.OnQuestLogShowCampaignOverview, self);
	EventRegistry:RegisterCallback("QuestLog.HideCampaignOverview", self.OnQuestLogHideCampaignOverview, self);
end

function QuestSessionManagementMixin:OnShow()
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
end

function QuestSessionManagementMixin:OnHide()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED");
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");

	UpdateMicroButtons();
end

function QuestSessionManagementMixin:OnEvent(event, ...)
	self:UpdateExecuteSessionCommandState();
end

function QuestSessionManagementMixin:OnClick(button, down)
	if button == "LeftButton" then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		QuestSessionManager:ExecuteSessionCommand();

		HelpTip:Acknowledge(self.ExecuteSessionCommand, QUEST_SESSION_WORLD_MAP_TUTORIAL_TEXT);
	end
end

function QuestSessionManagementMixin:OnQuestSessionManagerUpdate()
	QuestMapFrame_UpdateQuestSessionState(QuestMapFrame);
end

function QuestSessionManagementMixin:OnQuestLogShowCampaignOverview(campaignID)
	QuestMapFrame:ShowCampaignOverview(campaignID);
end

function QuestSessionManagementMixin:OnQuestLogHideCampaignOverview()
	QuestMapFrame:HideCampaignOverview();
end

function QuestSessionManagementMixin:UpdateVisibility()
	local shouldShow = QuestSessionManager:ShouldSessionManagementUIBeVisible() and not self.suppressed;
	self:SetShown(shouldShow);

	if shouldShow then
		self:EvaluateAlertVisibility();

		local command = QuestSessionManager:GetSessionCommand();
		if command then
			self.CommandText:SetText(sessionCommandToCommandName[command]);
			self.HelpText:SetText(GetQuestSessionHelpText(command));

			local onlyShowSessionActive = command == Enum.QuestSessionCommand.SessionActiveNoCommand;
			self.ExecuteSessionCommand:SetShown(not onlyShowSessionActive);
			self.SessionActiveFrame:SetShown(onlyShowSessionActive);
			self:UpdateExecuteSessionCommandState();
			self:UpdateExecuteCommandAtlases(command);
		end
	end
end

function QuestSessionManagementMixin:UpdateExecuteSessionCommandState()
	self.ExecuteSessionCommand:SetEnabled(QuestSessionManager:IsSessionManagementEnabled());
	self:UpdateTooltip();
end

function QuestSessionManagementMixin:UpdateExecuteCommandAtlases(command)
	local atlases = sessionCommandToButtonAtlases[command];
	if atlases then
		self.ExecuteSessionCommand:SetNormalAtlas(atlases.normal);
		self.ExecuteSessionCommand:SetPushedAtlas(atlases.pushed);
		self.ExecuteSessionCommand:SetDisabledAtlas(atlases.disabled);
	end
end

function QuestSessionManagementMixin:SetSuppressed(suppressed)
	if self.suppressed ~= suppressed then
		self.suppressed = suppressed;
		self:UpdateVisibility();
	end
end

function QuestSessionManagementMixin:ShowTooltip()
	local command = QuestSessionManager:GetSessionCommand();
	local title = sessionCommandToTooltipTitle[command];
	local text = sessionCommandToTooltipBody[command];

	if title and text then
		GameTooltip:SetOwner(self.ExecuteSessionCommand, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, title);

		local wrap = true;
		GameTooltip_AddNormalLine(GameTooltip, text, wrap);

		local failureReason = QuestSessionManager:GetSessionManagementFailureReason();
		if failureReason == "inCombat" then
			GameTooltip_AddErrorLine(GameTooltip, QUEST_SESSION_TOOLTIP_START_SESSION_NOT_IN_COMBAT);
		end

		GameTooltip:Show();
	end
end

function QuestSessionManagementMixin:UpdateTooltip()
	if GameTooltip:GetOwner() == self.ExecuteSessionCommand then
		GameTooltip:Hide();
		self:ShowTooltip();
	end
end

function ShouldShowQuestSessionAlert()
	return C_QuestSession.CanStart() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_QUEST_SESSION);
end

function QuestSessionManagementMixin:EvaluateAlertVisibility()
	if ShouldShowQuestSessionAlert() then
		local helpTipInfo = {
			text = QUEST_SESSION_WORLD_MAP_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_QUEST_SESSION,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetY = 4,
		};

		HelpTip:Show(self.ExecuteSessionCommand, helpTipInfo);
	end
end

function QuestSessionManagementMixin:OnEnter()
	self:ShowTooltip();
end

function QuestSessionManagementMixin:OnLeave()
	GameTooltip:Hide();
end

function QuestSessionManagementExecute_OnClick(self, button, down)
	self:GetParent():OnClick(button, down);
end

function QuestSessionManagement_OnEnter(self)
	self:GetParent():OnEnter();
end

function QuestSessionManagement_OnLeave(self)
	self:GetParent():OnLeave();
end

function QuestMapFrame_UpdateQuestSessionState(self)
	self.QuestSessionManagement:UpdateVisibility();
	self.QuestSessionManagement:UpdateTooltip();
	if self.QuestSessionManagement:IsShown() then
		self.QuestsFrame.DetailFrame.BottomDetail:SetAtlas("QuestSharing-QuestLog-BottomDetail");
		self.QuestsFrame:SetPoint("BOTTOMRIGHT", self.QuestSessionManagement, "TOPRIGHT", -27, 0);
	else
		self.QuestsFrame.DetailFrame.BottomDetail:SetAtlas("QuestLog_BottomDetail");
		self.QuestsFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -27, 0);
	end
end

function QuestMapFrame_OnShow(self)
	QuestMapFrame_UpdateQuestSessionState(self);
end

-- opening/closing the quest frame is different from showing/hiding because of fullscreen map mode
-- opened indicates the quest frame should show in windowed map mode
-- in fullscreen map mode the quest frame could be opened but hidden
function QuestMapFrame_Open(userAction)
	if ( userAction ) then
		SetCVar("questLogOpen", 1);
	end
	if ( QuestMapFrame:GetParent():CanDisplayQuestLog() ) then
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
	if ( not QuestMapFrame:IsShown() ) then
		QuestMapFrame_UpdateAll();
		QuestMapFrame:Show();
		QuestMapFrame:GetParent():OnQuestLogShow();
	end
end

function QuestMapFrame_Hide()
	if ( QuestMapFrame:IsShown() ) then
		QuestMapFrame:Hide();
		QuestMapFrame_UpdateAll();
		QuestMapFrame_CheckTutorials();
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
		if ( numPOIs > 0 and GetCVarBool("questPOI") ) then
			GetQuestPOIs(poiTable);
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
	local numEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();
	QuestMapFrame.ignoreQuestLogUpdate = true;
	for questLogIndex = 1, numEntries do
		local info = C_QuestLog.GetInfo(questLogIndex);
		if info and info.isHeader then
			if info.isOnMap then
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

local ignoreWaypointsByQuestID = { };

function QuestMapFrame_ToggleShowDestination()
	local questID = QuestMapFrame.DetailsFrame.questID;
	ignoreWaypointsByQuestID[questID] = not ignoreWaypointsByQuestID[questID];
	QuestMapFrame_ShowQuestDetails(QuestMapFrame.DetailsFrame.questID);
end

function QuestMapFrame_AdjustPathButtons()
	if QuestMapDetailsScrollFrame:GetVerticalScrollRange() > 0 then
		QuestMapFrame.DetailsFrame.DestinationMapButton:SetPoint("TOPRIGHT", -2, -4);
		QuestMapFrame.DetailsFrame.WaypointMapButton:SetPoint("TOPRIGHT", -2, -4);
		QuestInfo_AdjustTitleWidth(-19);
	else
		QuestMapFrame.DetailsFrame.DestinationMapButton:SetPoint("TOPRIGHT", 14, -4);
		QuestMapFrame.DetailsFrame.WaypointMapButton:SetPoint("TOPRIGHT", 14, -4);
		QuestInfo_AdjustTitleWidth(-2);
	end
end

function QuestDetailsFrame_OnShow(self)
	QuestMapFrame.DetailsFrame.Bg:SetAtlas(QuestUtil.GetDefaultQuestMapBackgroundTexture());
	QuestMapFrame.QuestSessionManagement:SetSuppressed(true);
end

function QuestDetailsFrame_OnHide(self)
	QuestMapFrame.QuestSessionManagement:SetSuppressed(false);
end

function QuestMapFrame_CheckAutoSupertrackOnShowDetails(questID)
	-- Callings never display a POI icon, so super-track it now, yep, this steals the current super-track.
	if C_QuestLog.IsQuestCalling(questID) then
		C_SuperTrack.SetSuperTrackedQuestID(questID);
	end
end

function QuestMapFrame_ShowQuestDetails(questID)
	QuestMapFrame_CheckAutoSupertrackOnShowDetails(questID);

	EventRegistry:TriggerEvent("QuestLog.HideCampaignOverview");
	C_QuestLog.SetSelectedQuest(questID);
	QuestMapFrame.DetailsFrame.questID = questID;
	QuestMapFrame:GetParent():SetFocusedQuestID(questID);
	QuestInfo_Display(QUEST_TEMPLATE_MAP_DETAILS, QuestMapFrame.DetailsFrame.ScrollFrame.Contents);
	QuestInfo_Display(QUEST_TEMPLATE_MAP_REWARDS, QuestMapFrame.DetailsFrame.RewardsFrame, nil, nil, true);
	QuestMapFrame.DetailsFrame.ScrollFrame.ScrollBar:SetValue(0);

	local mapFrame = QuestMapFrame:GetParent();
	local questPortrait, questPortraitText, questPortraitName, questPortraitMount, questPortraitModelSceneID = C_QuestLog.GetQuestLogPortraitGiver();
	if (questPortrait and questPortrait ~= 0 and QuestLogShouldShowPortrait() and (UIParent:GetRight() - mapFrame:GetRight() > QuestModelScene:GetWidth() + 6)) then
		QuestFrame_ShowQuestPortrait(mapFrame, questPortrait, questPortraitMount, questPortraitModelSceneID, questPortraitText, questPortraitName, -2, -43);
		QuestModelScene:SetFrameLevel(mapFrame:GetFrameLevel() + 2);
	else
		QuestFrame_HideQuestPortrait();
	end

	-- height
	local height;
	if ( MapQuestInfoRewardsFrame:IsShown() ) then
		height = MapQuestInfoRewardsFrame:GetHeight() + 49;
	else
		height = 59;
	end
	height = min(height, 275);
	QuestMapFrame.DetailsFrame.RewardsFrame:SetHeight(height);
	QuestMapFrame.DetailsFrame.RewardsFrame.Background:SetTexCoord(0, 1, 0, height / 275);

	QuestMapFrame.QuestsFrame:Hide();
	QuestMapFrame.DetailsFrame:Show();

	-- save current view
	QuestMapFrame.DetailsFrame.returnMapID = QuestMapFrame:GetParent():GetMapID();

	-- destination/waypoint
	local ignoreWaypoints = false;
	if C_QuestLog.GetNextWaypoint(questID) then
		ignoreWaypoints = ignoreWaypointsByQuestID[questID];
		QuestMapFrame.DetailsFrame.DestinationMapButton:SetShown(not ignoreWaypoints);
		QuestMapFrame.DetailsFrame.WaypointMapButton:SetShown(ignoreWaypoints);
	else
		QuestMapFrame.DetailsFrame.DestinationMapButton:Hide();
		QuestMapFrame.DetailsFrame.WaypointMapButton:Hide();
	end

	local mapID = GetQuestUiMapID(questID, ignoreWaypoints);
	QuestMapFrame.DetailsFrame.questMapID = mapID;
	if ( mapID ~= 0 ) then
		QuestMapFrame:GetParent():SetMapID(mapID);
	end

	QuestMapFrame_UpdateQuestDetailsButtons();
	QuestMapFrame_AdjustPathButtons();

	local quest = QuestCache:Get(questID);
	if not quest:IsDisabledForSession() and quest:IsComplete() and quest.isAutoComplete then
		QuestMapFrame.DetailsFrame.CompleteQuestFrame:Show();
		QuestMapFrame.DetailsFrame.RewardsFrame:SetPoint("BOTTOMLEFT", 0, 44);
	else
		QuestMapFrame.DetailsFrame.CompleteQuestFrame:Hide();
		QuestMapFrame.DetailsFrame.RewardsFrame:SetPoint("BOTTOMLEFT", 0, 20);
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
	QuestFrame_HideQuestPortrait(optPortraitOwnerCheckFrame);

	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
end

function QuestMapFrame_PingQuestID(questId)
	QuestMapFrame:GetParent():PingQuestID(questId);
end

function QuestMapFrame_UpdateSuperTrackedQuest(self)
	local questID = C_SuperTrack.GetSuperTrackedQuestID();
	if ( questID ~= QuestMapFrame.DetailsFrame.questID ) then
		QuestMapFrame_CloseQuestDetails(self:GetParent());
		QuestPOI_SelectButtonByQuestID(QuestScrollFrame.Contents, questID);
	end
end

function QuestMapFrame_UpdateQuestDetailsButtons()
	local questID = C_QuestLog.GetSelectedQuest();

	local isQuestDisabled = C_QuestLog.IsQuestDisabledForSession(questID);

	local canAbandon = not isQuestDisabled and C_QuestLog.CanAbandonQuest(questID);
	QuestMapFrame.DetailsFrame.AbandonButton:SetEnabled(canAbandon);
	QuestLogPopupDetailFrame.AbandonButton:SetEnabled(canAbandon);

	local isWatched = QuestUtils_IsQuestWatched(questID);
	if isWatched then
		QuestMapFrame.DetailsFrame.TrackButton:SetText(UNTRACK_QUEST_ABBREV);
		QuestLogPopupDetailFrame.TrackButton:SetText(UNTRACK_QUEST_ABBREV);
	else
		QuestMapFrame.DetailsFrame.TrackButton:SetText(TRACK_QUEST_ABBREV);
		QuestLogPopupDetailFrame.TrackButton:SetText(TRACK_QUEST_ABBREV);
	end

	-- Need to be able to remove watch if the quest got disabled
	local enableTrackButton = isWatched or not isQuestDisabled;
	QuestMapFrame.DetailsFrame.TrackButton:SetEnabled(enableTrackButton);
	QuestLogPopupDetailFrame.TrackButton:SetEnabled(enableTrackButton);

	local enableShare = not isQuestDisabled and C_QuestLog.IsPushableQuest(questID) and IsInGroup();
	QuestMapFrame.DetailsFrame.ShareButton:SetEnabled(enableShare);
	QuestLogPopupDetailFrame.ShareButton:Enable(enableShare);
end

function QuestMapFrame_ReturnFromQuestDetails()
	if ( QuestMapFrame.DetailsFrame.returnMapID ) then
		QuestMapFrame:GetParent():SetMapID(QuestMapFrame.DetailsFrame.returnMapID);
	end
	QuestMapFrame_CloseQuestDetails();
	QuestMapFrame_UpdateQuestSessionState(QuestMapFrame);
end

function QuestMapFrame_OpenToQuestDetails(questID)
	OpenQuestLog();
	QuestMapFrame_ShowQuestDetails(questID);
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
	self.campaignHeaderFramePool = CreateFramePool("FRAME", QuestMapFrame.QuestsFrame.Contents, "CampaignHeaderTemplate");
	self.covenantCallingsHeaderFramePool = CreateFramePool("BUTTON", QuestMapFrame.QuestsFrame.Contents, "CovenantCallingsHeaderTemplate");
	self.CampaignTooltip = CreateFrame("Frame", nil, UIParent, "CampaignTooltipTemplate");
end

-- *****************************************************************************************************
-- ***** QUEST OPTIONS DROPDOWN
-- *****************************************************************************************************

function QuestMapQuestOptionsDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.notCheckable = true;

	info.text = TRACK_QUEST;
	if QuestUtils_IsQuestWatched(self.questID) then
		info.text = UNTRACK_QUEST;
	end
	info.func = function(_, questID) QuestMapQuestOptions_TrackQuest(questID) end;
	info.arg1 = self.questID;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	info.text = SHARE_QUEST;
	info.func = function(_, questID) QuestMapQuestOptions_ShareQuest(questID) end;
	info.arg1 = self.questID;
	if ( not C_QuestLog.IsPushableQuest(self.questID) or not IsInGroup() ) then
		info.disabled = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	if C_QuestLog.CanAbandonQuest(self.questID) then
		info.text = ABANDON_QUEST;
		info.func = function(_, questID) QuestMapQuestOptions_AbandonQuest(questID) end;
		info.arg1 = self.questID;
		info.disabled = nil;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

function QuestMapQuestOptions_TrackQuest(questID)
	if QuestUtils_IsQuestWatched(questID) then
		QuestObjectiveTracker_UntrackQuest(nil, questID);
	else
		C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Manual);
		QuestSuperTracking_OnQuestTracked(questID);
	end
end

function QuestMapQuestOptions_ShareQuest(questID)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	QuestLogPushQuest(questLogIndex);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end

local function BuildItemNames(items)
	if items then
		local itemNames = {};
		local item = Item:CreateFromItemID(0);

		for itemIndex, itemID in ipairs(items) do
			item:SetItemID(itemID);
			local itemName = item:GetItemName();
			if itemName then
				table.insert(itemNames, itemName);
			end
		end

		if #itemNames > 0 then
			return table.concat(itemNames, ", ");
		end
	end

	return nil;
end

function QuestMapQuestOptions_AbandonQuest(questID)
	local oldSelectedQuest = C_QuestLog.GetSelectedQuest();
	C_QuestLog.SetSelectedQuest(questID);
	C_QuestLog.SetAbandonQuest();

	local items = BuildItemNames(C_QuestLog.GetAbandonQuestItems());
	local title = QuestUtils_GetQuestName(C_QuestLog.GetAbandonQuest());
	if ( items ) then
		StaticPopup_Hide("ABANDON_QUEST");
		StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", title, items);
	else
		StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
		StaticPopup_Show("ABANDON_QUEST", title);
	end
	C_QuestLog.SetSelectedQuest(oldSelectedQuest);
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

local function QuestLogQuests_GetTitle(displayState, info)
	local title = info.title;

	if displayState.displayQuestID then
		title = info.questID.." - "..title;
	end

	if displayState.showReadyToRecord then
		if info.readyForTranslation ~= nil then
			if info.readyForTranslation == false then
				title = "<Not Ready for Translation> " .. title;
			end
		end
	end

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		title = "["..info.difficultyLevel.."] "..title;
	end

	-- If not a header see if any nearby group mates are on this quest
	local partyMembersOnQuest = QuestUtils_GetNumPartyMembersOnQuest(info.questID);

	if partyMembersOnQuest > 0 then
		title = "["..partyMembersOnQuest.."] "..title;
	end

	return title;
end

local function QuestLogQuests_ShouldShowQuestButton(info)
	-- If it's not a quest, then it shouldn't show as a quest button
	if info.isHeader then
		return false;
	end

	-- If it is a quest, but its header is collapsed, then it shouldn't show
	if info.header and info.header.isCollapsed then
		return false;
	end

	-- Normal rules about quest visibility.
	-- NOTE: IsComplete checks should be cached if possible...coming soon...
	return not info.isTask and not info.isHidden and (not info.isBounty or C_QuestLog.IsComplete(info.questID));
end

local function QuestLogQuests_ShouldShowHeaderButton(info)
	-- NOTE: Info must refer to a header and it shouldDisplay must have been determined in advance.
	return info.isHeader and info.shouldDisplay;
end

local function QuestLogQuests_BuildSingleQuestInfo(questLogIndex, questInfoContainer, lastHeader)
	local info = C_QuestLog.GetInfo(questLogIndex);
	if not info then return end

	questInfoContainer[questLogIndex] = info;

	-- Precompute whether or not the headers should display so that it's easier to add them later.
	-- We don't care about collapsed states, we only care about the fact that there are any quests
	-- to display under the header.
	-- Caveat: Campaign headers will always display, otherwise they wouldn't be added to the quest log!
	if info.isHeader then
		lastHeader = info;

		local isCampaign = info.campaignID ~= nil;
		info.shouldDisplay = isCampaign; -- Always display campaign headers, the rest start as hidden
	else
		info.isCalling = C_QuestLog.IsQuestCalling(info.questID);

		if lastHeader and not lastHeader.shouldDisplay then
			lastHeader.shouldDisplay = QuestLogQuests_ShouldShowQuestButton(info);
		end

		-- Make it easy for a quest to look up its header
		info.header = lastHeader;

		-- Might as well just keep this in Lua
		if info.isCalling and info.header then
			info.header.isCalling = true;
		end
	end

	return lastHeader;
end

local function QuestLogQuests_BuildQuestInfoContainer()
	local questInfoContainer = {};
	local numEntries = C_QuestLog.GetNumQuestLogEntries();
	local lastHeader;

	for questLogIndex = 1, numEntries do
		lastHeader = QuestLogQuests_BuildSingleQuestInfo(questLogIndex, questInfoContainer, lastHeader);
	end

	return questInfoContainer;
end

local function QuestLogQuests_GetCampaignInfos(questInfoContainer)
	local infos = {};

	-- questInfoContainer is sorted with all campaigns coming first
	for index, info in ipairs(questInfoContainer) do
		if info.campaignID then
			table.insert(infos, info);
		else
			break;
		end
	end

	return infos;
end

local function QuestLogQuests_GetCovenantCallingsInfos(questInfoContainer)
	local infos = {};

	for index, info in ipairs(questInfoContainer) do
		if info.isCalling then
			table.insert(infos, info);
		end
	end

	return infos;
end

local function QuestLogQuests_GetQuestInfos(questInfoContainer)
	local infos = {};

	for index, info in ipairs(questInfoContainer) do
		if not info.campaignID and not info.isCalling then
			table.insert(infos, info);
		end
	end

	return infos;
end

local function QuestLogQuests_ShouldDisplayPOIButton(displayState, info, isDisabledQuest)
	return (info.hasLocalPOI or isDisabledQuest) and displayState.questPOI;
end

local function QuestLogQuests_GetPOIButton(displayState, info, isDisabledQuest, isComplete)
	if isDisabledQuest then
		return QuestPOI_GetButton(QuestScrollFrame.Contents, info.questID, "disabled", nil);
	elseif isComplete then
		return QuestPOI_GetButton(QuestScrollFrame.Contents, info.questID, "normal", nil);
	else
		for index, poiQuestID in ipairs(displayState.poiTable) do
			if poiQuestID == info.questID then
				return QuestPOI_GetButton(QuestScrollFrame.Contents, info.questID, "numeric", index);
			end
		end
	end
end

local function QuestLogQuests_GetBestTagID(questID, info, isComplete)
	if isComplete then
		return "COMPLETED";
	end

	-- At this point, we know the quest is not complete, no need to check it any more.
	if C_QuestLog.IsFailed(questID) then
		return "FAILED";
	end

	if info.isCalling then
		local secondsRemaining = C_TaskQuest.GetQuestTimeLeftSeconds(questID);
		if secondsRemaining then
			if secondsRemaining < 3600 then -- 1 hour
				return "EXPIRING_SOON";
			elseif secondsRemaining < 18000 then -- 5 hours
				return "EXPIRING";
			end
		end
	end

	local tagInfo = C_QuestLog.GetQuestTagInfo(questID);
	local questTagID = tagInfo and tagInfo.tagID;

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

local function QuestLogQuests_AddQuestButton(displayState, info)
	local button = QuestScrollFrame.titleFramePool:Acquire();
	local questID = info.questID;
	local questLogIndex = info.questLogIndex;

	button.info = info;
	button.questID = questID;
	button.questLogIndex = questLogIndex;

	QuestMapFrame:SetFrameLayoutIndex(button);

	local title = QuestLogQuests_GetTitle(displayState, info);

	local ignoreReplayable = false;
	local ignoreDisabled = true;
	local useLargeIcon = false;
	button.Text:SetText(QuestUtils_DecorateQuestText(questID, title, useLargeIcon, ignoreReplayable, ignoreDisabled));

	local difficultyColor = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID));
	button.Text:SetTextColor(difficultyColor.r, difficultyColor.g, difficultyColor.b);

	if C_QuestLog.GetQuestWatchType(questID) == Enum.QuestWatchType.Manual then
		button.Check:Show();
		button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth() + 2, 0);
	else
		button.Check:Hide();
	end

	-- tag. daily icon can be alone or before other icons except for COMPLETED or FAILED
	local isComplete = C_QuestLog.IsComplete(questID);
	local tagID = QuestLogQuests_GetBestTagID(questID, info, isComplete);
	local tagCoords = tagID and QUEST_TAG_TCOORDS[tagID];
	button.TagTexture:SetShown(tagCoords ~= nil);

	if tagCoords then
		button.TagTexture:SetTexCoord(unpack(tagCoords));
		button.TagTexture:SetDesaturated(C_QuestLog.IsQuestDisabledForSession(questID));
	end

	-- POI/objectives
	local requiredMoney = C_QuestLog.GetRequiredMoney(questID);
	local playerMoney = GetMoney();
	local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
	local isDisabledQuest = C_QuestLog.IsQuestDisabledForSession(questID);
	local totalHeight = 8 + button.Text:GetHeight();

	-- objectives
	if isComplete then
		local objectiveFrame = QuestScrollFrame.objectiveFramePool:Acquire();
		objectiveFrame.questID = questID;
		objectiveFrame:Show();
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		objectiveFrame.Text:SetText(completionText);
		SetupObjectiveTextColor(objectiveFrame.Text, isDisabledQuest, false);
		local height = objectiveFrame.Text:GetStringHeight();
		objectiveFrame:SetHeight(height);
		objectiveFrame:SetPoint("TOPLEFT", button.Text, "BOTTOMLEFT", 0, -3);
		totalHeight = totalHeight + height + 3;
	else
		local prevObjective;
		for i = 1, numObjectives do
			local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
			if text and not finished then
				local objectiveFrame = QuestScrollFrame.objectiveFramePool:Acquire();
				objectiveFrame.questID = questID;
				objectiveFrame:Show();
				objectiveFrame.Text:SetText(text);
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

	if QuestLogQuests_ShouldDisplayPOIButton(displayState, info, isDisabledQuest) then
		local poiButton = QuestLogQuests_GetPOIButton(displayState, info, isDisabledQuest, isComplete);
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
	button:ClearAllPoints();

	if displayState.prevButton then
		button:SetPoint("TOPLEFT", displayState.prevButton, "BOTTOMLEFT", 0, 0);
	else
		button:SetPoint("TOPLEFT", 1, -6);
	end

	button:Show();
	displayState.prevButton = button;
	displayState.prevButtonInfo = info;
end

local function QuestLogQuests_GetPreviousButtonInfo(displayState)
	return displayState.prevButtonInfo;
end

local function QuestLogQuests_IsPreviousButtonCollapsed(displayState)
	local info = QuestLogQuests_GetPreviousButtonInfo(displayState);
	if info then
		return info.isHeader and info.isCollapsed;
	end

	return false;
end

local function QuestLogQuests_AddCampaignHeaderButton(displayState, info)
	local button = QuestScrollFrame.campaignHeaderFramePool:Acquire();
	button:SetCampaignFromQuestHeader(info);

	button.questLogIndex = info.questLogIndex;
	QuestMapFrame:SetFrameLayoutIndex(button);

	-- Only set campaignShown to true, once it's true it should remain true for this display
	-- NOTE: The topPadding hack is due to the container being a vertical layout frame, we don't want spacing
	-- on the other elements, and we need the first header
	if not displayState.campaignShown and button:IsShown() and not button:GetCampaign():IsComplete() then
		displayState.campaignShown = true;
		button.topPadding = 0;
	else
		if QuestLogQuests_IsPreviousButtonCollapsed(displayState) then
			button.topPadding = 0;
		else
			button.topPadding = 12;
		end
	end

	return button;
end

local function QuestLogQuests_SetupStandardHeaderButton(button, displayState, info)
	button:SetNormalAtlas(info.isCollapsed and "Campaign_HeaderIcon_Closed" or "Campaign_HeaderIcon_Open" );
	button:SetPushedAtlas(info.isCollapsed and "Campaign_HeaderIcon_ClosedPressed" or "Campaign_HeaderIcon_OpenPressed");
	button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
	button:SetHitRectInsets(0, -button.ButtonText:GetWidth(), 0, 0);

	button.questLogIndex = info.questLogIndex;
	QuestMapFrame:SetFrameLayoutIndex(button);

	return button;
end

CovenantCallingsHeaderMixin = {};

function CovenantCallingsHeaderMixin:OnLoadCovenantCallings()
	EventRegistry:RegisterCallback("CovenantCallings.CallingsUpdated", self.UpdateText, self);
end

function CovenantCallingsHeaderMixin:UpdateBG()
	local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());

	if covenantData then
		local bgAtlas = GetFinalNameFromTextureKit("Callings-Header-%s", covenantData.textureKit);
		self.HighlightBackground:SetAtlas(bgAtlas, TextureKitConstants.UseAtlasSize);
		self.Background:SetAtlas(bgAtlas, TextureKitConstants.UseAtlasSize);
	end
end

function CovenantCallingsHeaderMixin:UpdateText()
	self:SetText(QUEST_LOG_COVENANT_CALLINGS_HEADER:format(CovenantCalling_GetCompletedCount(), Constants.Callings.MaxCallings));
end

local function QuestLogQuests_AddCovenantCallingsHeaderButton(displayState, info)
	local button = QuestScrollFrame.covenantCallingsHeaderFramePool:Acquire();
	QuestLogQuests_SetupStandardHeaderButton(button, displayState, info);
	button.SelectedTexture:SetShown(not info.isCollapsed);
	CovenantCalling_CheckCallings();
	button:UpdateText();
	button:UpdateBG();

	button.topPadding = 20; -- Set the default
	if QuestLogQuests_IsPreviousButtonCollapsed(displayState) then
		button.topPadding = 0;
	end

	return button;
end

local function QuestLogQuests_AddStandardHeaderButton(displayState, info)
	local button = QuestScrollFrame.headerFramePool:Acquire();
	QuestLogQuests_SetupStandardHeaderButton(button, displayState, info);
	button:SetText(info.title);

	-- Handle the case where there's nothing above this quest header
	button.topPadding = 0;
	if not QuestLogQuests_GetPreviousButtonInfo(displayState) then
		button.topPadding = 8;
	end

	return button;
end

local function QuestLogQuests_AddHeaderButton(displayState, info)
	displayState.hasShownAnyHeader = true;

	local button;
	if info.campaignID then
		button = QuestLogQuests_AddCampaignHeaderButton(displayState, info);
	elseif info.isCalling then
		button = QuestLogQuests_AddCovenantCallingsHeaderButton(displayState, info);
	else
		button = QuestLogQuests_AddStandardHeaderButton(displayState, info);
	end

	button:ClearAllPoints();
	if displayState.prevButton then
		button:SetPoint("TOPLEFT", displayState.prevButton, "BOTTOMLEFT", 0, 0);
	else
		button:SetPoint("TOPLEFT", 1, -6);
	end

	displayState.prevButton = button;
	displayState.prevButtonInfo = info;
	button:Show();
end

local function QuestLogQuests_DisplayQuestButton(displayState, info)
	-- TODO: This is a work-around for quest sharing potentially signalling a UI update when nothing is actually in the quest log.
	-- Figure out the real fix (probably related to waiting until quests have stablized)
	if not (info and info.title) then
		return;
	end

	if QuestLogQuests_ShouldShowHeaderButton(info) then
		QuestLogQuests_AddHeaderButton(displayState, info);
	elseif QuestLogQuests_ShouldShowQuestButton(info) then
		QuestLogQuests_AddQuestButton(displayState, info);
	end
end

local function QuestLogQuests_IsDisplayEmpty(displayState)
	return not displayState.hasShownAnyHeader and QuestScrollFrame.titleFramePool:GetNumActive() == 0;
end

local function QuestLogQuests_UpdateBackground(displayState)
	local atlas = QuestLogQuests_IsDisplayEmpty(displayState) and "NoQuestsBackground" or "QuestLogBackground";
	QuestMapFrame.Background:SetAtlas(atlas, true);
end

local function QuestLogQuests_BuildInitialDisplayState(poiTable, questInfoContainer)
	return {
		questInfoContainer = questInfoContainer,
		poiTable = poiTable,
		displayQuestID = GetCVarBool("displayQuestID"),
		showReadyToRecord = GetCVarBool("showReadyToRecord"),
		questPOI = GetCVarBool("questPOI"),
	};
end

local function QuestLogQuests_DisplayQuestsFromIndices(displayState, infos)
	for index, info in ipairs(infos) do
		QuestLogQuests_DisplayQuestButton(displayState, info);
	end
end

function QuestLogQuests_Update(poiTable)
	QuestScrollFrame.titleFramePool:ReleaseAll();
	QuestScrollFrame.objectiveFramePool:ReleaseAll();
	QuestScrollFrame.headerFramePool:ReleaseAll();
	QuestScrollFrame.campaignHeaderFramePool:ReleaseAll();
	QuestScrollFrame.covenantCallingsHeaderFramePool:ReleaseAll();
	QuestPOI_ResetUsage(QuestScrollFrame.Contents);
	QuestMapFrame:ResetLayoutIndex();

	-- Build the info table, to determine what needs to be displayed
	local questInfoContainer = QuestLogQuests_BuildQuestInfoContainer();
	local campaignInfos = QuestLogQuests_GetCampaignInfos(questInfoContainer);
	local covenantCallingsInfos = QuestLogQuests_GetCovenantCallingsInfos(questInfoContainer);
	local questInfos = QuestLogQuests_GetQuestInfos(questInfoContainer);
	local displayState = QuestLogQuests_BuildInitialDisplayState(poiTable, questInfoContainer);

	-- Display all campaigns
	QuestLogQuests_DisplayQuestsFromIndices(displayState, campaignInfos);
	QuestLogQuests_DisplayQuestsFromIndices(displayState, covenantCallingsInfos);

	-- Display the zone story stuff if appropriate, updating separators as necessary...TODO: Refactor this out as well
	local mapID = QuestMapFrame:GetParent():GetMapID();
	local storyAchievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(mapID);

	local separator = QuestScrollFrame.Contents.Separator;
	separator:SetShown(displayState.campaignShown);
	if displayState.campaignShown then
		QuestMapFrame:SetFrameLayoutIndex(separator);
		if storyAchievementID then
			separator.Divider:SetAtlas("ZoneStory_Divider", true);
		else
			separator.Divider:SetAtlas("QuestLog_Divider_NormalQuests", true);
		end
	end

	if storyAchievementID then
		if displayState.campaignShown then
			QuestScrollFrame.Contents.StoryHeader.topPadding = -18;
		else
			QuestScrollFrame.Contents.StoryHeader.topPadding = -4;
		end

		QuestScrollFrame.Contents.StoryHeader:Show();
		QuestMapFrame:SetFrameLayoutIndex(QuestScrollFrame.Contents.StoryHeader);
		local mapInfo = C_Map.GetMapInfo(storyMapID);
		QuestScrollFrame.Contents.StoryHeader.Text:SetText(mapInfo and mapInfo.name or nil);
		local numCriteria = GetAchievementNumCriteria(storyAchievementID);
		local completedCriteria = 0;
		for i = 1, numCriteria do
			local _, _, completed = GetAchievementCriteriaInfo(storyAchievementID, i);
			if ( completed ) then
				completedCriteria = completedCriteria + 1;
			end
		end
		QuestScrollFrame.Contents.StoryHeader.Progress:SetFormattedText(QUEST_STORY_STATUS, completedCriteria, numCriteria);
		displayState.prevButton = QuestScrollFrame.Contents.StoryHeader;
	else
		QuestScrollFrame.Contents.StoryHeader:Hide();
	end

	-- Display the rest of the normal quests and their headers.
	QuestLogQuests_DisplayQuestsFromIndices(displayState, questInfos);

	QuestLogQuests_UpdateBackground(displayState);
	QuestPOI_SelectButtonByQuestID(QuestScrollFrame.Contents, C_SuperTrack.GetSuperTrackedQuestID());
	QuestPOI_HideUnusedButtons(QuestScrollFrame.Contents);
	QuestScrollFrame.Contents:Layout();
end

function ToggleQuestLog()
	if ( QuestMapFrame:IsShown() and QuestMapFrame:IsVisible() ) then
		HideUIPanel(QuestMapFrame:GetParent());
	else
		OpenQuestLog();
	end
end

function OpenQuestLog(mapID)
	QuestMapFrame:GetParent():OnQuestLogOpen();
	ShowUIPanel(QuestMapFrame:GetParent());
	QuestMapFrame_Open();

	if mapID then
		QuestMapFrame:GetParent():SetMapID(mapID);
	end
end

function QuestMapLogTitleButton_OnEnter(self)
	-- do block highlight
	local info = C_QuestLog.GetInfo(self.questLogIndex);
	assert(info and not info.isHeader);
	local isComplete = C_QuestLog.IsComplete(info.questID);
	local questID = info.questID;

	local difficultyHighlightColor;
	if isHeader then
		difficultyHighlightColor = QuestDifficultyHighlightColors["header"];
	else
		difficultyHighlightColor = select(2, GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID)));
	end

	self.Text:SetTextColor(difficultyHighlightColor.r, difficultyHighlightColor.g, difficultyHighlightColor.b);

	local isDisabledQuest = C_QuestLog.IsQuestDisabledForSession(questID);
	for line in QuestScrollFrame.objectiveFramePool:EnumerateActive() do
		if ( line.questID == questID ) then
			SetupObjectiveTextColor(line.Text, isDisabledQuest, true);
		end
	end

	QuestMapFrame:GetParent():SetHighlightedQuestID(questID);

	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 34, 0);
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:SetText(info.title);
	local tooltipWidth = 20 + max(231, GameTooltipTextLeft1:GetStringWidth());
	if ( tooltipWidth > UIParent:GetRight() - QuestMapFrame:GetParent():GetRight() ) then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0);
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:SetText(info.title);
	end

	if C_QuestLog.IsQuestReplayable(questID) then
		GameTooltip_AddInstructionLine(GameTooltip, QuestUtils_GetReplayQuestDecoration(questID)..QUEST_SESSION_QUEST_TOOLTIP_IS_REPLAY, false);
	elseif C_QuestLog.IsQuestDisabledForSession(questID) then
		GameTooltip_AddColoredLine(GameTooltip, QuestUtils_GetDisabledQuestDecoration(questID)..QUEST_SESSION_ON_HOLD_TOOLTIP_TITLE, DISABLED_FONT_COLOR, false);
	end

	-- quest tag
	local tagInfo = C_QuestLog.GetQuestTagInfo(questID);
	if ( tagInfo ) then
		local tagName = tagInfo.tagName;
		local factionGroup = GetQuestFactionGroup(questID);
		-- Faction-specific account quests have additional info in the tooltip
		if ( tagInfo.tagID == Enum.QuestTag.Account and factionGroup ) then
			local factionString = FACTION_ALLIANCE;
			if ( factionGroup == LE_QUEST_FACTION_HORDE ) then
				factionString = FACTION_HORDE;
			end
			tagName = format("%s (%s)", tagName, factionString);
		end

		local overrideQuestTag = tagInfo.tagID;
		if ( QUEST_TAG_TCOORDS[tagInfo.tagID] ) then
			if ( tagInfo.tagID == Enum.QuestTag.Account and factionGroup ) then
				overrideQuestTag = "ALLIANCE";
				if ( factionGroup == LE_QUEST_FACTION_HORDE ) then
					overrideQuestTag = "HORDE";
				end
			end
		end

		QuestUtils_AddQuestTagLineToTooltip(GameTooltip, tagName, overrideQuestTag, tagInfo.worldQuestType, NORMAL_FONT_COLOR);
	end

	GameTooltip_CheckAddQuestTimeToTooltip(GameTooltip, questID);

	if ( info.frequency == Enum.QuestFrequency.Daily ) then
		QuestUtils_AddQuestTagLineToTooltip(GameTooltip, DAILY, "DAILY", nil, NORMAL_FONT_COLOR);
	elseif ( info.frequency == Enum.QuestFrequency.Weekly ) then
		QuestUtils_AddQuestTagLineToTooltip(GameTooltip, WEEKLY, "WEEKLY", nil, NORMAL_FONT_COLOR);
	end

	if C_QuestLog.IsFailed(info.questID) then
		QuestUtils_AddQuestTagLineToTooltip(GameTooltip, FAILED, "FAILED", nil, RED_FONT_COLOR);
	end

	GameTooltip:AddLine(" ");

	-- description
	if isComplete then
		local completionText = GetQuestLogCompletionText(self.questLogIndex) or QUEST_WATCH_QUEST_READY;
		GameTooltip:AddLine(completionText, 1, 1, 1, true);
		GameTooltip:AddLine(" ");
	else
		local needsSeparator = false;
		local _, objectiveText = GetQuestLogQuestText(self.questLogIndex);
		GameTooltip:AddLine(objectiveText, 1, 1, 1, true);
		GameTooltip:AddLine(" ");
		local requiredMoney = C_QuestLog.GetRequiredMoney(questID);
		local numObjectives = GetNumQuestLeaderBoards(self.questLogIndex);
		for i = 1, numObjectives do
			local text, objectiveType, finished = GetQuestLogLeaderBoard(i, self.questLogIndex);
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

	if QuestUtils_GetNumPartyMembersOnQuest(questID) > 0 then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(PARTY_QUEST_STATUS_ON);

		local omitTitle = true;
		local ignoreActivePlayer = true;
		GameTooltip:SetQuestPartyProgress(questID, omitTitle, ignoreActivePlayer);
	end

	GameTooltip:Show();
	tooltipButton = self;
end

function QuestMapLogTitleButton_OnLeave(self)
	-- remove block highlight
	local info = C_QuestLog.GetInfo(self.questLogIndex);
	if info then
		local difficultyColor = info.isHeader and QuestDifficultyColors["header"] or GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(info.questID));
		self.Text:SetTextColor( difficultyColor.r, difficultyColor.g, difficultyColor.b );

		local isDisabledQuest = C_QuestLog.IsQuestDisabledForSession(info.questID);
		for line in QuestScrollFrame.objectiveFramePool:EnumerateActive() do
			if ( line.questID == info.questID ) then
				SetupObjectiveTextColor(line.Text, isDisabledQuest, false);
			end
		end
	end

	QuestMapFrame:GetParent():ClearHighlightedQuestID();
	GameTooltip:Hide();
	tooltipButton = nil;
end

function QuestMapLogTitleButton_OnClick(self, button)
	if ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local isDisabledQuest = C_QuestLog.IsQuestDisabledForSession(self.questID);
	if not isDisabledQuest and IsShiftKeyDown() then
		QuestMapQuestOptions_TrackQuest(self.questID);
	else
		if not isDisabledQuest and button == "RightButton" then
			if ( self.questID ~= QuestMapQuestOptionsDropDown.questID ) then
				CloseDropDownMenus();
			end
			QuestMapQuestOptionsDropDown.questID = self.questID;
			ToggleDropDownMenu(1, nil, QuestMapQuestOptionsDropDown, "cursor", 6, -6);
		elseif button == "LeftButton" then
			QuestMapFrame_ShowQuestDetails(self.questID);
		end
	end
end

function QuestMapLogTitleButton_OnMouseDown(self)
	local anchor, _, _, x, y = self.Text:GetPoint();
	self.Text:SetPoint(anchor, x + 1, y - 1);
	anchor, _, _, x, y = self.TagTexture:GetPoint(2);
	self.TagTexture:SetPoint(anchor, x + 1, y - 1);
end

function QuestMapLogTitleButton_OnMouseUp(self)
	local anchor, _, _, x, y = self.Text:GetPoint();
	self.Text:SetPoint(anchor, x - 1, y + 1);
	anchor, _, _, x, y = self.TagTexture:GetPoint(2);
	self.TagTexture:SetPoint(anchor, x - 1, y + 1);
end

function QuestMapLog_ShowStoryTooltip(self)
	local tooltip = QuestScrollFrame.StoryTooltip;
	local mapID = QuestMapFrame:GetParent():GetMapID();
	local storyAchievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(mapID);
	local maxWidth = 0;
	local totalHeight = 0;

	local mapInfo = C_Map.GetMapInfo(storyMapID);
	tooltip.Title:SetText(mapInfo.name);
	totalHeight = totalHeight + tooltip.Title:GetHeight();
	maxWidth = tooltip.Title:GetWidth();

	-- Clear out old quest criteria
	for i = 1, #tooltip.Lines do
		tooltip.Lines[i]:Hide();
	end
	for _, checkMark in pairs(tooltip.CheckMarks) do
		checkMark:Hide();
	end

	local numCriteria = GetAchievementNumCriteria(storyAchievementID);
	local completedCriteria = 0;
	for i = 1, numCriteria do
		local title, _, completed = GetAchievementCriteriaInfo(storyAchievementID, i);
		if ( completed ) then
			completedCriteria = completedCriteria + 1;
		end
		if ( not tooltip.Lines[i] ) then
			local fontString = tooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			fontString:SetPoint("TOP", tooltip.Lines[i-1], "BOTTOM", 0, -6);
			tooltip.Lines[i] = fontString;
		end
		if ( completed ) then
			tooltip.Lines[i]:SetText(GREEN_FONT_COLOR_CODE..title..FONT_COLOR_CODE_CLOSE);
			tooltip.Lines[i]:SetPoint("LEFT", 30, 0);
			if ( not tooltip.CheckMarks[i] ) then
				local texture = tooltip:CreateTexture(nil, "ARTWORK", "GreenCheckMarkTemplate");
				texture:ClearAllPoints();
				texture:SetPoint("RIGHT", tooltip.Lines[i], "LEFT", -4, -1);
				tooltip.CheckMarks[i] = texture;
			end
			tooltip.CheckMarks[i]:Show();
			maxWidth = max(maxWidth, tooltip.Lines[i]:GetWidth() + 20);
		else
			tooltip.Lines[i]:SetText(title);
			tooltip.Lines[i]:SetPoint("LEFT", 10, 0);
			if ( tooltip.CheckMarks[i] ) then
				tooltip.CheckMarks[i]:Hide();
			end
			maxWidth = max(maxWidth, tooltip.Lines[i]:GetWidth());
		end
		tooltip.Lines[i]:Show();
		totalHeight = totalHeight + tooltip.Lines[i]:GetHeight() + 6;
	end

	tooltip.ProgressCount:SetFormattedText(STORY_CHAPTERS, completedCriteria, numCriteria);
	maxWidth = max(maxWidth, tooltip.ProgressLabel:GetWidth(), tooltip.ProgressCount:GetWidth());
	totalHeight = totalHeight + tooltip.ProgressLabel:GetHeight() + tooltip.ProgressCount:GetHeight();

	tooltip:ClearAllPoints();
	local tooltipWidth = max(MIN_STORY_TOOLTIP_WIDTH, maxWidth + 20);
	if ( tooltipWidth > UIParent:GetRight() - QuestMapFrame:GetParent():GetRight() ) then
		tooltip:SetPoint("TOPRIGHT", self:GetParent().StoryHeader, "TOPLEFT", -5, 0);
	else
		tooltip:SetPoint("TOPLEFT", self:GetParent().StoryHeader, "TOPRIGHT", 27, 0);
	end
	tooltip:SetSize(tooltipWidth, totalHeight + 42);
	tooltip:Show();
end

function QuestMapLog_HideStoryTooltip(self)
	QuestScrollFrame.StoryTooltip:Hide();
end

function QuestMapLog_GetCampaignTooltip()
	return QuestScrollFrame.CampaignTooltip;
end

-- *****************************************************************************************************
-- ***** POPUP DETAIL FRAME
-- *****************************************************************************************************

function QuestLogPopupDetailFrame_OnLoad(self)
	self.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", self.ScrollFrame, "TOPRIGHT", 6, -14);
end

function QuestLogPopupDetailFrame_OnHide(self)
	self.questID = nil;
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
end

function QuestLogPopupDetailFrame_Show(questLogIndex)
	local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex);
	if ( QuestLogPopupDetailFrame.questID == questID and QuestLogPopupDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogPopupDetailFrame);
		return;
	end

	QuestLogPopupDetailFrame.questID = questID;
	C_QuestLog.SetSelectedQuest(questID);
	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
	C_QuestLog.SetAbandonQuest();

	QuestMapFrame_UpdateQuestDetailsButtons();

	QuestLogPopupDetailFrame_Update(true);
	ShowUIPanel(QuestLogPopupDetailFrame);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);

	-- portrait
	local questPortrait, questPortraitText, questPortraitName, questPortraitMount, questPortraitModelSceneID = C_QuestLog.GetQuestLogPortraitGiver();
	if (questPortrait and questPortrait ~= 0 and QuestLogShouldShowPortrait()) then
		QuestFrame_ShowQuestPortrait(QuestLogPopupDetailFrame, questPortrait, questPortraitMount, questPortraitModelSceneID, questPortraitText, questPortraitName, -3, -42);
	else
		QuestFrame_HideQuestPortrait();
	end
end

function QuestLogPopupDetailFrame_Update(resetScrollBar)
	QuestInfo_Display(QUEST_TEMPLATE_LOG, QuestLogPopupDetailFrame.ScrollFrame.ScrollChild)
	if ( resetScrollBar ) then
		QuestLogPopupDetailFrame.ScrollFrame.ScrollBar:SetValue(0);
	end
end
