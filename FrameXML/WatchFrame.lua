-- Who watches the WatchFrame...?

WATCHFRAME_COLLAPSEDWIDTH = 0;		-- set in WatchFrame_OnLoad
WATCHFRAME_LASTWIDTH = 0;
WATCHFRAME_LINEHEIGHT = 16;
WATCHFRAME_MAXLINEWIDTH = 192;
WATCHFRAME_MULTIPLE_LINEHEIGHT = 29;
WATCHFRAME_ITEM_WIDTH = 33;

local DASH_NONE = 0;
local DASH_SHOW = 1;
local DASH_HIDE = 2;
local DASH_WIDTH;
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
WATCHFRAME_NUM_POI_ACTIVE = 0;
WATCHFRAME_NUM_POI_COMPLETED = 0;

WATCHFRAME_OBJECTIVEHANDLERS = {};
WATCHFRAME_TIMEDCRITERIA = {};
WATCHFRAME_TIMERLINES = {};
WATCHFRAME_ACHIEVEMENTLINES = {};
WATCHFRAME_QUESTLINES = {};
WATCHFRAME_LINKBUTTONS = {};
local WATCHFRAME_SETLINES = { };			-- buffer to hold lines for a quest/achievement that will be displayed only if there is room
local WATCHFRAME_SETLINES_NUMLINES;		-- the number of visual lines to be rendered for the buffered data - used just for item wrapping right now

CURRENT_MAP_QUESTS = { };

WATCHFRAME_FLAGS = { ["locked"] = 0x01, ["collapsed"] = 0x02 }

WATCHFRAME_ACHIEVEMENT_ARENA_CATEGORY = 165;

local watchFrameTestLine;

local function WatchFrame_UpdateStateCVar ()	
	local WatchFrame = WatchFrame;
	local flag = 0;
	for value, bitflag in pairs(WATCHFRAME_FLAGS) do
		if ( WatchFrame[value] == true ) then
			flag = flag + bitflag;
		end
	end
	SetCVar("watchFrameState", flag);
end

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
	if ( IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() ) then
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
			QuestLog_OpenToQuest( GetQuestIndexForWatch(self.index) );
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
	self:SetScript("OnSizeChanged", WatchFrame_OnSizeChanged); -- Has to be set here instead of in XML for now due to OnSizeChanged scripts getting run before OnLoad scripts.
	self.lineCache = UIFrameCache:New("FRAME", "WatchFrameLine", WatchFrameLines, "WatchFrameLineTemplate");
	self.buttonCache = UIFrameCache:New("BUTTON", "WatchFrameLinkButton", WatchFrameLines, "WatchFrameLinkButtonTemplate")
	watchFrameTestLine = self.lineCache:GetFrame();
	WATCHFRAME_COLLAPSEDWIDTH = WatchFrameTitle:GetWidth() + 50;
	local _, fontHeight = watchFrameTestLine.text:GetFont();
	watchFrameTestLine.dash:SetText(QUEST_DASH);
	DASH_WIDTH = watchFrameTestLine.dash:GetWidth();
	WATCHFRAMELINES_FONTHEIGHT = fontHeight;
	WATCHFRAMELINES_FONTSPACING = (WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTHEIGHT) / 2
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayQuestTimers);
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayTrackedAchievements);
	WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
end

function WatchFrame_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
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
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		if ( not WorldMapFrame:IsShown() and WatchFrame.showObjectives ) then
			WorldMapQuestScrollChildFrame.selected = nil;
			SetMapToCurrentZone();
		end
	elseif ( event == "WORLD_MAP_UPDATE" and WatchFrame.showObjectives ) then
		WatchFrame_GetCurrentMapQuests();
		WatchFrame_Update();
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		WatchFrame_OnSizeChanged(self);
	end
end

function WatchFrame_OnSizeChanged(self)
	WatchFrame_ClearDisplay();
	WatchFrame_Update(self)	
end

