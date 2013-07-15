-- Who watches the WatchFrame...?

WATCHFRAME_COLLAPSEDWIDTH = 0;		-- set in WatchFrame_OnLoad
WATCHFRAME_EXPANDEDWIDTH = 204;		-- changed in WatchFrame_SetWidth
WATCHFRAME_MAXLINEWIDTH = 192;		-- changed in WatchFrame_SetWidth
WATCHFRAME_LINEHEIGHT = 16;
WATCHFRAME_MULTIPLE_LINEHEIGHT = 0;	-- set in WatchFrame_SetWidth
WATCHFRAME_ITEM_WIDTH = 33;

local DASH_NONE = 0;
local DASH_SHOW = 1;
local DASH_HIDE = 2;
local DASH_ICON = 3;
local DASH_WIDTH;
local DASH_ICON_WIDTH = 20;
local IS_HEADER = true;

WATCHFRAME_INITIAL_OFFSET = 0;
WATCHFRAME_TYPE_OFFSET = 10;
WATCHFRAME_QUEST_OFFSET = 10;

WATCHFRAMELINES_FONTSPACING = 0;
WATCHFRAMELINES_FONTHEIGHT = 0;

WATCHFRAME_MAXQUESTS = 10;
WATCHFRAME_MAXACHIEVEMENTS = 10;
WATCHFRAME_CRITERIA_PER_ACHIEVEMENT = 5;

WATCHFRAME_NUM_TIMERS = 0;
WATCHFRAME_NUM_ITEMS = 0;
WATCHFRAME_NUM_POPUPS = 0;

WATCHFRAME_OBJECTIVEHANDLERS = {};
WATCHFRAME_TIMEDCRITERIA = {};
WATCHFRAME_TIMERLINES = {};
WATCHFRAME_ACHIEVEMENTLINES = {};
WATCHFRAME_QUESTLINES = {};
WATCHFRAME_LINKBUTTONS = {};
local WATCHFRAME_SETLINES = { };			-- buffer to hold lines for a quest/achievement that will be displayed only if there is room
local WATCHFRAME_SETLINES_NUMLINES = 0;		-- the number of visual lines to be rendered for the buffered data - used just for item wrapping right now

CURRENT_MAP_QUESTS = { };
LOCAL_MAP_QUESTS = { };
VISIBLE_WATCHES  = { };

WATCHFRAME_FLAGS = { ["locked"] = 0x01, ["collapsed"] = 0x02 }

WATCHFRAME_ACHIEVEMENT_ARENA_CATEGORY = 165;

local watchFrameTestLine;

WATCHFRAME_SORT_PROXIMITY = 1;
WATCHFRAME_SORT_DIFFICULTY_HIGH = 2;
WATCHFRAME_SORT_DIFFICULTY_LOW = 3;
WATCHFRAME_SORT_MANUAL = 0;
WATCHFRAME_FILTER_ACHIEVEMENTS = 1;
WATCHFRAME_FILTER_COMPLETED_QUESTS = 2;
WATCHFRAME_FILTER_REMOTE_ZONES = 4;
WATCHFRAME_FILTER_NONE = 0;
WATCHFRAME_SORT_TYPE = 0;
WATCHFRAME_FILTER_TYPE = 0;
WATCHFRAME_UPDATE_RATE = 1;

local watchButtonIndex = 1;
local function WatchFrame_GetLinkButton ()
	local button = WATCHFRAME_LINKBUTTONS[watchButtonIndex]
	if ( not button ) then
		WATCHFRAME_LINKBUTTONS[watchButtonIndex] = WatchFrame.buttonCache:GetFrame();
		button = WATCHFRAME_LINKBUTTONS[watchButtonIndex];
	end

	watchButtonIndex = watchButtonIndex + 1;
	return button;
end

local function WatchFrame_ResetLinkButtons ()
	watchButtonIndex = 1;
end

local function WatchFrame_ReleaseUnusedLinkButtons ()
	local watchButton
	for i = watchButtonIndex, #WATCHFRAME_LINKBUTTONS do
		watchButton = WATCHFRAME_LINKBUTTONS[i];
		watchButton.type = nil
		watchButton.index = nil;
		watchButton:Hide();
		watchButton.frameCache:ReleaseFrame(watchButton);
		WATCHFRAME_LINKBUTTONS[i] = nil;
	end
end

function WatchFrameLinkButtonTemplate_OnClick (self, button, pushed)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		if ( self.type == "QUEST" ) then
			local questLink = GetQuestLink(GetQuestIndexForWatch(self.index));
			if ( questLink ) then
				ChatEdit_InsertLink(questLink);
			end
		elseif ( self.type == "ACHIEVEMENT" ) then
			local achievementLink = GetAchievementLink(self.index);
			if ( achievementLink ) then
				ChatEdit_InsertLink(achievementLink);
			end
		end
	elseif ( button ~= "RightButton" ) then
		WatchFrameLinkButtonTemplate_OnLeftClick(self, button);
	else
		local dropDown = WatchFrameDropDown;
		if ( WatchFrame.lastLinkButton ~= self ) then
			CloseDropDownMenus();
		end
		dropDown.type = self.type;
		dropDown.index = self.index;
		WatchFrame.dropDownOpen = true;
		WatchFrame.lastLinkButton = self;
		ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3)
	end
end

function WatchFrameLinkButtonTemplate_OnLeftClick (self, button)
	CloseDropDownMenus();
	if ( self.type == "QUEST" ) then
		if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			WatchFrame_StopTrackingQuest( button, self.index);
		else
			ExpandQuestHeader( GetQuestSortIndex( GetQuestIndexForWatch(self.index) ) );
			-- you have to call GetQuestIndexForWatch again because ExpandQuestHeader will sort the indices
			local questIndex = GetQuestIndexForWatch(self.index);
			if (self.isComplete and GetQuestLogIsAutoComplete(questIndex)) then
				ShowQuestComplete(questIndex);
				WatchFrameAutoQuest_ClearPopUpByLogIndex(questIndex);
			else
				QuestLog_OpenToQuest( questIndex );
			end
		end
		return;
	elseif ( self.type == "ACHIEVEMENT" ) then
		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end
		if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			WatchFrame_StopTrackingAchievement(button, self.index);
		elseif ( not AchievementFrame:IsShown() ) then
			AchievementFrame_ToggleAchievementFrame();
			AchievementFrame_SelectAchievement(self.index);
		else
			if ( AchievementFrameAchievements.selection ~= self.index ) then
				AchievementFrame_SelectAchievement(self.index);
			else
				AchievementFrame_ToggleAchievementFrame();
			end
		end		
		return;
	end		
end

local achievementLineIndex = 1;
local function WatchFrame_GetAchievementLine ()
	local line = WATCHFRAME_ACHIEVEMENTLINES[achievementLineIndex];
	if ( not line ) then
		WATCHFRAME_ACHIEVEMENTLINES[achievementLineIndex] = WatchFrame.lineCache:GetFrame();
		line = WATCHFRAME_ACHIEVEMENTLINES[achievementLineIndex];
	end

	line:Reset();
	achievementLineIndex = achievementLineIndex + 1;
	return line;
end

local function WatchFrame_ResetAchievementLines ()
	achievementLineIndex = 1;
end

local function WatchFrame_ReleaseUnusedAchievementLines ()
	local line
	for i = achievementLineIndex, #WATCHFRAME_ACHIEVEMENTLINES do
		line = WATCHFRAME_ACHIEVEMENTLINES[i];
		line:Hide();
		line.frameCache:ReleaseFrame(line);
		WATCHFRAME_ACHIEVEMENTLINES[i] = nil;
	end
end

local questLineIndex = 1;
local function WatchFrame_GetQuestLine ()
	local line = WATCHFRAME_QUESTLINES[questLineIndex];
	if ( not line ) then
		WATCHFRAME_QUESTLINES[questLineIndex] = WatchFrame.lineCache:GetFrame();
		line = WATCHFRAME_QUESTLINES[questLineIndex];
	end

	line:Reset();
	questLineIndex = questLineIndex + 1;
	return line;
end

local function WatchFrame_ResetQuestLines ()
	questLineIndex = 1;
end

local function WatchFrame_ReleaseUnusedQuestLines ()
	local line
	for i = questLineIndex, #WATCHFRAME_QUESTLINES do
		line = WATCHFRAME_QUESTLINES[i];
		line:Hide();
		line.frameCache:ReleaseFrame(line);
		WATCHFRAME_QUESTLINES[i] = nil;
	end
end

function WatchFrame_OnLoad (self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE");
	self:RegisterEvent("ITEM_PUSH");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("QUEST_AUTOCOMPLETE");
	self:RegisterEvent("SCENARIO_UPDATE");
	self:RegisterEvent("SCENARIO_CRITERIA_UPDATE");
	self:RegisterEvent("CRITERIA_COMPLETE");
	self:RegisterEvent("NEW_WMO_CHUNK");
	self:SetScript("OnSizeChanged", WatchFrame_OnSizeChanged); -- Has to be set here instead of in XML for now due to OnSizeChanged scripts getting run before OnLoad scripts.
	self.lineCache = UIFrameCache:New("FRAME", "WatchFrameLine", WatchFrameLines, "WatchFrameLineTemplate");
	self.buttonCache = UIFrameCache:New("BUTTON", "WatchFrameLinkButton", WatchFrameLines, "WatchFrameLinkButtonTemplate")
	watchFrameTestLine = self.lineCache:GetFrame();
	local titleWidth = WatchFrameTitle:GetWidth();
	WATCHFRAME_COLLAPSEDWIDTH = WatchFrameTitle:GetWidth() + 70;
	local _, fontHeight = watchFrameTestLine.text:GetFont();
	watchFrameTestLine.dash:SetText(QUEST_DASH);
	DASH_WIDTH = watchFrameTestLine.dash:GetWidth();
	WATCHFRAMELINES_FONTHEIGHT = fontHeight;
	WATCHFRAMELINES_FONTSPACING = (WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTHEIGHT) / 2;
	WATCHFRAME_MULTIPLE_LINEHEIGHT = WATCHFRAMELINES_FONTHEIGHT * 2 + 5;
	WatchFrame_AddObjectiveHandler(WatchFrameScenario_DisplayScenario);
	WatchFrame_AddObjectiveHandler(WatchFrameAutoQuest_DisplayAutoQuestPopUps);
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayQuestTimers);
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayTrackedAchievements);
	WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
	WatchFrame.updateTimer = WATCHFRAME_UPDATE_RATE;
end