function WatchFrame_Collapse (self)
	self.collapsed = true;
	WATCHFRAME_LASTWIDTH = WatchFrame:GetWidth();
	self:SetWidth(WATCHFRAME_COLLAPSEDWIDTH);
	WatchFrameLines:Hide();
	local button = WatchFrameCollapseExpandButton;
	local texture = button:GetNormalTexture();
	texture:SetTexCoord(0, 0.5, 0, 0.5);
	texture = button:GetPushedTexture();	
	texture:SetTexCoord(0.5, 1, 0, 0.5);
	WatchFrame_UpdateStateCVar();
end

function WatchFrame_Expand (self)
	self.collapsed = nil;
	self:SetWidth(WATCHFRAME_LASTWIDTH);
	WATCHFRAME_LASTWIDTH = 0;
	WatchFrameLines:Show();
	local button = WatchFrameCollapseExpandButton;
	local texture = button:GetNormalTexture();
	texture:SetTexCoord(0, 0.5, 0.5, 1);
	texture = button:GetPushedTexture();
	texture:SetTexCoord(0.5, 1, 0.5, 1);
	WatchFrame_Update(self);
	WatchFrame_UpdateStateCVar();
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
end

function WatchFrame_Update (self)
	self = self or WatchFrame; -- Speeds things up if we pass in this reference when we can conveniently.
	-- Display things in this order: quest timers, achievements, quests, addon subscriptions.
	if ( self.updating ) then
		return;
	end
	
	self.updating = true;
	
	local pixelsUsed = 0;
	local totalOffset = WATCHFRAME_INITIAL_OFFSET;
	local lineFrame = WatchFrameLines;
	local maxHeight = (WatchFrame:GetTop() - WatchFrame:GetBottom()); -- Can't use lineFrame:GetHeight() because it could be an invalid rectangle (width of 0)
	
	local maxFrameWidth = WATCHFRAME_MAXLINEWIDTH;
	local maxWidth = 0;
	local maxLineWidth;
	
	WatchFrame_ResetLinkButtons();
	
	for i = 1, #WATCHFRAME_OBJECTIVEHANDLERS do
		pixelsUsed, maxLineWidth = WATCHFRAME_OBJECTIVEHANDLERS[i](lineFrame, totalOffset, maxHeight, maxFrameWidth);
		maxWidth = max(maxLineWidth, maxWidth);
		
		if ( pixelsUsed > 0 ) then
			totalOffset = totalOffset - WATCHFRAME_TYPE_OFFSET - pixelsUsed;
		end
	end
	--disabled for now, might make it an option
	--lineFrame:SetWidth(min(maxWidth, maxFrameWidth));
	
	if ( totalOffset < WATCHFRAME_INITIAL_OFFSET ) then
		WatchFrameTitle:Show();
		WatchFrameCollapseExpandButton:Show();		
	else
		WatchFrameTitle:Hide();
		WatchFrameCollapseExpandButton:Hide();
	end
	
	WatchFrame_ReleaseUnusedLinkButtons();
	
	self.updating = nil;
	self.nextOffset = totalOffset;
end

function WatchFrame_AddObjectiveHandler (func)
	local numFunctions = #WATCHFRAME_OBJECTIVEHANDLERS
	for i = 1, numFunctions do
		if ( WATCHFRAME_OBJECTIVEHANDLERS[i] == func ) then
			return;
		end
	end
	
	tinsert(WATCHFRAME_OBJECTIVEHANDLERS, func);
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

function WatchFrame_HandleDisplayQuestTimers (lineFrame, initialOffset, maxHeight, frameWidth)
	return WatchFrame_DisplayQuestTimers(lineFrame, initialOffset, maxHeight, frameWidth, GetQuestTimers());
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

function WatchFrame_DisplayQuestTimers (lineFrame, initialOffset, maxHeight, frameWidth, ...)
	local numTimers = select("#", ...);

	if ( numTimers == 0 ) then
		WatchFrame_ResetTimerLines();
		WatchFrame_ReleaseUnusedTimerLines();
		-- Nothing to see here, move along.
		if ( WATCHFRAME_NUM_TIMERS ~= 0 ) then
			WatchFrameLines_RemoveUpdateFunction(WatchFrame_HandleQuestTimerUpdate);
			WATCHFRAME_NUM_TIMERS = 0;
		end
		return 0, 0;
	end
	
	WatchFrame_ResetTimerLines();
	
	local lineCache = WatchFrame.lineCache;
	local maxWidth = 0;
	local heightUsed = 0;
	local watchFrame = WatchFrame;
	
	local line = WatchFrame_GetTimerLine();
	line.text:SetText(NORMAL_FONT_COLOR_CODE .. QUEST_TIMERS);
	line:Show();
	line:SetPoint("TOPRIGHT", lineFrame, "TOPRIGHT", 0, initialOffset);
	line:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, initialOffset);

	heightUsed = heightUsed + line:GetHeight();
	maxWidth = line.text:GetStringWidth();
	
	local lastLine = line;
	
	for i = 1, numTimers do
		line = WatchFrame_GetTimerLine();
		line.text:SetText(" - " .. SecondsToTime(select(i, ...)));
		line:Show();
		line:SetPoint("TOPRIGHT", lastLine, "BOTTOMRIGHT");
		line:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT");
		maxWidth = max(maxWidth, line.text:GetStringWidth());
		line:SetWidth(maxWidth) -- FIXME
		heightUsed = heightUsed + line:GetHeight();
		line:SetScript("OnEnter", function (self) GameTooltip:SetOwner(self); GameTooltip:SetHyperlink(GetQuestLink(GetQuestIndexForTimer(i))); GameTooltip:Show(); end);
		line:SetScript("OnLeave", GameTooltip_Hide);
		line:EnableMouse(true);
	end
	
	if ( WATCHFRAME_NUM_TIMERS ~= numTimers ) then
		WATCHFRAME_NUM_TIMERS = numTimers;
		WatchFrameLines_AddUpdateFunction(WatchFrame_HandleQuestTimerUpdate);
	end
	
	WatchFrame_ReleaseUnusedTimerLines();
	
	return heightUsed, maxWidth;
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
	
function WatchFrame_HandleDisplayTrackedAchievements (lineFrame, initialOffset, maxHeight, frameWidth)
	return WatchFrame_DisplayTrackedAchievements(lineFrame, initialOffset, maxHeight, frameWidth, GetTrackedAchievements());
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

function WatchFrame_SetLine(line, anchor, verticalOffset, isHeader, text, dash, hasItem)
	-- anchor
	if ( anchor ) then
		line:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, verticalOffset);
		line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, verticalOffset);
	end
	-- text
	line.text:SetText(text);
	if ( isHeader ) then
		WATCHFRAME_SETLINES_NUMLINES = 0;
		line.text:SetTextColor(0.75, 0.61, 0);
	else
		--this should be the default, set in WatchFrameLineTemplate_Reset
	end
	-- dash
	local usedWidth = 0;
	if ( dash == DASH_SHOW ) then
		line.dash:SetText(QUEST_DASH);
		usedWidth = DASH_WIDTH;
	elseif ( dash == DASH_HIDE ) then
		line.dash:SetText(QUEST_DASH);
		line.dash:Hide();
		usedWidth = DASH_WIDTH;
	end	
	-- multiple lines
	if ( hasItem and WATCHFRAME_SETLINES_NUMLINES < 2 ) then
		usedWidth = usedWidth + WATCHFRAME_ITEM_WIDTH;
	end
	line.text:SetWidth(WATCHFRAME_MAXLINEWIDTH - usedWidth);
	if ( line.text:GetHeight() > WATCHFRAME_LINEHEIGHT ) then
		line:SetHeight(WATCHFRAME_MULTIPLE_LINEHEIGHT);
		line.text:SetHeight(WATCHFRAME_MULTIPLE_LINEHEIGHT);
		WATCHFRAME_SETLINES_NUMLINES = WATCHFRAME_SETLINES_NUMLINES + 2;
	else
		WATCHFRAME_SETLINES_NUMLINES = WATCHFRAME_SETLINES_NUMLINES + 1;
	end
	tinsert(WATCHFRAME_SETLINES, line);	