function WatchFrame_OnEvent (self, event, ...)
	if ( event == "PLAYER_MONEY" and self.watchMoney ) then
		WatchFrame_Update(self);
		if ( self.collapsed ) then
			UIFrameFlash(WatchFrameTitleButtonHighlight, .5, .5, 5, false);
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		SetMapToCurrentZone();		-- forces WatchFrame event via the WORLD_MAP_UPDATE event
	elseif ( event == "QUEST_LOG_UPDATE" and not self.updating ) then -- May as well check here too and save some time
		if ( WatchFrame.showObjectives ) then
			WatchFrame_GetCurrentMapQuests();
		end
		WatchFrame_Update(self);
		if ( self.collapsed ) then
			UIFrameFlash(WatchFrameTitleButtonHighlight, .5, .5, 5, false);
		end
	elseif ( event == "TRACKED_ACHIEVEMENT_UPDATE" ) then
		local achievementID, criteriaID, elapsed, duration = ...;

		if ( not elapsed or not duration ) then
			-- Don't do anything
		elseif ( elapsed >= duration ) then
			WATCHFRAME_TIMEDCRITERIA[criteriaID] = nil;
		else		
			local timedCriteria = WATCHFRAME_TIMEDCRITERIA[criteriaID] or {};
			timedCriteria.achievementID = achievementID;
			timedCriteria.startTime = GetTime() - elapsed;
			timedCriteria.duration = duration;
			WATCHFRAME_TIMEDCRITERIA[criteriaID] = timedCriteria;
		end
		
		if ( self.collapsed ) then
			UIFrameFlash(WatchFrameTitleButtonHighlight, .5, .5, 5, false);
		end
		
		WatchFrame_Update();
	elseif ( event == "ITEM_PUSH" ) then
		WatchFrame_Update();
	elseif ( event == "SCENARIO_UPDATE" ) then
		local newStep = ...;
		if ( newStep ) then
			WatchFrameScenario_UpdateScenario(true);
			-- expand will do an update
			WatchFrame_Expand(self);
		else
			WatchFrameScenario_UpdateScenario();
			WatchFrame_Update();
		end
	elseif ( event == "SCENARIO_CRITERIA_UPDATE" ) then
		local id = ...;
		WatchFrameScenario_UpdateScenario(nil, id);
		WatchFrame_Update();
	elseif ( event == "CRITERIA_COMPLETE" ) then
		local id = ...;
		WatchFrameScenario_UpdateScenario(nil, id);
		WatchFrame_Update();
		if ( not self.collapsed and self:IsShown() ) then
			WatchFrameScenario_PlayCriteriaAnimation(...);
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" or event == "NEW_WMO_CHUNK" ) then
		if ( not WorldMapFrame:IsShown() and WatchFrame.showObjectives ) then
			SetMapToCurrentZone();			-- update the zone to get the right POI numbers for the tracker
		end
	elseif ( event == "WORLD_MAP_UPDATE" or event == "QUEST_POI_UPDATE" and WatchFrame.showObjectives ) then
		WatchFrame_GetCurrentMapQuests();
		WatchFrame_Update();
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		WatchFrame_OnSizeChanged(self);
	elseif ( event == "VARIABLES_LOADED" ) then
		WatchFrame_SetWidth(GetCVar("watchFrameWidth"));
		WATCHFRAME_SORT_TYPE = tonumber(GetCVar("trackerSorting"));
		WATCHFRAME_FILTER_TYPE = tonumber(GetCVar("trackerFilter"));
	elseif ( event == "QUEST_AUTOCOMPLETE" ) then
		local questId = ...;
		if (WatchFrameAutoQuest_AddPopUp(questId, "COMPLETE")) then
			PlaySound("UI_AutoQuestComplete");
		end
	end
end

function WatchFrame_OnUpdate(self, elapsed)
	if ( WATCHFRAME_SORT_TYPE == WATCHFRAME_SORT_PROXIMITY ) then
		self.updateTimer = self.updateTimer - elapsed;
		if ( self.updateTimer < 0 ) then
			if ( SortQuestWatches() ) then
				WatchFrame_Update();
			end
			self.updateTimer = WATCHFRAME_UPDATE_RATE;
		end
	end
end

function WatchFrame_OnSizeChanged(self)
	WatchFrame_ClearDisplay();
	WatchFrame_Update(self)	
end

function WatchFrame_Collapse (self)
	self.collapsed = true;
	self:SetWidth(WATCHFRAME_COLLAPSEDWIDTH);
	WatchFrameLines:Hide();
	local button = WatchFrameCollapseExpandButton;
	local texture = button:GetNormalTexture();
	texture:SetTexCoord(0, 0.5, 0, 0.5);
	texture = button:GetPushedTexture();	
	texture:SetTexCoord(0.5, 1, 0, 0.5);
	WatchFrameScenario_StopCriteriaAnimations();
end

function WatchFrame_Expand (self)
	self.collapsed = nil;
	self:SetWidth(WATCHFRAME_EXPANDEDWIDTH);
	WatchFrameLines:Show();
	local button = WatchFrameCollapseExpandButton;
	local texture = button:GetNormalTexture();
	texture:SetTexCoord(0, 0.5, 0.5, 1);
	texture = button:GetPushedTexture();
	texture:SetTexCoord(0.5, 1, 0.5, 1);
	WatchFrame_Update(self);
end

function GetTimerTextColor (duration, elapsed)
	local START_PERCENTAGE_YELLOW = .66
	local START_PERCENTAGE_RED = .33
	
	local percentageLeft = 1 - ( elapsed / duration )
	if ( percentageLeft > START_PERCENTAGE_YELLOW ) then
		return 1, 1, 1	
	elseif ( percentageLeft > START_PERCENTAGE_RED ) then -- Start fading to yellow by eliminating blue
		local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_YELLOW - START_PERCENTAGE_RED);
		return 1, 1, blueOffset;
	else
		local greenOffset = percentageLeft / START_PERCENTAGE_RED; -- Fade to red by eliminating green
		return 1, greenOffset, 0;
	end
end

function WatchFrame_ClearDisplay ()
	for _, timerLine in pairs(WATCHFRAME_TIMERLINES) do
		timerLine:Reset();
	end
	for _, achievementLine in pairs(WATCHFRAME_ACHIEVEMENTLINES) do
		achievementLine:Reset();
	end
	for _, questLine in pairs(WATCHFRAME_QUESTLINES) do
		questLine:Reset();
	end
	for i = 1, WATCHFRAME_NUM_ITEMS do
		_G["WatchFrameItem" .. i]:Hide();
	end
	QuestPOI_HideAllButtons("WatchFrameLines");
end

function WatchFrame_Update (self)
	self = self or WatchFrame; -- Speeds things up if we pass in this reference when we can conveniently.
	-- Display things in this order: quest timers, achievements, quests, addon subscriptions.
	if ( self.updating ) then
		return;
	end
	
	self.updating = true;
	self.watchMoney = false;
	
	local nextAnchor = nil;
	local lineFrame = WatchFrameLines;
	local maxHeight = (WatchFrame:GetTop() - WatchFrame:GetBottom()); -- Can't use lineFrame:GetHeight() because it could be an invalid rectangle (width of 0)
	
	local maxFrameWidth = WATCHFRAME_MAXLINEWIDTH;
	local maxWidth = 0;
	local maxLineWidth, numObjectives, numPopUps;
	local totalObjectives = 0;
	WATCHFRAME_NUM_POPUPS = 0;
	
	WatchFrame_ResetLinkButtons();
	for i = 1, #WATCHFRAME_OBJECTIVEHANDLERS do
		nextAnchor, maxLineWidth, numObjectives, numPopUps = WATCHFRAME_OBJECTIVEHANDLERS[i](lineFrame, nextAnchor, maxHeight, maxFrameWidth);
		maxWidth = max(maxLineWidth, maxWidth);
		totalObjectives = totalObjectives + numObjectives;
		WATCHFRAME_NUM_POPUPS = WATCHFRAME_NUM_POPUPS + numPopUps;
	end
	
	--disabled for now, might make it an option
	--lineFrame:SetWidth(min(maxWidth, maxFrameWidth));
	
	-- shadow
	if ( WATCHFRAME_NUM_POPUPS > 0) then
		if (not lineFrame.Shadow:IsShown()) then
			lineFrame.Shadow:Show();
			lineFrame.Shadow.FadeIn:Play();
		end
	else
		lineFrame.Shadow:Hide();
	end
	
	if ( totalObjectives > 0 ) then
		WatchFrameHeader:Show();
		WatchFrameCollapseExpandButton:Show();
		WatchFrameTitle:SetText(OBJECTIVES_TRACKER_LABEL.." ("..totalObjectives..")");
		WatchFrameHeader:SetWidth(WatchFrameTitle:GetWidth() + 4);
		-- visible objectives?
		if ( nextAnchor ) then
			if ( self.collapsed and not self.userCollapsed ) then
				WatchFrame_Expand(self);
			end
			WatchFrameCollapseExpandButton:Enable();
		else
			if ( not self.collapsed ) then
				WatchFrame_Collapse(self);
			end
			WatchFrameCollapseExpandButton:Disable();		
		end		
	else
		WatchFrameHeader:Hide();
		WatchFrameCollapseExpandButton:Hide();
	end
	
	WatchFrame_ReleaseUnusedLinkButtons();
	
	self.updating = nil;
end

function WatchFrame_AddObjectiveHandler (func, index)
	local numFunctions = #WATCHFRAME_OBJECTIVEHANDLERS
	for i = 1, numFunctions do
		if ( WATCHFRAME_OBJECTIVEHANDLERS[i] == func ) then
			return;
		end
	end
	
	if ( index ) then
		tinsert(WATCHFRAME_OBJECTIVEHANDLERS, index, func);
	else
		tinsert(WATCHFRAME_OBJECTIVEHANDLERS, func);
	end
	return true;
end

function WatchFrame_RemoveObjectiveHandler (func)
	local numFunctions = #WATCHFRAME_OBJECTIVEHANDLERS
	for i = 1, numFunctions do
		if ( WATCHFRAME_OBJECTIVEHANDLERS[i] == func ) then
			tremove(WATCHFRAME_OBJECTIVEHANDLERS, i);
			return true;
		end
	end
end

function WatchFrame_HandleDisplayQuestTimers (lineFrame, nextAnchor, maxHeight, frameWidth)
	return WatchFrame_DisplayQuestTimers(lineFrame, nextAnchor, maxHeight, frameWidth, GetQuestTimers());
end

local timerLineIndex = 1;
local function WatchFrame_GetTimerLine ()
	local line = WATCHFRAME_TIMERLINES[timerLineIndex];
	if ( not line ) then
		WATCHFRAME_TIMERLINES[timerLineIndex] = WatchFrame.lineCache:GetFrame();
		line = WATCHFRAME_TIMERLINES[timerLineIndex];
	end
	
	line:Reset();
	timerLineIndex = timerLineIndex + 1;
	return line;
end

local function WatchFrame_ResetTimerLines ()
	timerLineIndex = 1;
end

local function WatchFrame_ReleaseUnusedTimerLines ()
	local line
	for i = timerLineIndex, #WATCHFRAME_TIMERLINES do
		line = WATCHFRAME_TIMERLINES[i];
		line:Hide();
		line:SetScript("OnEnter", nil);
		line:SetScript("OnLeave", nil);
		line:EnableMouse(false);
		line.frameCache:ReleaseFrame(line);
		WATCHFRAME_TIMERLINES[i] = nil;
	end
end

function WatchFrame_DisplayQuestTimers (lineFrame, nextAnchor, maxHeight, frameWidth, ...)
	local numTimers = select("#", ...);

	if ( numTimers == 0 ) then
		WatchFrame_ResetTimerLines();
		WatchFrame_ReleaseUnusedTimerLines();
		-- Nothing to see here, move along.
		if ( WATCHFRAME_NUM_TIMERS ~= 0 ) then
			WatchFrameLines_RemoveUpdateFunction(WatchFrame_HandleQuestTimerUpdate);
			WATCHFRAME_NUM_TIMERS = 0;
		end
		return nextAnchor, 0, 0, 0;
	end
	
	WatchFrame_ResetTimerLines();
	
	local lineCache = WatchFrame.lineCache;
	local maxWidth = 0;
	local heightUsed = 0;
	local watchFrame = WatchFrame;
	
	local line = WatchFrame_GetTimerLine();
	line.text:SetText(NORMAL_FONT_COLOR_CODE .. QUEST_TIMERS);
	line:Show();
	line:SetPoint("RIGHT", lineFrame, "RIGHT", 0, 0);
	line:SetPoint("LEFT", lineFrame, "LEFT", 0, 0);
	if (nextAnchor) then
		line:SetPoint("TOP", nextAnchor, "BOTTOM", 0, -WATCHFRAME_TYPE_OFFSET);
	else
		line:SetPoint("TOP", lineFrame, "TOP", 0, -WATCHFRAME_INITIAL_OFFSET)
	end

	heightUsed = heightUsed + line:GetHeight();
	maxWidth = line.text:GetStringWidth();
	
	nextAnchor = line;
	
	for i = 1, numTimers do
		line = WatchFrame_GetTimerLine();
		line.text:SetText(" - " .. SecondsToTime(select(i, ...)));
		line:Show();
		line:SetPoint("RIGHT", lineFrame, "RIGHT", 0, 0);
		line:SetPoint("LEFT", lineFrame, "LEFT", 0, 0);
		line:SetPoint("TOP", nextAnchor, "BOTTOM", 0, 0);
		maxWidth = max(maxWidth, line.text:GetStringWidth());
		line:SetWidth(maxWidth) -- FIXME
		heightUsed = heightUsed + line:GetHeight();
		line:SetScript("OnEnter", function (self) GameTooltip:SetOwner(self); GameTooltip:SetHyperlink(GetQuestLink(GetQuestIndexForTimer(i))); GameTooltip:Show(); end);
		line:SetScript("OnLeave", GameTooltip_Hide);
		line:EnableMouse(true);
		nextAnchor = line;
	end
	
	if ( WATCHFRAME_NUM_TIMERS ~= numTimers ) then
		WATCHFRAME_NUM_TIMERS = numTimers;
		WatchFrameLines_AddUpdateFunction(WatchFrame_HandleQuestTimerUpdate);
	end
	
	WatchFrame_ReleaseUnusedTimerLines();
	return nextAnchor, maxWidth, 0, 0;