end

function WatchFrame_DisplayTrackedAchievements (lineFrame, initialOffset, maxHeight, frameWidth, ...)
	local _; -- Doing this here thanks to IBLJerry!
	local numTrackedAchievements = select("#", ...);
	local line;
	local achievementTitle;
	local previousLine;
	local linkButton;
	
	local numCriteria, criteriaDisplayed;
	local achievementID, achievementName, completed, description, icon;
	local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, achievementCategory;
	local displayOnlyArena = ArenaEnemyFrames and ArenaEnemyFrames:IsShown();

	local lineWidth = 0;
	local maxWidth = 0;
	local heightUsed = 0;
	local topEdge = 0;
	
	WatchFrame_ResetAchievementLines();
	
	for i = 1, numTrackedAchievements do
		linesToShow = { };
		WATCHFRAME_SETLINES = table.wipe(WATCHFRAME_SETLINES or { });
		achievementID = select(i, ...);
		achievementCategory = GetAchievementCategory(achievementID);
		_, achievementName, _, completed, _, _, _, description, _, icon = GetAchievementInfo(achievementID);
		if ( not completed and (not displayOnlyArena) or achievementCategory == WATCHFRAME_ACHIEVEMENT_ARENA_CATEGORY ) then			
			-- achievement name
			line = WatchFrame_GetAchievementLine();
			achievementTitle = line;
			WatchFrame_SetLine(line, previousLine, -WATCHFRAME_QUEST_OFFSET, IS_HEADER, achievementName, DASH_NONE);
			if ( not previousLine ) then
				line:SetPoint("TOPRIGHT", lineFrame, "TOPRIGHT", 0, initialOffset);
				line:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, initialOffset);
				topEdge = line:GetTop();
			end
			previousLine = line;
			-- criteria
			numCriteria = GetAchievementNumCriteria(achievementID);
			if ( numCriteria > 0 ) then
				criteriaDisplayed = 0;
				for j = 1, numCriteria do
					local dash = DASH_SHOW;		-- default since most will have this
					criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(achievementID, j);
					if ( criteriaCompleted or ( criteriaDisplayed > WATCHFRAME_CRITERIA_PER_ACHIEVEMENT and not criteriaCompleted ) ) then
						-- Do not display this one
						criteriaString = nil;
						dash = DASH_NONE;
					elseif ( criteriaDisplayed == WATCHFRAME_CRITERIA_PER_ACHIEVEMENT ) then
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
						if ( bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR ) then
							-- progress bar
							criteriaString = quantityString;
						else
							-- regular criteria
							-- no need to do anything, criteriaString and dash are already set				
						end
					end
					-- set up the line
					if ( criteriaString ) then
						line = WatchFrame_GetAchievementLine();
						WatchFrame_SetLine(line, previousLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, criteriaString, dash);
						previousLine = line;
						criteriaDisplayed = criteriaDisplayed + 1;
					end
				end
			else
				-- single criteria type of achievement
				line = WatchFrame_GetAchievementLine();				
				WatchFrame_SetLine(line, previousLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, description, DASH_SHOW);
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
				linkButton:Show();
				
				if ( previousBottom ) then
					heightUsed = topEdge - previousBottom;
				else
					heightUsed = 1;
				end
			end
		end
	end

	WatchFrame_ReleaseUnusedAchievementLines();

	return heightUsed, maxWidth;
end