end

function WatchFrame_HandleQuestTimerUpdate ()
	return WatchFrame_QuestTimerUpdateFunction(GetQuestTimers());
end

function WatchFrame_QuestTimerUpdateFunction (...)
	local numTimers = select("#", ...);
	
	if ( numTimers ~= WATCHFRAME_NUM_TIMERS ) then
		-- We need to update the entire watch frame, the number of displayed timers has changed.
		return true;
	end
		
	for i = 1, numTimers do
		local line = WATCHFRAME_TIMERLINES[i+1]; -- The first timer line is always the "Quest Timers" line, so skip it.
		local seconds = select(i, ...);
		line.text:SetText(" - " .. SecondsToTime(seconds));
	end
end
	
function WatchFrame_HandleDisplayTrackedAchievements (lineFrame, nextAnchor, maxHeight, frameWidth)
	return WatchFrame_DisplayTrackedAchievements(lineFrame, nextAnchor, maxHeight, frameWidth, GetTrackedAchievements());
end

function WatchFrame_UpdateTimedAchievements (elapsed)
	local numAchievementLines = #WATCHFRAME_ACHIEVEMENTLINES
	local timeNow, timeLeft;
	
	local needsUpdate = false;
	for i = 1, numAchievementLines do
		local line = WATCHFRAME_ACHIEVEMENTLINES[i];
		if ( line and line.criteriaID and WATCHFRAME_TIMEDCRITERIA[line.criteriaID] ) then
			timeNow = timeNow or GetTime();
			timeLeft = math.floor(line.startTime + line.duration - timeNow);
			if ( timeLeft <= 0 ) then
				line.text:SetText(string.format(" - " .. SECONDS_ABBR, 0));
				line.text:SetTextColor(1, 0, 0, 1);
			else
				line.text:SetText(" - " .. SecondsToTime(timeLeft));
				line.text:SetTextColor(GetTimerTextColor(line.duration, line.duration - timeLeft));
				needsUpdate = true;
			end
		end
	end
	
	if ( not needsUpdate ) then
		WatchFrameLines_RemoveUpdateFunction(WatchFrame_UpdateTimedAchievements);
	end
end

function WatchFrame_SetLine(line, anchor, verticalOffset, isHeader, text, dash, hasItem, fullHeight, eligible, usedWidth)
	-- anchor
	if ( anchor ) then
		line:SetPoint("RIGHT", anchor, "RIGHT", 0, 0);
		line:SetPoint("LEFT", anchor, "LEFT", 0, 0);
		line:SetPoint("TOP", anchor, "BOTTOM", 0, verticalOffset);
	end
	-- text
	line.text:SetText(text);
	if ( isHeader ) then
		WATCHFRAME_SETLINES_NUMLINES = 0;
		line.text:SetTextColor(0.75, 0.61, 0);
	else
		--this should be the default, set in WatchFrameLineTemplate_Reset
		if ( eligible ~= nil and eligible == false) then
			line.text.eligible = eligible;
			line.text:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b);
		else
			line.text.eligible = true;
			line.text:SetTextColor(0.8, 0.8, 0.8);
		end
	end
	-- dash
	local usedWidth = usedWidth or 0;
	if ( dash == DASH_SHOW ) then
		line.dash:SetText(QUEST_DASH);
		usedWidth = DASH_WIDTH;
	elseif ( dash == DASH_HIDE ) then
		line.dash:SetText(QUEST_DASH);
		line.dash:Hide();
		usedWidth = DASH_WIDTH;
	elseif ( dash == DASH_ICON ) then
		line.dash:SetWidth(DASH_ICON_WIDTH);
		usedWidth = DASH_ICON_WIDTH;
	end	
	-- multiple lines
	if ( hasItem and WATCHFRAME_SETLINES_NUMLINES < 2 ) then
		usedWidth = usedWidth + WATCHFRAME_ITEM_WIDTH;
	end
	line.text:SetWidth(WATCHFRAME_MAXLINEWIDTH - usedWidth);
	if ( line.text:GetHeight() > WATCHFRAME_LINEHEIGHT ) then
		if ( fullHeight ) then
			line:SetHeight(line.text:GetHeight() + 4);
		else
			line:SetHeight(WATCHFRAME_MULTIPLE_LINEHEIGHT);
			line.text:SetHeight(WATCHFRAME_MULTIPLE_LINEHEIGHT);
		end
		WATCHFRAME_SETLINES_NUMLINES = WATCHFRAME_SETLINES_NUMLINES + 2;
	else
		WATCHFRAME_SETLINES_NUMLINES = WATCHFRAME_SETLINES_NUMLINES + 1;
	end
	tinsert(WATCHFRAME_SETLINES, line);	
end

function WatchFrame_DisplayTrackedAchievements (lineFrame, nextAnchor, maxHeight, frameWidth, ...)
	local _; -- Doing this here thanks to IBLJerry!
	local numTrackedAchievements = select("#", ...);
	local line;
	local achievementTitle;
	local previousLine;
	local linkButton;
	
	local numCriteria, criteriaDisplayed;
	local achievementID, achievementName, completed, description, icon, wasEarnedByMe;
	local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, eligible, achievementCategory;
	local _, instanceType = IsInInstance();
	local displayOnlyArena = ArenaEnemyFrames and ArenaEnemyFrames:IsShown() and (instanceType == "arena");

	local lineWidth = 0;
	local maxWidth = 0;
	local heightUsed = 0;
	local topEdge = 0;
	
	WatchFrame_ResetAchievementLines();	
	if ( bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_ACHIEVEMENTS) == WATCHFRAME_FILTER_ACHIEVEMENTS ) then
		for i = 1, numTrackedAchievements do
			WATCHFRAME_SETLINES = table.wipe(WATCHFRAME_SETLINES or { });
			achievementID = select(i, ...);
			achievementCategory = GetAchievementCategory(achievementID);
			_, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
			if ( not wasEarnedByMe and (not displayOnlyArena) or achievementCategory == WATCHFRAME_ACHIEVEMENT_ARENA_CATEGORY ) then			
				-- achievement name
				line = WatchFrame_GetAchievementLine();
				achievementTitle = line;
				WatchFrame_SetLine(line, previousLine, -WATCHFRAME_QUEST_OFFSET, IS_HEADER, achievementName, DASH_NONE);
				if ( not previousLine ) then
					line:SetPoint("RIGHT", lineFrame, "RIGHT", 0, 0);
					line:SetPoint("LEFT", lineFrame, "LEFT", 0, 0);
					if (nextAnchor) then
						line:SetPoint("TOP", nextAnchor, "BOTTOM", 0, -WATCHFRAME_TYPE_OFFSET);
					else
						line:SetPoint("TOP", lineFrame, "TOP", 0, -WATCHFRAME_INITIAL_OFFSET);
					end
					topEdge = line:GetTop();
				end
				previousLine = line;
				-- criteria
				numCriteria = GetAchievementNumCriteria(achievementID);
				if ( numCriteria > 0 ) then
					criteriaDisplayed = 0;
					for j = 1, numCriteria do
						local dash = DASH_SHOW;		-- default since most will have this
						criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(achievementID, j);
						if ( criteriaCompleted or ( criteriaDisplayed > WATCHFRAME_CRITERIA_PER_ACHIEVEMENT and not criteriaCompleted ) ) then
							-- Do not display this one
							criteriaString = nil;
							dash = DASH_NONE;
						elseif ( criteriaDisplayed == WATCHFRAME_CRITERIA_PER_ACHIEVEMENT and numCriteria > (WATCHFRAME_CRITERIA_PER_ACHIEVEMENT + 1) ) then
							-- We ran out of space to display incomplete criteria >_<
							criteriaString = "...";
							dash = DASH_HIDE;
						else
							if ( WATCHFRAME_TIMEDCRITERIA[criteriaID] ) then
								-- not sure what this is for
								local timedCriteria = WATCHFRAME_TIMEDCRITERIA[criteriaID]
								line = WatchFrame_GetAchievementLine();
								line.criteriaID = criteriaID;
								line.duration = timedCriteria.duration;
								line.startTime = timedCriteria.startTime;
								WatchFrame_SetLine(line, previousLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, "<???>", DASH_NONE);
								previousLine = line;
								criteriaDisplayed = criteriaDisplayed + 1;
								WatchFrameLines_AddUpdateFunction(WatchFrame_UpdateTimedAchievements);
							end
							if ( description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
								-- progress bar
								if ( string.find(strlower(quantityString), "interface\\moneyframe") ) then	-- no easy way of telling it's a money progress bar
									criteriaString = quantityString.."\n"..description;
								else
									-- remove spaces so it matches the quest look, x/y
									criteriaString = string.gsub(quantityString, " / ", "/").." "..description;
								end
							else
								-- criteriaString and dash are already set for regular criteria
								-- for meta criteria look up the achievement name
								if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
									_, criteriaString = GetAchievementInfo(assetID);
								end
							end
						end
						-- set up the line
						if ( criteriaString ) then
							line = WatchFrame_GetAchievementLine();
							WatchFrame_SetLine(line, previousLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, criteriaString, dash, nil, nil, eligible);
							previousLine = line;
							criteriaDisplayed = criteriaDisplayed + 1;
						end
					end
				else
					-- single criteria type of achievement
					eligible = IsAchievementEligible(achievementID);
					line = WatchFrame_GetAchievementLine();
					WatchFrame_SetLine(line, previousLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, description, DASH_SHOW, nil, nil, eligible);
					previousLine = line;				
					for criteriaID, timedCriteria in next, WATCHFRAME_TIMEDCRITERIA do
						if ( timedCriteria.achievementID == achievementID ) then
							-- not sure what this is for
							line = WatchFrame_GetAchievementLine();
							line.criteriaID = criteriaID;
							line.duration = timedCriteria.duration;
							line.startTime = timedCriteria.startTime;
							WatchFrame_SetLine(line, previousLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, "<???>", DASH_NONE)
							previousLine = line;
							WatchFrameLines_AddUpdateFunction(WatchFrame_UpdateTimedAchievements);
						end
					end				
				end

				-- stop processing if there's no room to fit the achievement
				local numLines = #WATCHFRAME_SETLINES;
				local previousBottom = previousLine:GetBottom();
				if ( previousBottom and previousBottom < WatchFrame:GetBottom() ) then				
					achievementLineIndex = achievementLineIndex - numLines;
					table.wipe(WATCHFRAME_SETLINES);
					if ( achievementLineIndex > 1 ) then
						previousLine = WATCHFRAME_ACHIEVEMENTLINES[achievementLineIndex - 1];
					else
						previousLine = nil;
					end
					break;
				else
					-- turn on all lines
					for _, line in pairs(WATCHFRAME_SETLINES) do
						line:Show();
						lineWidth = line.text:GetWidth() + line.dash:GetWidth();
						maxWidth = max(maxWidth, lineWidth);
					end
					-- turn on link button
					linkButton = WatchFrame_GetLinkButton();
					linkButton:SetPoint("TOPLEFT", achievementTitle.text);
					linkButton:SetPoint("BOTTOMLEFT", achievementTitle.text);
					linkButton:SetWidth(achievementTitle.text:GetStringWidth());
					linkButton.type = "ACHIEVEMENT";
					linkButton.index = achievementID;
					linkButton.lines = WATCHFRAME_ACHIEVEMENTLINES;
					linkButton.startLine = achievementLineIndex - numLines;
					linkButton.lastLine = achievementLineIndex - 1;
					linkButton.isComplete = nil;
					linkButton:Show();
					
					if ( previousBottom ) then
						heightUsed = topEdge - previousBottom;
					else
						heightUsed = 1;
					end
				end
			end
		end
	end

	WatchFrame_ReleaseUnusedAchievementLines();
	return previousLine or nextAnchor, maxWidth, numTrackedAchievements, 0;
end

function WatchFrame_DisplayTrackedQuests (lineFrame, nextAnchor, maxHeight, frameWidth)
	local _;
	local questTitle;
	local questIndex;	
	local line;
	local lastLine;
	local linkButton;
	local watchItemIndex = 0;
	local numVisible = 0;
	
	local numPOINumeric = 0;
	local numPOICompleteIn = 0;
	local numPOICompleteOut = 0;

	local text, finished, objectiveType;
	local numQuestWatches = GetNumQuestWatches();
	local numObjectives;
	local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, startEvent;
	local numValidQuests = 0;

	local maxWidth = 0;
	local lineWidth = 0;
	local topEdge = 0;

	local playerMoney = GetMoney();
	if ( not WorldMapFrame or not WorldMapFrame:IsShown() ) then
		-- For the filter REMOTE ZONES: when it's unchecked we need to display local POIs only. Unfortunately all the POI
		-- code uses the current map so the tracker would not display the right quests if the world map was windowed and
		-- open to a different zone.
		table.wipe(LOCAL_MAP_QUESTS);
		LOCAL_MAP_QUESTS["zone"] = GetCurrentMapZone();
		for id in pairs(CURRENT_MAP_QUESTS) do
			LOCAL_MAP_QUESTS[id] = true;
		end	
	end
	
	table.wipe(VISIBLE_WATCHES);
	WatchFrame_ResetQuestLines();

	-- if supertracked quest is not in the quest log anymore, stop supertracking it
	if ( GetQuestLogIndexByID(GetSuperTrackedQuestID()) == 0 ) then
		SetSuperTrackedQuestID(0);
	end
	
	local inScenario = C_Scenario.IsInScenario();

	for i = 1, numQuestWatches do
		local validQuest = false;
		WATCHFRAME_SETLINES = table.wipe(WATCHFRAME_SETLINES or { });
		questIndex = GetQuestIndexForWatch(i);
		if ( questIndex ) then
			-- don't show non-scenario quests in scenarios
			if ( not inScenario or GetQuestLogQuestType(questIndex) == QUEST_TYPE_SCENARIO ) then
				validQuest = true;
			end
		end
		if ( validQuest ) then
			numValidQuests = numValidQuests + 1;
			title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, startEvent = GetQuestLogTitle(questIndex);
			
			if (GetSuperTrackedQuestID() == 0) then
				SetSuperTrackedQuestID(questID);
			end
			
			local questFailed = false;
			local requiredMoney = GetQuestLogRequiredMoney(questIndex);			
			numObjectives = GetNumQuestLeaderBoards(questIndex);
			if ( isComplete and isComplete < 0 ) then
				isComplete = false;
				questFailed = true;
			elseif ( numObjectives == 0 and playerMoney >= requiredMoney and not startEvent ) then
				isComplete = true;		
			end
			-- check filters
			local filterOK = true;
			if ( isComplete and bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_COMPLETED_QUESTS) ~= WATCHFRAME_FILTER_COMPLETED_QUESTS ) then
				filterOK = false;
			elseif ( bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_REMOTE_ZONES) ~= WATCHFRAME_FILTER_REMOTE_ZONES and not LOCAL_MAP_QUESTS[questID] ) then
				filterOK = false;
			end			
			
			if ( filterOK ) then
				local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questIndex);
				if ( requiredMoney > 0 ) then
					WatchFrame.watchMoney = true;	-- for update event			
				end
				questTitle = WatchFrame_GetQuestLine();
				WatchFrame_SetLine(questTitle, lastLine, -WATCHFRAME_QUEST_OFFSET, IS_HEADER, title, DASH_NONE, item);
				if ( not lastLine ) then -- First line
					questTitle:SetPoint("RIGHT", lineFrame, "RIGHT", 0, 0);
					questTitle:SetPoint("LEFT", lineFrame, "LEFT", 0, 0);
					if (nextAnchor) then
						questTitle:SetPoint("TOP", nextAnchor, "BOTTOM", 0, -WATCHFRAME_TYPE_OFFSET);
					else
						questTitle:SetPoint("TOP", lineFrame, "TOP", 0, -WATCHFRAME_INITIAL_OFFSET);
					end
					topEdge = questTitle:GetTop();
				end
				lastLine = questTitle;
				
				if ( isComplete ) then
					local showItem = item and showItemWhenComplete;
					if (GetQuestLogIsAutoComplete(questIndex)) then
						line = WatchFrame_GetQuestLine();
						WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, QUEST_WATCH_QUEST_COMPLETE, DASH_HIDE, showItem, true);
						lastLine = line;
						line = WatchFrame_GetQuestLine();
						WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, QUEST_WATCH_CLICK_TO_COMPLETE, DASH_HIDE, showItem, true);
						lastLine = line;
					else
						line = WatchFrame_GetQuestLine();
						WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, GetQuestLogCompletionText(questIndex), DASH_SHOW, showItem, true);
						lastLine = line;
					end
				elseif ( questFailed ) then
					line = WatchFrame_GetQuestLine();
					WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, FAILED, DASH_HIDE, nil, nil, false);
					lastLine = line;
				else
					for j = 1, numObjectives do
						text, objectiveType, finished = GetQuestLogLeaderBoard(j, questIndex);
						if ( not finished and text ) then
							text = ReverseQuestObjective(text, objectiveType);
							line = WatchFrame_GetQuestLine();
							WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, text, DASH_SHOW, item);
							lastLine = line;
						end
					end
					if ( requiredMoney > playerMoney ) then
						text = GetMoneyString(playerMoney).." / "..GetMoneyString(requiredMoney);
						line = WatchFrame_GetQuestLine();
						WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, text, DASH_SHOW, item);
						lastLine = line;
					end
				end

				-- stop processing if there's no room to fit the quest
				local numLines = #WATCHFRAME_SETLINES;
				local lastBottom = lastLine:GetBottom();
				if ( lastBottom and lastBottom < WatchFrame:GetBottom() ) then
					questLineIndex = questLineIndex - numLines;
					table.wipe(WATCHFRAME_SETLINES);
					break;
				end

				numVisible = numVisible + 1;
				table.insert(VISIBLE_WATCHES, numVisible, questIndex);		-- save the quest log index because watch order can change after dropdown is opened
				-- turn on quest item
				local itemButton;
				if ( item and (not isComplete or showItemWhenComplete) ) then
					watchItemIndex = watchItemIndex + 1;
					itemButton = _G["WatchFrameItem"..watchItemIndex];
					if ( not itemButton ) then
						WATCHFRAME_NUM_ITEMS = watchItemIndex;
						itemButton = CreateFrame("BUTTON", "WatchFrameItem" .. watchItemIndex, lineFrame, "WatchFrameItemButtonTemplate");
					end
					itemButton:Show();
					itemButton:ClearAllPoints();
					itemButton:SetID(questIndex);
					SetItemButtonTexture(itemButton, item);
					SetItemButtonCount(itemButton, charges);
					itemButton.charges = charges;
					WatchFrameItem_UpdateCooldown(itemButton);
					itemButton.rangeTimer = -1;
					itemButton:SetPoint("TOPRIGHT", questTitle, "TOPRIGHT", 10, -2);
				end			
				-- turn on all lines
				for _, line in pairs(WATCHFRAME_SETLINES) do
					line:Show();
					lineWidth = line.text:GetWidth() + line.dash:GetWidth();
					maxWidth = max(maxWidth, lineWidth);
				end
				-- turn on link button
				linkButton = WatchFrame_GetLinkButton();
				linkButton:SetPoint("TOPLEFT", questTitle);
				linkButton:SetPoint("BOTTOMLEFT", questTitle);
				linkButton:SetPoint("RIGHT", questTitle.text);
				linkButton.type = "QUEST"
				linkButton.index = i; -- We want the Watch index, we'll get the quest index later with GetQuestIndexForWatch(i);
				linkButton.lines = WATCHFRAME_QUESTLINES;
				linkButton.startLine = questLineIndex - numLines;
				linkButton.lastLine = questLineIndex - 1;
				linkButton.isComplete = isComplete;
				linkButton:Show();				
				-- quest POI icon
				if ( WatchFrame.showObjectives ) then
					local poiButton;
					if ( CURRENT_MAP_QUESTS[questID] ) then
						if ( isComplete ) then
							numPOICompleteIn = numPOICompleteIn + 1;
							poiButton = QuestPOI_DisplayButton("WatchFrameLines", QUEST_POI_COMPLETE_IN, numPOICompleteIn, questID);
						else
							numPOINumeric = numPOINumeric + 1;
							poiButton = QuestPOI_DisplayButton("WatchFrameLines", QUEST_POI_NUMERIC, numPOINumeric, questID);
						end
					elseif ( isComplete ) then
						numPOICompleteOut = numPOICompleteOut + 1;
						poiButton = QuestPOI_DisplayButton("WatchFrameLines", QUEST_POI_COMPLETE_OUT, numPOICompleteOut, questID);
					end
					if ( poiButton ) then
						poiButton:SetPoint("TOPRIGHT", questTitle, "TOPLEFT", 0, 5);
					end				
				end
				
			end
		end
	end

	for i = watchItemIndex + 1, WATCHFRAME_NUM_ITEMS do
		_G["WatchFrameItem" .. i]:Hide();
	end
	QuestPOI_HideButtons("WatchFrameLines", QUEST_POI_NUMERIC, numPOINumeric + 1);
	QuestPOI_HideButtons("WatchFrameLines", QUEST_POI_COMPLETE_IN, numPOICompleteIn + 1);
	QuestPOI_HideButtons("WatchFrameLines", QUEST_POI_COMPLETE_OUT, numPOICompleteOut + 1);
	
	WatchFrame_ReleaseUnusedQuestLines();

	local trackedQuestID = GetSuperTrackedQuestID();
	if ( trackedQuestID ) then
		QuestPOIUpdateIcons();
		QuestPOI_SelectButtonByQuestId("WatchFrameLines", trackedQuestID, true);
	end
	
	return lastLine or nextAnchor, maxWidth, numValidQuests, 0;
end

function WatchFrameLines_OnUpdate (self, elapsed)
	for i = 1, self.numFunctions do
		if ( self.updateFunctions[i](elapsed) ) then -- If a function returns true, update the entire watch frame (the number of lines changed). 
			WatchFrame_Update(WatchFrame);
			return;
		end
	end
end

function WatchFrameLines_AddUpdateFunction (func)
	local self = WatchFrameLines;
	local numFunctions = self.numFunctions
	for i = 1, numFunctions do
		if ( self.updateFunctions[i] == func ) then
			return;
		end
	end
	
	tinsert(self.updateFunctions, func);
	self.numFunctions = self.numFunctions + 1;
	self:SetScript("OnUpdate", WatchFrameLines_OnUpdate);
end