function WatchFrame_DisplayTrackedQuests (lineFrame, initialOffset, maxHeight, frameWidth)
	local _;
	local questTitle;
	local questIndex;	
	local line;
	local lastLine;
	local linkButton;
	local watchItemIndex = 0;
	
	local numActivePOI = 0;
	local numCompletedPOI = 0;
	
	local text, finished;	
	local numQuestWatches = GetNumQuestWatches();
	local numObjectives;
	local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID;

	local maxWidth = 0;
	local lineWidth = 0;
	local heightUsed = 0;	
	local topEdge = 0;

	WatchFrame_ResetQuestLines();
	
	for i = 1, numQuestWatches do
		WATCHFRAME_SETLINES = table.wipe(WATCHFRAME_SETLINES or { });
		questIndex = GetQuestIndexForWatch(i);
		if ( questIndex ) then
			title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(questIndex);
			local link, item, charges = GetQuestLogSpecialItemInfo(questIndex);
			line = WatchFrame_GetQuestLine();
			questTitle = line;
			WatchFrame_SetLine(line, lastLine, -WATCHFRAME_QUEST_OFFSET, IS_HEADER, title, DASH_NONE, item);
			if ( not lastLine ) then -- First line
				line:SetPoint("TOPRIGHT", lineFrame, "TOPRIGHT", 0, initialOffset);
				line:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, initialOffset);
				topEdge = line:GetTop();
			end
			lastLine = line;
			
			if ( isComplete ) then
				line = WatchFrame_GetQuestLine();
				WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, GetQuestLogCompletionText(questIndex), DASH_SHOW);
				lastLine = line;
			else
				numObjectives = GetNumQuestLeaderBoards(questIndex);
				for j = 1, numObjectives do
					text, _, finished = GetQuestLogLeaderBoard(j, questIndex);
					if ( not finished ) then
						text = WatchFrame_ReverseQuestObjective(text);
						line = WatchFrame_GetQuestLine();
						WatchFrame_SetLine(line, lastLine, WATCHFRAMELINES_FONTSPACING, not IS_HEADER, text, DASH_SHOW, item);
						lastLine = line;
					end
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

			-- NOTE: we're missing something to display required money for a quest...that should probably be added at some point

			-- turn on quest item
			local itemButton;
			if ( item ) then
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
			linkButton:Show();				
			-- quest POI icon
			if ( WatchFrame.showObjectives and CURRENT_MAP_QUESTS[questID] ) then
				if ( isComplete ) then
					numCompletedPOI = numCompletedPOI + 1;
				else
					numActivePOI = numActivePOI + 1;
				end
				questPOI = WatchFrame_GetQuestPOI(numActivePOI, CURRENT_MAP_QUESTS[questID], isComplete, numCompletedPOI);						
				questPOI:SetPoint("TOPRIGHT", questTitle, "TOPLEFT", 0, 5);
				questPOI:Show();
			end
			if ( lastBottom ) then
				heightUsed = topEdge - lastLine:GetBottom();
			else
				heightUsed = 1;
			end
		end
	end

	for i = watchItemIndex + 1, WATCHFRAME_NUM_ITEMS do
		_G["WatchFrameItem" .. i]:Hide();
	end
	WatchFrame_ClearQuestPOIs(numActivePOI, numCompletedPOI);	
	WatchFrame_ReleaseUnusedQuestLines();

	return heightUsed, maxWidth;	
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
	QuestLog_OpenToQuest(GetQuestIndexForWatch(arg1));
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
		WatchFrame.lastLinkButton:Enable(); 
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
		info.text = GetQuestLogTitle(GetQuestIndexForWatch(self.index))
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

		info = UIDropDownMenu_CreateInfo();
		info.notCheckable = 1;
		
		info.text = OBJECTIVES_VIEW_IN_QUESTLOG;
		info.func = WatchFrame_OpenQuestLog;
		info.arg1 = self.index;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = WatchFrame_StopTrackingQuest;
		info.arg1 = self.index;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		if ( GetQuestLogPushable(GetQuestIndexForWatch(self.index)) and ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1 ) ) then
			info.text = SHARE_QUEST;
			info.func = WatchFrame_ShareQuest;
			info.arg1 = self.index;
			info.checked = false;
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		end
		
		--[[
		if ( SHOW_QUEST_OBJECTIVES_ON_MAP == "1" ) then
			info.text = OBJECTIVES_SHOW_QUEST_MAP;
			info.func = WatchFrame_OpenMapToQuest;
			test = self
			info.arg1 = self.index;
			info.checked = false;
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		end
		]]--
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
		WatchFrame_Expand(WatchFrame);
		PlaySound("igMiniMapOpen");
	else
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
	CooldownFrame_SetTimer(itemCooldown, start, duration, enable);
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(self, 0.4, 0.4, 0.4);
	else
		SetItemButtonTextureVertexColor(self, 1, 1, 1);
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
			local link, item, charges = GetQuestLogSpecialItemInfo(self:GetID());
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
	if ( IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() ) then
		local link, item, charges = GetQuestLogSpecialItemInfo(questIndex);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	else
		UseQuestLogSpecialItem(questIndex);
	end