function WatchFrameLines_RemoveUpdateFunction (func)
	local self = WatchFrameLines;
	local numFunctions = WatchFrameLines.numFunctions
	for i = 1, numFunctions do
		if ( self.updateFunctions[i] == func ) then
			tremove(self.updateFunctions, i);
			self.numFunctions = self.numFunctions - 1;
			break;
		end
	end
	
	if ( self.numFunctions == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

function WatchFrame_OpenQuestLog (button, arg1, arg2, checked)
	ExpandQuestHeader(GetQuestIndexForWatch(arg1));
	-- you have to call GetQuestIndexForWatch again because ExpandQuestHeader will sort the indices
	QuestLog_OpenToQuest(GetQuestIndexForWatch(arg1), arg2);
end

function WatchFrame_AbandonQuest (button, arg1, arg2, checked)
	local lastQuest = GetQuestLogSelection();
	local lastNumQuests = GetNumQuestLogEntries();
	SelectQuestLogEntry(GetQuestIndexForWatch(arg1)); -- More or less QuestLogFrameAbandonButton_OnClick, may want to consolidate
	SetAbandonQuest();
	
	local items = GetAbandonQuestItems();
	if ( items ) then
		StaticPopup_Hide("ABANDON_QUEST");
		StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", GetAbandonQuestName(), items);
	else
		StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
		StaticPopup_Show("ABANDON_QUEST", GetAbandonQuestName());
	end
	SelectQuestLogEntry(lastQuest);
end

function WatchFrame_ShareQuest (button, arg1, arg2, checked)
	QuestLogPushQuest(GetQuestIndexForWatch(arg1));
end

function WatchFrame_StopTrackingQuest (button, arg1, arg2, checked)
	RemoveQuestWatch(GetQuestIndexForWatch(arg1));
	WatchFrame_Update();
	QuestLog_Update();
end

function WatchFrame_OpenMapToQuest (button, arg1)
	local index = GetQuestIndexForWatch(arg1);
	local questID = select(9, GetQuestLogTitle(index));
	WorldMap_OpenToQuest(questID);
end

function WatchFrame_OpenAchievementFrame (button, arg1, arg2, checked)
	if ( not AchievementFrame ) then
		AchievementFrame_LoadUI();
	end

	if ( not AchievementFrame:IsShown() ) then
		AchievementFrame_ToggleAchievementFrame();
		AchievementFrame_SelectAchievement(arg1);
	else
		if ( AchievementFrameAchievements.selection ~= arg1 ) then
			AchievementFrame_SelectAchievement(arg1);
		else
			AchievementFrame_ToggleAchievementFrame();
		end
	end	
end

function WatchFrame_StopTrackingAchievement (button, arg1, arg2, checked)
	RemoveTrackedAchievement(arg1);
	WatchFrame_Update();
	if ( AchievementFrame ) then
		AchievementFrameAchievements_ForceUpdate(); -- Quests handle this automatically because they have spiffy events.
	end
end

function WatchFrameDropDown_OnHide ()
	WatchFrame.dropDownOpen = nil; 
	
	if ( WatchFrame.lastLinkButton ) then 
		WatchFrame.lastLinkButton = nil;
	end 
end

function WatchFrameDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, WatchFrameDropDown_Initialize, "MENU");
	self.onHide = WatchFrameDropDown_OnHide;
end

function WatchFrameDropDown_Initialize (self)
	if ( self.type == "QUEST" ) then
		local info = UIDropDownMenu_CreateInfo();
		local questLogIndex = GetQuestIndexForWatch(self.index);
		info.text = GetQuestLogTitle(questLogIndex);
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

		info = UIDropDownMenu_CreateInfo();
		info.notCheckable = 1;
		
		info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
		info.func = WatchFrame_OpenQuestLog;
		info.arg1 = self.index;
		info.arg2 = true;
		info.noClickSound = 1;		
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = WatchFrame_StopTrackingQuest;
		info.arg1 = self.index;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		if ( GetQuestLogPushable(GetQuestIndexForWatch(self.index)) and IsInGroup() ) then
			info.text = SHARE_QUEST;
			info.func = WatchFrame_ShareQuest;
			info.arg1 = self.index;
			info.checked = false;
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		end
		if ( WatchFrame.showObjectives ) then
			info.text = OBJECTIVES_SHOW_QUEST_MAP;
			info.func = WatchFrame_OpenMapToQuest;
			info.arg1 = self.index;
			info.checked = false;
			info.noClickSound = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		end
		local numVisibleWatches = #VISIBLE_WATCHES;
		if ( numVisibleWatches > 1 ) then
			local visibleIndex = WatchFrame_GetVisibleIndex(questLogIndex);
			if ( visibleIndex > 1 ) then
				info.text = TRACKER_SORT_MANUAL_UP;
				info.func = WatchFrame_MoveQuest;
				info.arg1 = questLogIndex;
				info.arg2 = -1;
				info.checked = false;
				UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
				info.text = TRACKER_SORT_MANUAL_TOP;
				info.func = WatchFrame_MoveQuest;			
				info.arg1 = questLogIndex;
				info.arg2 = -100;		-- ensure move up to top regardless of reordering after dropdown has been opened
				info.checked = false;
				UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
			end
			if ( visibleIndex < numVisibleWatches ) then
				info.text = TRACKER_SORT_MANUAL_DOWN;
				info.func = WatchFrame_MoveQuest;
				info.arg1 = questLogIndex;
				info.arg2 = 1;
				info.checked = false;
				UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
				info.text = TRACKER_SORT_MANUAL_BOTTOM;
				info.func = WatchFrame_MoveQuest;
				info.arg1 = questLogIndex;
				info.arg2 = 100;		-- ensure move down to bottom regardless of reordering after dropdown has been opened
				info.checked = false;
				UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
			end			
		end
	elseif ( self.type == "ACHIEVEMENT" ) then
		local _, achievementName, _, completed, _, _, _, _, _, icon = GetAchievementInfo(self.index);
		local info = UIDropDownMenu_CreateInfo();
		info.text = achievementName;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		info = UIDropDownMenu_CreateInfo();
		info.notCheckable = 1;
		
		info.text = OBJECTIVES_VIEW_ACHIEVEMENT;
		info.func = WatchFrame_OpenAchievementFrame;
		info.arg1 = self.index;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = WatchFrame_StopTrackingAchievement;
		info.arg1 = self.index;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

function WatchFrame_CollapseExpandButton_OnClick (self)
	local WatchFrame = WatchFrame;
	if ( WatchFrame.collapsed ) then
		WatchFrame.userCollapsed = nil;
		WatchFrame_Expand(WatchFrame);
		PlaySound("igMiniMapOpen");
	else
		WatchFrame.userCollapsed = true;
		WatchFrame_Collapse(WatchFrame);
		PlaySound("igMiniMapClose");
	end
end

local function WatchFrameLineTemplate_Reset (self)
	self:ClearAllPoints();
	self.text:SetText("");
	self.text:SetTextColor(0.8, 0.8, 0.8);
	self.text:Show();
	self.dash:SetText(nil);
	self.dash:Show();
	self:SetHeight(WATCHFRAME_LINEHEIGHT);
	self.text:SetHeight(0);	
	self.criteriaID = nil;	
end

function WatchFrameLineTemplate_OnLoad (self)
	local name = self:GetName();
	self.Reset = WatchFrameLineTemplate_Reset;
end

function WatchFrameItem_UpdateCooldown (self)
	local itemCooldown = _G[self:GetName().."Cooldown"];
	local start, duration, enable = GetQuestLogSpecialItemCooldown(self:GetID());
	if ( start ) then
		CooldownFrame_SetTimer(itemCooldown, start, duration, enable);
		if ( duration > 0 and enable == 0 ) then
			SetItemButtonTextureVertexColor(self, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(self, 1, 1, 1);
		end
	end
end
		
function WatchFrameItem_OnLoad (self)
	self:RegisterForClicks("AnyUp");
end

function WatchFrameItem_OnEvent (self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		WatchFrameItem_UpdateCooldown(self);
	end
end

function WatchFrameItem_OnUpdate (self, elapsed)
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;
		if ( rangeTimer <= 0 ) then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self:GetID());
			if ( not charges or charges ~= self.charges ) then
				WatchFrame_Update();
				return;
			end
			local count = _G[self:GetName().."HotKey"];
			local valid = IsQuestLogSpecialItemInRange(self:GetID());
			if ( valid == 0 ) then
				count:Show();
				count:SetVertexColor(1.0, 0.1, 0.1);
			elseif ( valid == 1 ) then
				count:Show();
				count:SetVertexColor(0.6, 0.6, 0.6);
			else
				count:Hide();
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		
		self.rangeTimer = rangeTimer;
	end
end

function WatchFrameItem_OnShow (self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
end

function WatchFrameItem_OnHide (self)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
end

function WatchFrameItem_OnEnter (self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetQuestLogSpecialItem(self:GetID());
end
		
function WatchFrameItem_OnClick (self, button, down)
	local questIndex = self:GetID();
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questIndex);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	else
		UseQuestLogSpecialItem(questIndex);
	end
end

function WatchFrameLinkButtonTemplate_Highlight(self, onEnter)
	local line;
	for index = self.startLine, self.lastLine do
		line = self.lines[index];
		if ( line ) then
			if ( index == self.startLine ) then
				-- header
				if ( onEnter ) then
					line.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				else
					line.text:SetTextColor(0.75, 0.61, 0);
				end
			else
				if ( onEnter ) then
					if (line.text.eligible) then
						line.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					else
						line.text:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					end
					line.dash:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				else
					if (line.text.eligible) then
						line.text:SetTextColor(0.8, 0.8, 0.8);
					else
						line.text:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b);
					end
					line.dash:SetTextColor(0.8, 0.8, 0.8);
				end
			end
		end
	end
end

function WatchFrame_GetCurrentMapQuests()
	local numQuests = QuestMapUpdateAllQuests();
	table.wipe(CURRENT_MAP_QUESTS);	
	for i = 1, numQuests do
		local questId = QuestPOIGetQuestIDByVisibleIndex(i);
		CURRENT_MAP_QUESTS[questId] = i;
	end
end

function WatchFrameQuestPOI_OnClick(self, button)
	QuestPOI_SelectButtonByQuestId("WatchFrameLines", self.questId, true);
	if ( WorldMapFrame:IsShown() ) then
		WorldMapFrame_SelectQuestById(self.questId);
	end
	SetSuperTrackedQuestID(self.questId);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function WatchFrame_SetWidth(width)
	if ( width == "0" ) then
		WATCHFRAME_EXPANDEDWIDTH = 204;
		WATCHFRAME_MAXLINEWIDTH = 192;
	else
		WATCHFRAME_EXPANDEDWIDTH = 306;
		WATCHFRAME_MAXLINEWIDTH = 294;
	end
	WatchFrameScenarioFrame:SetWidth(WATCHFRAME_EXPANDEDWIDTH);
	WatchFrameScenarioFrame.dirty = true;
	if ( WatchFrame:IsShown() and not WatchFrame.collapsed ) then
		WatchFrame:SetWidth(WATCHFRAME_EXPANDEDWIDTH);
		WatchFrame_Update();
	end
end

-- header dropdown
function WatchFrameHeader_OnClick(self, button)
	if ( button == "RightButton" ) then	
		ToggleDropDownMenu(1, nil, WatchFrameHeaderDropDown, "cursor", 3, -3)
	end
end

function WatchFrameHeaderDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, WatchFrameHeaderDropDown_Initialize, "MENU");
end