end

function WatchFrame_ReverseQuestObjective(text)
	local _, _, arg1, arg2 = string.find(text, "(.*):%s(.*)");
	if ( arg1 and arg2 ) then
		return arg2.." "..arg1;
	else
		return text;
	end
end

function WatchFrameLinkButtonTemplate_Highlight(self, onEnter)
	--for index, line in pairs(self.lines) do
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
					line.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					line.dash:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				else
					line.text:SetTextColor(0.8, 0.8, 0.8);
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

function WatchFrame_GetQuestPOI(buttonIndex, questIndex, isComplete, numComplete)
	if ( isComplete ) then
		buttonIndex = numComplete + MAX_QUESTLOG_QUESTS;
	end
	local poiButton = _G["WatchFrameQuestPOI"..buttonIndex];
	if ( not poiButton ) then
		poiButton = CreateFrame("Button", "WatchFrameQuestPOI"..buttonIndex, WatchFrameLines, "WorldMapQuestPOITemplate");
		poiButton:SetScript("OnEnter", nil);
		poiButton:SetScript("OnLeave", nil);
		poiButton:SetScript("OnClick", WatchFrameQuestPOI_OnClick);
		poiButton:SetScale(0.9);
		if ( isComplete ) then
			poiButton.turnin:Show();
			poiButton.number:Hide();
			WATCHFRAME_NUM_POI_COMPLETED = numComplete;
		else
			WATCHFRAME_NUM_POI_ACTIVE = buttonIndex;		
			buttonIndex = buttonIndex - 1;
			local size = 1 / QUEST_NUMERIC_ICONS_PER_ROW;
			local yOffset = 0.5 + floor(buttonIndex / QUEST_NUMERIC_ICONS_PER_ROW) * size;
			local xOffset = mod(buttonIndex, QUEST_NUMERIC_ICONS_PER_ROW) * size;
			poiButton.number:SetTexCoord(xOffset + 0.004, xOffset + size, yOffset + 0.004, yOffset + size);
		end
	end
	poiButton.isComplete = isComplete;
	poiButton.quest = questIndex;
	return poiButton;
end

function WatchFrame_ClearQuestPOIs(numActivePOI, numCompletedPOI)
	for i = numActivePOI + 1, WATCHFRAME_NUM_POI_ACTIVE do
		_G["WatchFrameQuestPOI"..i]:Hide();
	end
	for i = numCompletedPOI + 1, WATCHFRAME_NUM_POI_COMPLETED do
		_G["WatchFrameQuestPOI"..i + MAX_QUESTLOG_QUESTS]:Hide();
	end
end

function WatchFrameQuestPOI_OnClick(self)
	if ( not WorldMapFrame:IsShown() or WorldMapQuestScrollChildFrame.selected.index == self.quest ) then
		ToggleFrame(WorldMapFrame);
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
	WorldMapFrame_SelectQuest(_G["WorldMapQuestFrame"..self.quest]);
end

function WatchFrameQuestPOI_OnEnter(self)
end

function WatchFrameQuestPOI_OnLeave(self)
end