function WatchFrameHeaderDropDown_Initialize (self)
	local info = UIDropDownMenu_CreateInfo();
	-- sort label
	info.text = TRACKER_SORT_LABEL;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	-- sort: proximity
	info = UIDropDownMenu_CreateInfo();
	info.checked = (WATCHFRAME_SORT_TYPE == WATCHFRAME_SORT_PROXIMITY);
	info.text = TRACKER_SORT_PROXIMITY;
	info.tooltipTitle = TRACKER_SORT_PROXIMITY;
	info.tooltipText = TOOLTIP_TRACKER_SORT_PROXIMITY;
	info.arg1 = WATCHFRAME_SORT_PROXIMITY;
	info.func = WatchFrame_SetSorting;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	-- sort: difficulty high
	info = UIDropDownMenu_CreateInfo();
	info.checked = (WATCHFRAME_SORT_TYPE == WATCHFRAME_SORT_DIFFICULTY_HIGH);	
	info.text = TRACKER_SORT_DIFFICULTY_HIGH;
	info.tooltipTitle = TRACKER_SORT_DIFFICULTY_HIGH;
	info.tooltipText = TOOLTIP_TRACKER_SORT_DIFFICULTY_HIGH;
	info.arg1 = WATCHFRAME_SORT_DIFFICULTY_HIGH;
	info.func = WatchFrame_SetSorting;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	-- sort: difficulty low
	info = UIDropDownMenu_CreateInfo();
	info.checked = (WATCHFRAME_SORT_TYPE == WATCHFRAME_SORT_DIFFICULTY_LOW);
	info.text = TRACKER_SORT_DIFFICULTY_LOW;
	info.tooltipTitle = TRACKER_SORT_DIFFICULTY_LOW;
	info.tooltipText = TOOLTIP_TRACKER_SORT_DIFFICULTY_LOW;
	info.arg1 = WATCHFRAME_SORT_DIFFICULTY_LOW;
	info.func = WatchFrame_SetSorting;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	-- sort: manual	
	info = UIDropDownMenu_CreateInfo();
	info.checked = (WATCHFRAME_SORT_TYPE == WATCHFRAME_SORT_MANUAL);
	info.text = TRACKER_SORT_MANUAL;
	info.tooltipTitle = TRACKER_SORT_MANUAL;
	info.tooltipText = TOOLTIP_TRACKER_SORT_MANUAL;	
	info.arg1 = WATCHFRAME_SORT_MANUAL;
	info.func = WatchFrame_SetSorting;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	-- filter label
	info.text = TRACKER_FILTER_LABEL;
	info.checked = false;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	-- filter: achievements
	info = UIDropDownMenu_CreateInfo();
	info.checked = (bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_ACHIEVEMENTS) == WATCHFRAME_FILTER_ACHIEVEMENTS);
	info.text = TRACKER_FILTER_ACHIEVEMENTS;
	info.tooltipTitle = TRACKER_FILTER_ACHIEVEMENTS;
	info.tooltipText = TOOLTIP_TRACKER_FILTER_ACHIEVEMENTS;
	info.arg1 = WATCHFRAME_FILTER_ACHIEVEMENTS;
	info.func = WatchFrame_SetFilter;
	info.isNotRadio = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	-- filter: completed quests
	info = UIDropDownMenu_CreateInfo();
	info.checked = (bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_COMPLETED_QUESTS) == WATCHFRAME_FILTER_COMPLETED_QUESTS);
	info.text = TRACKER_FILTER_COMPLETED_QUESTS;
	info.tooltipTitle = TRACKER_FILTER_COMPLETED_QUESTS;
	info.tooltipText = TOOLTIP_TRACKER_FILTER_COMPLETED_QUESTS;
	info.arg1 = WATCHFRAME_FILTER_COMPLETED_QUESTS;
	info.func = WatchFrame_SetFilter;
	info.isNotRadio = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);	
	-- filter: current zone
	info = UIDropDownMenu_CreateInfo();
	info.checked = (bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_REMOTE_ZONES) == WATCHFRAME_FILTER_REMOTE_ZONES);
	info.text = TRACKER_FILTER_REMOTE_ZONES;
	info.tooltipTitle = TRACKER_FILTER_REMOTE_ZONES;
	info.tooltipText = TOOLTIP_TRACKER_FILTER_REMOTE_ZONES;
	info.arg1 = WATCHFRAME_FILTER_REMOTE_ZONES;
	info.func = WatchFrame_SetFilter;
	info.isNotRadio = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);	
end

function WatchFrame_SetSorting(button, arg1)
	WATCHFRAME_SORT_TYPE = arg1;
	SetCVar("trackerSorting", WATCHFRAME_SORT_TYPE);
	if ( WATCHFRAME_SORT_TYPE ~= WATCHFRAME_SORT_MANUAL ) then
		SortQuestWatches();
		WatchFrame_Update();
		WatchFrame.updateTimer = WATCHFRAME_UPDATE_RATE;
		if ( WorldMapFrame:IsShown() ) then
			WorldMapFrame_UpdateMap();
		end
	end
end

function WatchFrame_SetFilter(button, arg1)
	if ( bit.band(WATCHFRAME_FILTER_TYPE, arg1) == arg1 ) then
		WATCHFRAME_FILTER_TYPE = WATCHFRAME_FILTER_TYPE - arg1;
	else
		WATCHFRAME_FILTER_TYPE = WATCHFRAME_FILTER_TYPE + arg1;
	end
	SetCVar("trackerFilter", WATCHFRAME_FILTER_TYPE);
	WatchFrame_Update();
end

function WatchFrame_GetVisibleIndex(questLogIndex)
	for i = 1, #VISIBLE_WATCHES do
		if ( VISIBLE_WATCHES[i] == questLogIndex ) then
			return i;
		end
	end
end

function WatchFrame_MoveQuest(button, questLogIndex, numMoves)
	if ( WATCHFRAME_SORT_TYPE ~= WATCHFRAME_SORT_MANUAL ) then
		WatchFrame_SetSorting(nil, WATCHFRAME_SORT_MANUAL);
		UIErrorsFrame:AddMessage(TRACKER_SORT_MANUAL_WARNING, 1.0, 1.0, 0.0, 1.0);
	end
	local numVisibleWatches = #VISIBLE_WATCHES;
	local indexStart = WatchFrame_GetVisibleIndex(questLogIndex);
	local indexEnd = indexStart + numMoves;
	if ( indexEnd < 1 ) then
		indexEnd = 1;
	elseif ( indexEnd > numVisibleWatches ) then
		indexEnd = numVisibleWatches;
	end
	ShiftQuestWatches(GetQuestWatchIndex(questLogIndex), GetQuestWatchIndex(VISIBLE_WATCHES[indexEnd]));
	WatchFrame_Update();
	if ( WorldMapFrame:IsShown() ) then
		WorldMapFrame_UpdateMap();
	end
end


-- AutoQuest pop-ups
local numPopUpFrames = 0;

function WatchFrameAutoQuest_GetOrCreateFrame(parent, index)
	if (_G["WatchFrameAutoQuestPopUp"..index]) then
		return _G["WatchFrameAutoQuestPopUp"..index];
	end
	local frame = CreateFrame("SCROLLFRAME", "WatchFrameAutoQuestPopUp"..index, parent, "WatchFrameAutoQuestPopUpTemplate");	
	frame.isFirst = (index == 1 and WATCHFRAME_NUM_POPUPS == 0);	-- used by slide-in animation
	numPopUpFrames = numPopUpFrames+1;
	return frame;
end

function WatchFrameAutoQuest_DisplayAutoQuestPopUps(lineFrame, nextAnchor, maxHeight, frameWidth)
	local numPopUps = 0;
	local maxWidth = 0;
	local i;
	local numAutoQuestPopUps = GetNumAutoQuestPopUps();
	for i=1, numAutoQuestPopUps do
		local questID, popUpType = GetAutoQuestPopUp(i);
		local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, _ = GetQuestLogTitle(GetQuestLogIndexByID(questID));
				
		if ( isComplete and isComplete > 0 ) then
			isComplete = true;
		else
			isComplete = false;
		end	
			
		if (questTitle and questTitle ~= "") then
			local frame = WatchFrameAutoQuest_GetOrCreateFrame(lineFrame, numPopUps+1);
			frame:Show();
			frame:ClearAllPoints();
			frame:SetParent(lineFrame);
			
			if (not frame.questId) then
				-- Only show the animation for new notifications
				frame.ScrollChild.Flash:Hide();
				WatchFrame_SlideInFrame(frame, "AUTOQUEST");
			end
			
			if (isComplete and popUpType == "COMPLETE") then
				frame.ScrollChild.QuestionMark:Show();
				frame.ScrollChild.Exclamation:Hide();
				frame.ScrollChild.TopText:SetText(QUEST_WATCH_POPUP_CLICK_TO_COMPLETE);
				frame.ScrollChild.BottomText:Hide();
				frame.ScrollChild.TopText:SetPoint("TOP", 0, -12);
				frame.ScrollChild.QuestName:SetPoint("TOP", 0, -32);
				if (frame.questId and frame.type=="OFFER") then
					frame.ScrollChild.Flash:Show();
				end
				frame.type="COMPLETED";
			elseif (popUpType == "OFFER") then
				frame.ScrollChild.QuestionMark:Hide();
				frame.ScrollChild.Exclamation:Show();
				frame.ScrollChild.TopText:SetText(QUEST_WATCH_POPUP_QUEST_DISCOVERED);
				frame.ScrollChild.BottomText:Show();
				frame.ScrollChild.BottomText:SetText(QUEST_WATCH_POPUP_CLICK_TO_VIEW);
				frame.ScrollChild.TopText:SetPoint("TOP", 0, -4);
				frame.ScrollChild.QuestName:SetPoint("TOP", 0, -24);
				frame.ScrollChild.Flash:Hide();
				frame.type="OFFER";
			end
			
			frame:ClearAllPoints();
			if (nextAnchor) then
				if (i == 1) then
					frame:SetPoint("TOP", nextAnchor, "BOTTOM", 0, -WATCHFRAME_TYPE_OFFSET);
				else
					frame:SetPoint("TOP", nextAnchor, "BOTTOM", 0, 0);
				end
			else
				-- Cancel out the WATCHFRAME_TYPE_OFFSET here, it will be added into the animation for the first pop-up.  Also add 1 for the initial height of the pop-up.
				-- This prevents tracked quests from moving a bit initially while the background shadow is fading in.
				frame:SetPoint("TOP", lineFrame, "TOP", 0, -WATCHFRAME_INITIAL_OFFSET+WATCHFRAME_TYPE_OFFSET+1);
			end
			frame:SetPoint("LEFT", lineFrame, "LEFT", -30, 0);

			frame.ScrollChild.QuestName:SetText(questTitle);
			frame.questId = questID;
			
			maxWidth = max(maxWidth, frame:GetWidth());
			nextAnchor = frame;
			numPopUps = numPopUps+1;
		end
	end
	
	for i=numPopUps+1, numPopUpFrames do
		_G["WatchFrameAutoQuestPopUp"..i].questId = nil;
		_G["WatchFrameAutoQuestPopUp"..i]:Hide();
	end
	
	return nextAnchor, maxWidth, 0, numPopUps;
end

function WatchFrameAutoQuest_OnFinishSlideIn(frame)
	frame.ScrollChild.Shine:Show();
	frame.ScrollChild.IconShine:Show();
	frame.ScrollChild.Shine.Flash:Play();
	frame.ScrollChild.IconShine.Flash:Play();
end

function WatchFrameAutoQuest_AddPopUp(questId, type)
	if (AddAutoQuestPopUp(questId, type)) then
		WatchFrame_Update(WatchFrame);
		WatchFrame_Expand(WatchFrame);
		return true;
	end
	return false;
end

function WatchFrameAutoQuest_ClearPopUp(questId)
	RemoveAutoQuestPopUp(questId);
	WatchFrame_Update(WatchFrame);
end

function WatchFrameAutoQuest_ClearPopUpByLogIndex(questIndex)
	local questId = select(9, GetQuestLogTitle(questIndex));
	WatchFrameAutoQuest_ClearPopUp(questId);
end

--------------------------------------------------------------------------------------------
-- Scenario
--------------------------------------------------------------------------------------------
local SCENARIO_POPUP_BASE_HEIGHT = 83;
local SCENARIO_TEXT_HEADER_HEIGHT = 0;		-- determined after setting the text
local SCENARIO_LINE_OFFSET = 10;
local SCENARIO_BONUS_OFFSET = 8;
local SCENARIO_CRITERIA_LINES = { };

function IsInProvingGround()
	if (WorldStateProvingGroundsFrame) then
		return WorldStateProvingGroundsFrame:IsVisible()
	else
		return nil;
	end
end

-- Sets up all the scenario info in response to events and not doing this on every WatchFrame_Update
function WatchFrameScenario_UpdateScenario(newStage, updateCriteriaID)
	local scenarioFrame = WatchFrameScenarioFrame;

	local name, currentStage, numStages, flags, hasBonusStep, isBonusStepComplete = C_Scenario.GetInfo();
	-- bonus stage is set up as an extra stage at the end of the normal stages
	-- we want to display bonus objectives even after a scenario ends
	local finalBonusDisplay = hasBonusStep and currentStage > numStages;
	if ( currentStage < 1 or (currentStage > numStages and not hasBonusStep)  or IsInProvingGround()) then
		-- this scenario has ended or we're in the middle of a proving ground
		scenarioFrame:Hide();
		scenarioFrame.stage = nil;
		scenarioFrame.name = nil;
		scenarioFrame.contentHeight = 0;
		scenarioFrame.dirty = nil;
		WatchFrameScenarioBonusHeader:Hide();
		return;
	end
	
	local headerFrame, nextAnchor;
	local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo();
	local inChallengeMode = C_Scenario.IsChallengeMode();

	-- in challenge modes we use a regular text header instead of the art header
	if ( inChallengeMode ) then
		headerFrame = scenarioFrame.ScrollChild.TextHeader;
	else
		headerFrame = scenarioFrame.ScrollChild.BlockHeader;
	end

	-- is it a new scenario?
	if ( scenarioFrame.name ~= name ) then
		scenarioFrame.name = name;
		scenarioFrame:Show();
		-- hide the other header
		if ( inChallengeMode ) then
			scenarioFrame.ScrollChild.BlockHeader:Hide();
		else
			scenarioFrame.ScrollChild.TextHeader:Hide();
		end
		-- make sure we have rewards for bonus objectives
		if ( hasBonusStep ) then
			RequestLFDPlayerLockInfo();
		end
	end

	nextAnchor = headerFrame;

	-- set up the stage
	if ( scenarioFrame.stage ~= currentStage ) then
		if ( inChallengeMode ) then
			headerFrame:Show();
			headerFrame:SetHeight(WATCHFRAME_LINEHEIGHT);
			headerFrame.text:SetHeight(0);
			WatchFrame_SetLine(headerFrame, nil, 0, IS_HEADER, stageName, DASH_NONE);
			SCENARIO_TEXT_HEADER_HEIGHT = headerFrame:GetHeight() + 4;
		else
			headerFrame:Show();
			if( bit.band(flags, SCENARIO_FLAG_SUPRESS_STAGE_TEXT) == SCENARIO_FLAG_SUPRESS_STAGE_TEXT) then
				headerFrame.stageLevel:SetText(stageName);
				headerFrame.finalBg:Hide();
				headerFrame.stageName:SetText("");
				headerFrame.stageLevel:SetPoint("TOPLEFT", 15, -18);
			else
				if ( currentStage == numStages ) then
					headerFrame.stageLevel:SetText(SCENARIO_STAGE_FINAL);
					headerFrame.finalBg:Show();
				else
					headerFrame.stageLevel:SetFormattedText(SCENARIO_STAGE, currentStage);
					headerFrame.finalBg:Hide();
				end
				headerFrame.stageName:SetText(stageName);
				if ( headerFrame.stageName:GetStringWidth() > headerFrame.stageName:GetWrappedWidth() ) then
					headerFrame.stageLevel:SetPoint("TOPLEFT", 15, -10);
				else
					headerFrame.stageLevel:SetPoint("TOPLEFT", 15, -18);
				end
			end
		end
		WatchFrameScenario_StopCriteriaAnimations();
		scenarioFrame.stage = currentStage;
	end

	-- don't do the criteria if stage just changed or the frame is sliding out or we're displaying bonus at end of scenario
	if ( (newStage and currentStage > 1) or scenarioFrame.slidingAction == "out" or finalBonusDisplay ) then
		numCriteria = 0;
	end
	local contentHeight = 0;
	local isFirstLine = true;
	for i = 1, numCriteria do
		local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID = C_Scenario.GetCriteriaInfo(i);
		criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString);
		local line = WatchFrameScenario_GetCriteriaLine(i, scenarioFrame.ScrollChild);
		WatchFrameScenario_SetLine(line, criteriaString, criteriaID, nextAnchor, inChallengeMode, isFirstLine, false);
		isFirstLine = false;
		if ( criteriaCompleted ) then
			line.text:SetTextColor(0.6, 0.6, 0.6);
			line.icon:SetTexture("Interface\\Scenarios\\ScenarioIcon-Check");
		else
			line.icon:SetTexture("Interface\\Scenarios\\ScenarioIcon-Combat");
		end
		nextAnchor = line;
		contentHeight = contentHeight + line:GetHeight() - WATCHFRAMELINES_FONTSPACING + SCENARIO_LINE_OFFSET;
	end

	-- bonus objectives	
	local bonusHeader = WatchFrameScenarioBonusHeader;
	local bonusHeaderAnim;
	if ( hasBonusStep ) then
		local bonusName, bonusDescription, numBonusCriteria, bonusStepFailed = C_Scenario.GetBonusStepInfo();
		nextAnchor = bonusHeader;
		local isFirstLine = true;
		bonusHeader.timedCriteriaIndex = nil;
		for i = 1, numBonusCriteria do
			numCriteria = numCriteria + 1;
			local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, timeLeft, criteriaFailed = C_Scenario.GetBonusCriteriaInfo(i);
			-- there should only be 1 timer event...
			if ( timeLeft and timeLeft > 0 and not criteriaCompleted and not criteriaFailed ) then
				bonusHeader.timedCriteriaIndex = i;
			end
			criteriaString = string.format("%d/%d %s", quantity, totalQuantity, criteriaString);
			local line = WatchFrameScenario_GetCriteriaLine(numCriteria, bonusHeader);
			if ( bonusStepFailed and not criteriaFailed ) then
				line.text:SetFontObject("GameFontBlack");
			else
				line.text:SetFontObject("GameFontNormal");
			end
			WatchFrameScenario_SetLine(line, criteriaString, criteriaID, nextAnchor, inChallengeMode, isFirstLine, true);
			isFirstLine = false;
			if ( criteriaCompleted ) then
				if ( not bonusStepFailed ) then
					line.text:SetTextColor(0.6, 0.6, 0.6);
				end
				line.icon:SetTexture("Interface\\Scenarios\\ScenarioIcon-Check");
			elseif ( criteriaFailed ) then
				line.icon:SetTexture("Interface\\Scenarios\\ScenarioIcon-Fail");
				line.text:SetTextColor(DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b);
			else
				line.icon:SetTexture("Interface\\Scenarios\\ScenarioIcon-Combat");
			end
			-- darken criteria lines if bonus step has failed
			if ( bonusStepFailed and not criteriaFailed ) then
				line.text:SetTextColor(0.2, 0.2, 0.2);
				line.icon:SetDesaturated(true);
			else
				line.icon:SetDesaturated(false);
			end
			-- animation? 
			if ( criteriaID == updateCriteriaID and isBonusStepComplete and bonusHeader.state ~= "success" ) then
				bonusHeaderAnim = bonusHeader.AnimSuccess;
				PlaySound("UI_Scenario_BonusObjective_Success");
			elseif ( criteriaID == updateCriteriaID and criteriaFailed and bonusStepFailed and bonusHeader.state ~= "failure" ) then
				bonusHeaderAnim = bonusHeader.AnimFailure;
			end
			nextAnchor = line;
		end
		-- timer
		if ( bonusHeader.timedCriteriaIndex ) then
			bonusHeader:SetScript("OnUpdate", WatchFrameScenarioBonusHeader_OnUpdate);
			bonusHeader.updateTime = true;
		else
			bonusHeader:SetScript("OnUpdate", nil);
			bonusHeader.TimeLeft:SetText("");
		end
		-- text and glow
		if ( isBonusStepComplete ) then
			-- bonus objectives have been completed
			bonusHeader.Label:SetText(SCENARIO_BONUS_SUCCESS);
			bonusHeader.Label:SetTextColor(1, 0.831, 0.380);
			bonusHeader.Background:SetDesaturated(false);
			bonusHeader.Background:SetVertexColor(1, 1, 1);
			bonusHeader.Flag:SetDesaturated(false);
			bonusHeader.Flag:SetVertexColor(1, 1, 1);
			bonusHeader.state = "success";
		elseif ( bonusStepFailed ) then
			-- at least one bonus objective has failed
			bonusHeader.Label:SetText(SCENARIO_BONUS_LABEL);
			bonusHeader.Label:SetTextColor(0.5, 0.5, 0.5);
			bonusHeader.Background:SetDesaturated(true);
			bonusHeader.Background:SetVertexColor(0.5, 0.5, 0.5);
			bonusHeader.Flag:SetDesaturated(true);
			bonusHeader.Flag:SetVertexColor(0.5, 0.5, 0.5);
			bonusHeader.state = "failure";
		else
			-- scenario in progress
			bonusHeader.Label:SetText(SCENARIO_BONUS_LABEL);
			bonusHeader.Label:SetTextColor(1, 0.831, 0.380);
			bonusHeader.Background:SetDesaturated(false);
			bonusHeader.Background:SetVertexColor(1, 1, 1);
			bonusHeader.Flag:SetDesaturated(false);
			bonusHeader.Flag:SetVertexColor(1, 1, 1);
			bonusHeader.state = "ongoing";
		end
		-- animation
		if ( bonusHeaderAnim ) then
			bonusHeaderAnim:Play();
		end
		bonusHeader:Show();
		scenarioFrame.bottomAnchor = nextAnchor;
	else
		bonusHeader:Hide();
		scenarioFrame.bottomAnchor = scenarioFrame;
	end

	-- hide unused lines
	for i = numCriteria + 1, #SCENARIO_CRITERIA_LINES do
		SCENARIO_CRITERIA_LINES[i]:Hide();
	end
	
	if ( finalBonusDisplay ) then
		contentHeight = 1;
		scenarioFrame.numPopups = 1;	-- treat this as a popup so shadow frame is displayed
	elseif ( inChallengeMode ) then
		contentHeight = contentHeight + SCENARIO_TEXT_HEADER_HEIGHT;
		scenarioFrame.numPopups = 0;
	else
		contentHeight = contentHeight + SCENARIO_POPUP_BASE_HEIGHT;
		scenarioFrame.numPopups = 1;	-- treat this as a popup so shadow frame is displayed
	end

	-- during a sliding animation the height is being controlled by WatchFrameSlideInFrame_OnUpdate
	if ( not scenarioFrame.slidingAction ) then
		scenarioFrame:SetHeight(contentHeight);
	end
	scenarioFrame.contentHeight = contentHeight;

	if ( newStage and not inChallengeMode ) then
		if ( WatchFrame:IsVisible() ) then
			if ( currentStage == 1 ) then
				WatchFrameScenario_SlideIn();
				LevelUpDisplay_PlayScenario();
			else
				WatchFrameScenario_SlideOut();
			end
		else
			LevelUpDisplay_PlayScenario();
		end
		-- play sound if not the first stage
		if ( currentStage > 1 and currentStage <= numStages ) then
			PlaySound("UI_Scenario_Stage_End");
		end
	end

	scenarioFrame.dirty = nil;
end

function WatchFrameScenario_SetLine(line, text, criteriaID, anchor, inChallengeMode, isFirstLine, isBonus)
	line.criteriaID = criteriaID;
	local offset;
	if ( isFirstLine ) then
		offset = 0;
		if ( inChallengeMode ) then
			offset = SCENARIO_LINE_OFFSET;
		end
		if ( isBonus ) then
			offset = offset + SCENARIO_BONUS_OFFSET;
		end
	else
		offset = SCENARIO_LINE_OFFSET;
	end
	WatchFrame_SetLine(line, anchor, WATCHFRAMELINES_FONTSPACING - offset, nil, text, DASH_ICON, nil, true);
	line.criteriaID = criteriaID;
	line:Show();
end

-- This is called from the WatchFrame_Update handler
function WatchFrameScenario_DisplayScenario(lineFrame, nextAnchor, maxHeight, frameWidth)
	local scenarioFrame = WatchFrameScenarioFrame;
	-- this will happen after a reloadui
	if ( C_Scenario.IsInScenario() and (not scenarioFrame.name or scenarioFrame.dirty) ) then
		WatchFrameScenario_UpdateScenario();
	end

	if ( scenarioFrame.name ) then
		scenarioFrame:ClearAllPoints();
		if ( nextAnchor ) then
			scenarioFrame:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", 0, -WATCHFRAME_TYPE_OFFSET);
		else
			scenarioFrame:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, -WATCHFRAME_INITIAL_OFFSET + 4);
		end
		WatchFrameScenarioBonusHeader.updateTime = true;
		-- returning anchor, width, numObjectives, numPopups
		return scenarioFrame.bottomAnchor, 0, 1, scenarioFrame.numPopups;
	else
		scenarioFrame:Hide();
		WatchFrameScenarioBonusHeader:Hide();
		-- returning anchor, width, numObjectives, numPopups
		return nextAnchor, 0, 0, 0;
	end
end

function WatchFrameScenario_GetCriteriaLine(index, parent)
	local line = SCENARIO_CRITERIA_LINES[index];
	if ( not line ) then
		line = CreateFrame("FRAME", "WatchFrameScenarioLine"..index, parent, "WatchFrameScenarioLineTemplate");
		tinsert(SCENARIO_CRITERIA_LINES, line);
	else
		line:SetParent(parent);
		if ( line.isAnimating ) then
			line.Glow.ScaleAnim:Stop();
			line.Glow.AlphaAnim:Stop();
			line.Sheen.Anim:Stop();
			line.Check.Anim:Stop();
			line.isAnimating = nil;
		end
	end
	line:SetHeight(WATCHFRAME_LINEHEIGHT);
	line.text:SetHeight(0);
	return line;
end

function WatchFrameScenario_PlayCriteriaAnimation(criteriaID)
	for i = 1, #SCENARIO_CRITERIA_LINES do
		local line = SCENARIO_CRITERIA_LINES[i];
		if ( line.criteriaID == criteriaID ) then
			line.Glow.ScaleAnim:Play();
			line.Glow.AlphaAnim:Play();
			line.Sheen.Anim:Play();
			line.Check.Anim:Play();
			line.isAnimating = true;
			return;
		end
	end
end

function WatchFrameScenario_StopCriteriaAnimations()
	for i = 1, #SCENARIO_CRITERIA_LINES do
		local line = SCENARIO_CRITERIA_LINES[i];
		if ( line.isAnimating ) then
			line.Glow.ScaleAnim:Stop();
			line.Glow.AlphaAnim:Stop();
			line.Sheen.Anim:Stop();
			line.Check.Anim:Stop();
			line.isAnimating = nil;
		end
	end
end

function WatchFrameScenario_StopAllAnimations()
	local frame = WatchFrameScenarioFrame;
	if ( frame.slidingAction ) then
		frame:SetScript("OnUpdate", nil);
		frame:SetVerticalScroll(0);
		frame.slidingAction = nil;
		frame.ScrollChild.BlockHeader.stageComplete:Hide();
		frame.ScrollChild.BlockHeader.stageLevel:Show();
		frame.ScrollChild.BlockHeader.stageName:Show();
		WatchFrameScenario_UpdateScenario();	-- to turn criteria lines back on and update the height
	end
	WatchFrameScenario_StopCriteriaAnimations();
end

function WatchFrameScenario_SlideIn()
	local frame = WatchFrameScenarioFrame;
	frame.slidingAction = "in";
	local headerFrame = frame.ScrollChild.BlockHeader;
	headerFrame.stageLevel:Show();
	headerFrame.stageName:Show();
	WATCHFRAME_SLIDEIN_ANIMATIONS["SCENARIO_IN"].height = frame.contentHeight;
	WATCHFRAME_SLIDEIN_ANIMATIONS["SCENARIO_IN"].scrollStart = frame.contentHeight;
	WatchFrame_SlideInFrame(frame, "SCENARIO_IN");
end

function WatchFrameScenario_OnFinishSlideIn()
	WatchFrameScenarioFrame.slidingAction = nil;
end

function WatchFrameScenario_SlideOut()
	local headerFrame = WatchFrameScenarioFrame.ScrollChild.BlockHeader;
	headerFrame.stageLevel:Hide();
	headerFrame.stageName:Hide();
	headerFrame.stageComplete:Show();
	headerFrame.bgAnim.AlphaAnim:Play();
	WatchFrameScenarioFrame.slidingAction = "out";
	WATCHFRAME_SLIDEIN_ANIMATIONS["SCENARIO_OUT"].height = SCENARIO_POPUP_BASE_HEIGHT;
	WATCHFRAME_SLIDEIN_ANIMATIONS["SCENARIO_OUT"].scrollEnd = WATCHFRAME_SLIDEIN_ANIMATIONS["SCENARIO_OUT"].scrollStart;
	WatchFrame_SlideInFrame(WatchFrameScenarioFrame, "SCENARIO_OUT");
end

function WatchFrameScenario_OnFinishSlideOut()
	WatchFrameScenarioFrame.slidingAction = nil;
	WatchFrameScenarioFrame.ScrollChild.BlockHeader.stageComplete:Hide();
	WatchFrameScenarioFrame.dirty = true;
	WatchFrame_Update();
	local name, currentStage, numStages = C_Scenario.GetInfo();
	if ( currentStage and currentStage <= numStages ) then
		WatchFrameScenario_SlideIn();
	end
end

function WatchFrameScenario_OnBeginSlideOut()
	-- it's a little hacky to have this function but we want to play this animation
	-- when the header actually begins sliding out
	LevelUpDisplay_PlayScenario();
end

function WatchFrameScenarioBonusHeader_OnEnter(self)
	local bonusName, bonusDescription, numBonusCriteria, bonusStepFailed = C_Scenario.GetBonusStepInfo();
	if ( bonusStepFailed ) then
		return;
	end
	if ( not bonusName or bonusName == "" ) then
		bonusName = SCENARIO_BONUS_OBJECTIVES;
	end
	if ( not bonusDescription or bonusDescription == "" ) then
		bonusName = SCENARIO_BONUS_OBJECTIVES_DESCRIPTION;
	end	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 36);
	GameTooltip:SetText(bonusName, 1, 0.831, 0.380);
	GameTooltip:AddLine(bonusDescription, 1, 1, 1, 1);
	-- bonus rewards
	local dungeonID, randomID = GetPartyLFGID();
	if ( randomID ) then
		-- random takes precedence for determing rewards
		dungeonID = randomID;
	end
	if ( dungeonID ) then
		local firstReward = true;
		local numRewards = select(6, GetLFGDungeonRewards(dungeonID));
		for i = 1, numRewards do
			local name, texturePath, quantity, isBonusCurrency = GetLFGDungeonRewardInfo(dungeonID, i);
			if ( isBonusCurrency ) then
				if ( firstReward ) then
					GameTooltip:AddLine(" ");
					GameTooltip:AddLine(SCENARIO_BONUS_REWARD, 1, 0.831, 0.380);
					firstReward = false;
				end
				GameTooltip:AddLine(format(SCENARIO_BONUS_CURRENCY_FORMAT, quantity, name), 1, 1, 1);
				GameTooltip:AddTexture(texturePath);
			end
		end
	end
	GameTooltip:Show();
end

function WatchFrameScenarioBonusHeader_OnUpdate(self, elapsed)
	if ( self.updateTime ) then
		self.timeLeft = select(10, C_Scenario.GetBonusCriteriaInfo(self.timedCriteriaIndex));
		self.updateTime = nil;
	end
	self.timeLeft = self.timeLeft - elapsed;
	if ( self.timeLeft >= 0 ) then
		self.TimeLeft:SetText(GetTimeStringFromSeconds(self.timeLeft, nil, true));	-- only show hours if nonzero
	else
		WatchFrameScenario_UpdateScenario();
	end
end

--------------------------------------------------------------------------------------------
-- Slide-in Animations
--------------------------------------------------------------------------------------------
WATCHFRAME_SLIDEIN_ANIMATIONS = {
	["AUTOQUEST"] = { height = 72, scrollStart = 65, scrollEnd = -9, slideInTime = 0.4, onFinishFunc = WatchFrameAutoQuest_OnFinishSlideIn },
	["SCENARIO_IN"]  = { height = nil, scrollStart = nil, scrollEnd = 0, slideInTime = 0.4,
						 onFinishFunc = WatchFrameScenario_OnFinishSlideIn },										-- various content heights, nil values must be set
	["SCENARIO_OUT"] = { height = nil, scrollStart = 0, scrollEnd = nil, slideInTime = 0.4, reverse = true,
						 afterStartDelayFunc = WatchFrameScenario_OnBeginSlideOut,
						 onFinishFunc = WatchFrameScenario_OnFinishSlideOut, startDelay = 0.8, endDelay = 0.6 },	-- various content heights, nil values must be set
};

function WatchFrame_SlideInFrame(frame, animType)
	frame.totalTime = 0;
	frame.animData = WATCHFRAME_SLIDEIN_ANIMATIONS[animType];
	frame.slideInTime = frame.animData.slideInTime;
	frame:SetHeight(1);
	if ( frame.animData.reverse ) then
		frame:SetHeight(frame.animData["height"]);
	else
		frame:SetHeight(1);
	end
	frame.startDelay = frame.animData.startDelay;
	frame:SetScript("OnUpdate", WatchFrameSlideInFrame_OnUpdate);
end

function WatchFrameSlideInFrame_OnUpdate(frame, timestep)
	local animData = frame.animData;
	local height = animData.height;
	local scrollStart = animData.scrollStart;
	local scrollEnd = animData.scrollEnd;
	local endTime = animData.slideInTime + (animData.endDelay or 0);

	-- Pause animation while the lineframe shadow is animating
	if (WatchFrameLinesShadow.FadeIn:IsPlaying()) then
		return;
	end

	if (frame.startDelay) then
		frame.startDelay = frame.startDelay - timestep;
		if (frame.startDelay <= 0) then
			frame.startDelay = nil;
			if ( animData.afterStartDelayFunc ) then
				animData.afterStartDelayFunc();
			end
		else
			return;
		end
	end

	-- The first pop-up needs to include the WATCHFRAME_TYPE_OFFSET in the animation
	if (frame.isFirst) then
		height = height + WATCHFRAME_TYPE_OFFSET;
		scrollEnd = scrollEnd - WATCHFRAME_TYPE_OFFSET;
	end

	frame.totalTime = frame.totalTime+timestep;
	if (frame.totalTime > endTime) then
		frame.totalTime = endTime;
	end

	local scrollPos = scrollEnd;
	if (animData.slideInTime and animData.slideInTime > 0) then
		height = height*(frame.totalTime/animData.slideInTime);
		scrollPos = scrollStart + (scrollEnd-scrollStart)*(frame.totalTime/animData.slideInTime);
	end
	if ( animData.reverse ) then
		height = max(animData.height - height, 1);
	end
	frame:SetHeight(height);
	frame:UpdateScrollChildRect();
	frame:SetVerticalScroll(floor(scrollPos+0.5));

	if (frame.totalTime >= endTime) then
		frame:SetScript("OnUpdate", nil);
		WatchFrame_Update();
		if ( animData.onFinishFunc ) then
			animData.onFinishFunc(frame);
		end
	end
end
