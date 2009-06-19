-- Who watches the WatchFrame...?

WATCHFRAME_FADEDELAY = .5;
WATCHFRAME_FADETIME = .15;
WATCHFRAME_HOVERALPHA = 1;

WATCHFRAME_BORDERHEIGHT = 38;

WATCHFRAME_MINIMUMWIDTH = 220;
WATCHFRAME_COLLAPSEDWIDTH = 178;
WATCHFRAME_LASTWIDTH = 0;
MAX_LONG_CRITERIA_WIDTH = 260;
RegisterForSave("WATCHFRAME_LASTWIDTH");

WATCHFRAME_MINIMUMHEIGHT = 128;

WATCHFRAME_LINEHEIGHT = 16;
WATCHFRAME_LINEHEIGHT_PROGRESSBAR = 28;
WATCHFRAME_ICONXOFFSET = 24;
WATCHFRAME_QUESTTIMER_HEIGHT = 37;
WATCHFRAME_QUEST_WITH_ITEM_HEIGHT = 28;
WATCHFRAME_INITIAL_OFFSET = 0;
WATCHFRAME_TYPE_OFFSET = 5;
WATCHFRAME_QUEST_OFFSET = 10;

WATCHFRAME_ITEM_WIDTH = 33;

WATCHFRAMELINES_FONTSPACING = 0;
WATCHFRAMELINES_FONTHEIGHT = 0;
WATCHFRAMELINES_YOFFSET = 42;
WATCHFRAMELINES_XOFFSET = 24;

WATCHFRAME_MAXQUESTS = 10;
WATCHFRAME_MAXACHIEVEMENTS = 10;

WATCHFRAME_CRITERIA_PER_ACHIEVEMENT = 5;

WATCHFRAME_NUM_TIMERS = 0;
WATCHFRAME_NUM_ITEMS = 0;

WATCHFRAME_OBJECTIVEHANDLERS = {};

WATCHFRAME_TIMEDCRITERIA = {};

WATCHFRAME_TIMERLINES = {};
WATCHFRAME_ACHIEVEMENTLINES = {};
WATCHFRAME_QUESTLINES = {};

WATCHFRAME_LINKBUTTONS = {};

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
	if ( button ~= "RightButton" ) then
		WatchFrameLinkButtonTemplate_OnLeftClick(self);
		return;
	end
	
	local dropDown = WatchFrameDropDown;
	
	CloseDropDownMenus();
	
	dropDown.type = self.type;
	dropDown.index = self.index;
	UIFrameFadeOut(WatchFrameLines, WATCHFRAME_FADETIME, WatchFrameLines:GetAlpha(), .5);
	WatchFrame.dropDownOpen = true;
	WatchFrame.lastLinkButton = self;
	ToggleDropDownMenu(1, nil, dropDown, "cursor")
	self:Disable();
end

function WatchFrameLinkButtonTemplate_OnLeftClick (self)
	CloseDropDownMenus();
	if ( self.type == "QUEST" ) then
		ExpandQuestHeader(0);
		QuestLog_OpenToQuestIndex(GetQuestIndexForWatch(self.index));
		return;
	elseif ( self.type == "ACHIEVEMENT" ) then
		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end
	
		if ( not AchievementFrame:IsShown() ) then
			AchievementFrame_ToggleAchievementFrame();
		end
		AchievementFrame_SelectAchievement(self.index);
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

function WatchFrame_ToggleSimpleWatch ()
	local WatchFrame = WatchFrame; -- local references are faster
	if ( ADVANCED_WATCH_FRAME == "0" ) then
		WatchFrame.simpleMode = true;
		WatchFrame:SetUserPlaced(false);
		WatchFrame_SetBaseAlpha(0);
		WatchFrame:SetAlpha(0);
		WatchFrame_Expand(WatchFrame);
		WatchFrame_Lock(WatchFrame);
		WatchFrameTitleButton:Hide();
		WatchFrameCollapseExpandButton:Hide();
		WatchFrame_Update();
		UIParent_ManageFramePositions();
		WatchFrame:SetScript("OnUpdate", nil);
	elseif ( WatchFrame.simpleMode ) then -- We were at simple mode in some point, we need to undo some stuff...
		WatchFrame.simpleMode = nil;
		WatchFrame:SetUserPlaced(true);
		WatchFrame_Unlock(WatchFrame);
		WatchFrameTitleButton:Show();
		WatchFrameCollapseExpandButton:Show();
		WatchFrame_Update();
		WatchFrame:SetScript("OnUpdate", WatchFrame_OnUpdate);
		WatchFrame_ToggleIgnoreCursor(); -- Update cursor settings
	end
	if ( ArenaEnemyFrames_UpdateWatchFrame ) then
		ArenaEnemyFrames_UpdateWatchFrame();
	end
end

function WatchFrame_ToggleIgnoreCursor ()
	local WatchFrame = WatchFrame;
	if ( WATCHFRAME_IGNORECURSOR == "1" ) then
		WatchFrameTitleButton:Disable();
		WatchFrameCollapseExpandButton:Disable();
		WatchFrame_Lock(WatchFrame);
	else
		WatchFrameTitleButton:Enable();
		WatchFrameCollapseExpandButton:Enable();
	end
end

function WatchFrame_OnLoad (self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE");
	self:RegisterEvent("ITEM_PUSH");
	self:SetScript("OnSizeChanged", WatchFrame_OnSizeChanged); -- Has to be set here instead of in XML for now due to OnSizeChanged scripts getting run before OnLoad scripts.
	self.lineCache = UIFrameCache:New("FRAME", "WatchFrameLine", WatchFrameLines, "WatchFrameLineTemplate");
	self.buttonCache = UIFrameCache:New("BUTTON", "WatchFrameLinkButton", WatchFrameLines, "WatchFrameLinkButtonTemplate")
	watchFrameTestLine = self.lineCache:GetFrame();
	local _, fontHeight = watchFrameTestLine.text:GetFont();
	WATCHFRAMELINES_FONTHEIGHT = fontHeight;
	WATCHFRAMELINES_FONTSPACING = (WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTHEIGHT) / 2
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayQuestTimers);
	WatchFrame_AddObjectiveHandler(WatchFrame_HandleDisplayTrackedAchievements);
	WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
end

function WatchFrame_OnEvent (self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		if ( not GetCVarBool("advancedWatchFrame") ) then
			return;
		end
			
		-- Setup window appearance and behaviors		
		self.baseAlpha = tonumber(GetCVar("watchFrameBaseAlpha"));		
		WatchFrame:SetAlpha(self.baseAlpha);
		
		WatchFrame:SetUserPlaced(true);
		
		local flags = tonumber(GetCVar("watchFrameState"));
		for value, bitflag in next, WATCHFRAME_FLAGS do
			if ( bit.band(flags, bitflag) == bitflag ) then
				self[value] = true;
			end
		end

		local lastWidth = WATCHFRAME_LASTWIDTH;
		if ( self.collapsed ) then
			WatchFrame_Collapse(self);
		end
		WATCHFRAME_LASTWIDTH = lastWidth;
		
		if ( self.locked ) then
			WatchFrame_Lock(self);
		end
		
		local midPoint = self:GetLeft() + (self:GetRight() - self:GetLeft())/2;
		local uiParentMidPoint = (UIParent:GetRight() - UIParent:GetLeft())/2;
		if ( midPoint <= uiParentMidPoint ) then
			self.keepLeft = true;
		end
		
		WatchFrame_Update(self);
	elseif ( event == "QUEST_LOG_UPDATE" and not self.updating ) then -- May as well check here too and save some time
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
	end
end

function WatchFrame_OnUpdate (self, elapsed)
	if ( not self.collapsed and (WATCHFRAME_IGNORECURSOR == "1" or not MouseIsOver(WatchFrameMouseover) and not self.moving and not self.sizing and not (self.dropDownOpen and WatchFrameDropDown.type == "CONFIG")) ) then
		if ( self.timeEntered ) then		
			self.timeEntered = nil;
			self.fadeIn = nil;
			self.timeLeft = GetTime();
		elseif ( self.timeLeft and self.timeLeft + WATCHFRAME_FADEDELAY <= GetTime() ) then
			self.timeLeft = nil;
			UIFrameFadeOut(WatchFrame, WATCHFRAME_FADETIME, WatchFrame:GetAlpha(), self.baseAlpha);
		end			
	elseif ( not self.timeEntered ) then
		self.timeEntered = GetTime();
		self.timeLeft = nil;
	elseif ( self.timeEntered and self.timeEntered + WATCHFRAME_FADEDELAY <= GetTime() ) then
		if ( not self.fadeIn ) then 
			UIFrameFadeIn(WatchFrame, WATCHFRAME_FADETIME, WatchFrame:GetAlpha(), WATCHFRAME_HOVERALPHA);
			self.fadeIn = true;
		end
	end
	
	if ( self.moving ) then
		local midPoint = self:GetLeft() + (self:GetRight() - self:GetLeft())/2;
		local uiParentMidPoint = (UIParent:GetRight() - UIParent:GetLeft())/2;
		if ( not self.keepLeft and midPoint <= uiParentMidPoint - 5 ) then
			self.keepLeft = true;
			WatchFrame_Update(self);
		elseif ( self.keepLeft and midPoint >= uiParentMidPoint + 5 ) then
			self.keepLeft = nil;
			WatchFrame_Update(self);
		end
	end
end

function WatchFrame_ToggleLock ()
	local watchFrame = WatchFrame;
	if ( watchFrame.locked ) then
		WatchFrame_Unlock(watchFrame);
	else
		WatchFrame_Lock(watchFrame);
	end
end

function WatchFrame_Lock (self)
	self.locked = true;
	WatchFrameRightResizeThumb:Hide();
	WatchFrameLeftResizeThumb:Hide();
	if ( WATCHFRAME_IGNORECURSOR ~= "1" ) then
		WatchFrameTitleButton:RegisterForDrag("");
	end
	WatchFrame_UpdateStateCVar();
end

function WatchFrame_Unlock (self)
	self.locked = false;
	WatchFrameRightResizeThumb:Show();
	WatchFrameLeftResizeThumb:Show();
	if ( WATCHFRAME_IGNORECURSOR ~= "1" ) then
		WatchFrameTitleButton:RegisterForDrag("LeftButton");
	end
	WatchFrame_UpdateStateCVar();
end

function WatchFrame_Collapse (self)
	self.collapsed = true;
	WATCHFRAME_LASTWIDTH = WatchFrame:GetWidth();
	self:SetWidth(WATCHFRAME_COLLAPSEDWIDTH);
	WatchFrameLines:Hide();
	local button = WatchFrameCollapseExpandButton;
	button:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up");
	button:SetPushedTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Down");
	button:SetDisabledTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Disabled");	
	self:DisableDrawLayer("BORDER");
	self:EnableDrawLayer("ARTWORK");
	WatchFrameMouseover:SetPoint("BOTTOMRIGHT", WatchFrameCollapsedBorderRight, "BOTTOMRIGHT");
	WatchFrameDialogBG:Hide();
	WatchFrame_UpdateStateCVar();
end

function WatchFrame_Expand (self)
	self.collapsed = nil;
	self:SetWidth(max(WATCHFRAME_LASTWIDTH, WATCHFRAME_MINIMUMWIDTH));
	WATCHFRAME_LASTWIDTH = 0;
	WatchFrameLines:Show();
	local button = WatchFrameCollapseExpandButton;
	button:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up");
	button:SetPushedTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Down");
	button:SetDisabledTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Disabled");
	self:EnableDrawLayer("BORDER");
	self:DisableDrawLayer("ARTWORK");
	WatchFrameMouseover:SetPoint("BOTTOMRIGHT", WatchFrame, "BOTTOMRIGHT");
	WatchFrameDialogBG:Show();
	WatchFrame_Update(self);
	WatchFrame_UpdateStateCVar();
end

function WatchFrame_ShowOpacityFrameBaseAlpha ()
	OpacityFrame:ClearAllPoints();
	OpacityFrame:SetPoint("TOPRIGHT", "WatchFrame", "TOPLEFT", 0, 7);
	OpacityFrame.opacityFunc = WatchFrame_SetBaseAlpha;
	OpacityFrame:Show();
	OpacityFrameSlider:SetValue(1 - WatchFrame.baseAlpha);
end

function WatchFrame_SetBaseAlpha (alpha)
	local watchFrame = WatchFrame;
	alpha = alpha or (1 - OpacityFrameSlider:GetValue()) -- This is so terrible
	watchFrame.baseAlpha = alpha;
	SetCVar("watchFrameBaseAlpha", alpha);
	if ( not MouseIsOver(watchFrame) or OpacityFrame:IsShown() ) then -- We should be setting the current opacity
		WatchFrame:SetAlpha(alpha)	
	end
end

function WatchFrameTitleButton_OnClick (self, button, down)
	local watchFrame = WatchFrame;
	local dropDown = WatchFrameDropDown;
	if ( watchFrame.dropDownOpen and dropDown.type == "CONFIG" ) then
		dropDown.type = nil;
		CloseDropDownMenus();
		return;
	end
	
	CloseDropDownMenus();
	dropDown.type = "CONFIG";
	watchFrame.dropDownOpen = true;
	if ( WatchFrameLines:IsShown() ) then
		UIFrameFadeOut(WatchFrameLines, WATCHFRAME_FADETIME, WatchFrameLines:GetAlpha(), .5);
	end
	ToggleDropDownMenu(1, nil, dropDown, self:GetName(), 0, 0);
end

function WatchFrame_OnSizeChanged (self, width, height)
	WatchFrame_ClearDisplay();
	WatchFrame_Update(self)
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

function WatchFrame_GetRemainingSpace ()	
	local watchFrame = WatchFrame;
	if ( WATCHFRAME_NUM_TIMERS == 0 ) then
		return watchFrame:GetTop() - watchFrame:GetBottom() - WATCHFRAMELINES_YOFFSET - WATCHFRAME_QUESTTIMER_HEIGHT - math.abs(watchFrame.nextOffset);
	end
	
	return (watchFrame:GetTop() - watchFrame:GetBottom() - WATCHFRAMELINES_YOFFSET) - math.abs(watchFrame.nextOffset);
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
	
	local maxFrameWidth;
	if ( self.simpleMode ) then
		maxFrameWidth = 1024; -- Effectively meaningless number
	else
		maxFrameWidth = self:GetWidth() - WATCHFRAMELINES_XOFFSET;
	end
	
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
	
	WatchFrame_ReleaseUnusedLinkButtons();
	
	if ( self.simpleMode or not self.keepLeft ) then -- Keep right
		if ( not lineFrame.keepRight ) then
			lineFrame.keepRight = true;
			lineFrame.keepLeft = nil;
			lineFrame:ClearAllPoints();
			lineFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", -12, -30);
			lineFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -12, 12);
		end
		lineFrame:SetWidth(min(maxWidth, maxFrameWidth));
	elseif ( self.keepLeft ) then
		if ( not lineFrame.keepLeft ) then
			lineFrame.keepRight = nil;
			lineFrame.keepLeft = true;
			lineFrame:ClearAllPoints();
			lineFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 14, -30);
			lineFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -12, 12);
		end
	end
	
	if ( WATCHFRAME_NUM_TIMERS == 0 ) then
		self:SetMinResize(WATCHFRAME_MINIMUMWIDTH, max(WATCHFRAME_MINIMUMHEIGHT, -totalOffset + WATCHFRAME_QUESTTIMER_HEIGHT + WATCHFRAMELINES_YOFFSET))
	else
		self:SetMinResize(WATCHFRAME_MINIMUMWIDTH, max(WATCHFRAME_MINIMUMHEIGHT, -totalOffset + WATCHFRAMELINES_YOFFSET));
	end
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

function WatchFrame_GetHeightNeededForAchievement (achievementID)
	local _, name, _, completed, _, _, _, description = GetAchievementInfo(achievementID);
	if ( completed ) then
		return 0; -- Completed achievements can't be tracked, right?
	end
	
	local heightUsed = WATCHFRAME_LINEHEIGHT; -- Achievement title + icon
	
	if ( GetNumTrackedAchievements() > 1 ) then
		heightUsed = heightUsed + WATCHFRAME_QUEST_OFFSET;
	end
	
	local lineHeight = WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTSPACING;
	
	local numCriteria = GetAchievementNumCriteria(achievementID);
	if ( numCriteria == 0 ) then
		local frameWidth = WatchFrame:GetWidth() - WATCHFRAMELINES_XOFFSET;
		watchFrameTestLine.text:SetText(name);
		local maxWidth = watchFrameTestLine.text:GetStringWidth();
		
		watchFrameTestLine.text:SetText(" - ");
		local dashWidth = watchFrameTestLine.text:GetStringWidth();
		
		watchFrameTestLine.text:SetText(description);
		local stringWidth = watchFrameTestLine.text:GetStringWidth();
		local desiredWidth = math.ceil(stringWidth + dashWidth); -- This is how long we want the line to be with no wrapping
			
		if ( desiredWidth > maxWidth ) then
			maxWidth = min(desiredWidth, frameWidth);
		end
		
		local linesNeeded = math.ceil(stringWidth / (maxWidth - dashWidth));
		heightUsed = heightUsed + (WATCHFRAMELINES_FONTHEIGHT * linesNeeded);
		
		for criteriaID, timedCriteria in next, WATCHFRAME_TIMEDCRITERIA do
			if ( timedCriteria.achievementID == achievementID ) then
				heightUsed = heightUsed + lineHeight;
			end
		end
		
		return heightUsed;
	end
	
	local criteriaDisplayed = 0;
	for i = 1, numCriteria do
		local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(achievementID, i);
		if ( criteriaCompleted ) then
			-- Do nothing
		elseif ( criteriaDisplayed > WATCHFRAME_CRITERIA_PER_ACHIEVEMENT ) then
			return heightUsed;
		elseif ( criteriaDisplayed == WATCHFRAME_CRITERIA_PER_ACHIEVEMENT ) then
			heightUsed = heightUsed + lineHeight;
			return heightUsed;
		elseif ( bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR ) then
			if ( WATCHFRAME_TIMEDCRITERIA[criteriaID] ) then
				heightUsed = heightUsed + lineHeight;
			end
			heightUsed = heightUsed + WATCHFRAME_LINEHEIGHT_PROGRESSBAR;
			criteriaDisplayed = criteriaDisplayed + 2;
		else
			if ( WATCHFRAME_TIMEDCRITERIA[criteriaID] ) then
				heightUsed = heightUsed + lineHeight;
			end
			heightUsed = heightUsed + lineHeight;
			criteriaDisplayed = criteriaDisplayed + 1;
		end
	end
		
	return heightUsed;
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

function WatchFrame_DisplayTrackedAchievements (lineFrame, initialOffset, maxHeight, frameWidth, ...)
	local _; -- Doing this here thanks to IBLJerry!
	local self = WatchFrame;
	local numTrackedAchievements = select("#", ...);
	
	WatchFrame_ResetAchievementLines();
	
	local lineCache = WatchFrame.lineCache;
	local maxWidth = 0;
	local heightUsed = 0;
	local heightNeeded = 0;
	
	local achievementID;
	local achievementName, completed, description, icon;
	
	local line;
	local achievementTitle;
	local previousLine;
	local nextXOffset = 0;
	local linkButton;
		
	local numCriteria, criteriaDisplayed;
	local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, achievementCategory;

	local displayOnlyArena = (not WatchFrame:IsUserPlaced()) and ArenaEnemyFrames and ArenaEnemyFrames:IsShown();
	for i = 1, numTrackedAchievements do
		achievementID = select(i, ...);
		achievementCategory = GetAchievementCategory(achievementID);
		if ( (not displayOnlyArena) or achievementCategory == WATCHFRAME_ACHIEVEMENT_ARENA_CATEGORY ) then
			_, achievementName, _, completed, _, _, _, description, _, icon = GetAchievementInfo(achievementID);
			
			local heightNeeded = WatchFrame_GetHeightNeededForAchievement(achievementID);
			if ( heightNeeded > maxHeight + (initialOffset - heightUsed) ) then
				return heightUsed, maxWidth; -- We ran out of space to draw achievements, stop.
			else
				heightUsed = heightUsed + heightNeeded;
			end
			
			line = WatchFrame_GetAchievementLine();
			achievementTitle = line;
			line.text:SetText(achievementName);
			if ( completed ) then
				line.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			else
				line.text:SetTextColor(0.75, 0.61, 0);
			end
			line:Show()
			local lineWidth = line.text:GetStringWidth() + WATCHFRAME_ICONXOFFSET
			maxWidth = max(maxWidth, lineWidth)
			if ( previousLine ) then -- If this isn't the first displayed title, our position is relative to the last displayed line.
				local yOffset = 0;
				if ( previousLine.statusBar:IsShown() ) then
					yOffset = -5
				end
				
				line:SetPoint("TOPRIGHT", previousLine, "BOTTOMRIGHT", 0, yOffset - WATCHFRAME_QUEST_OFFSET);
				line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", nextXOffset, yOffset - WATCHFRAME_QUEST_OFFSET);
			else
				line:SetPoint("TOPRIGHT", lineFrame, "TOPRIGHT", 0, initialOffset);
				line:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, initialOffset);
			end
			if ( not self.disableButtons ) then
				linkButton = WatchFrame_GetLinkButton();
				linkButton:SetPoint("TOPLEFT", line.text);
				linkButton:SetPoint("BOTTOMLEFT", line.text);
				linkButton:SetWidth(lineWidth + WATCHFRAME_ICONXOFFSET);
				linkButton.type = "ACHIEVEMENT"
				linkButton.index = achievementID;
				linkButton:Show();
			end
			nextXOffset = 0;
			previousLine = line;
			numCriteria = GetAchievementNumCriteria(achievementID);
			if ( numCriteria > 0 ) then
				criteriaDisplayed = 0;
				for j = 1, numCriteria do
					criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(achievementID, j);
					if ( criteriaCompleted or ( criteriaDisplayed > WATCHFRAME_CRITERIA_PER_ACHIEVEMENT and not criteriaCompleted ) ) then
						-- Don't do anything
					elseif ( criteriaDisplayed == WATCHFRAME_CRITERIA_PER_ACHIEVEMENT ) then
						-- We ran out of space to display incomplete criteria >_<
						line = WatchFrame_GetAchievementLine();
						line.text:SetText(" - ");
						local dashWidth = line.text:GetStringWidth();
						nextXOffset = nextXOffset + dashWidth -- Offset as if there were a dash
						line.text:SetText("...");
						line.text:SetTextColor(0.8, 0.8, 0.8);
						line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", nextXOffset, 3);
						line:SetPoint("TOPRIGHT", previousLine, "BOTTOMRIGHT", 0, 3);
						line:Show();
						maxWidth = max(maxWidth, line.text:GetStringWidth()); -- I can't imagine this happening anytime soon really
						criteriaDisplayed = criteriaDisplayed + 1;
						previousLine = line;
						nextXOffset = -dashWidth;
					else
						if ( WATCHFRAME_TIMEDCRITERIA[criteriaID] ) then
							local timedCriteria = WATCHFRAME_TIMEDCRITERIA[criteriaID]
							line = WatchFrame_GetAchievementLine();
							line.criteriaID = criteriaID;
							line.duration = timedCriteria.duration;
							line.startTime = timedCriteria.startTime;
							
							local yOffset = WATCHFRAMELINES_FONTSPACING;
							if ( previousLine.statusBar:IsShown() ) then
								yOffset = yOffset - 5;
							end
							line:SetPoint("TOPRIGHT", previousLine, "BOTTOMRIGHT", 0, yOffset);
							line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", nextXOffset, yOffset);
							line:Show()
							criteriaDisplayed = criteriaDisplayed + 1;
							previousLine = line;
							nextXOffset = 0;
							WatchFrameLines_AddUpdateFunction(WatchFrame_UpdateTimedAchievements);
						end
						if ( bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR ) then
							line = WatchFrame_GetAchievementLine();
							line.statusBar:Show();
							line.statusBar:GetStatusBarTexture():SetVertexColor(0, 0.6, 0, 1);
							line.statusBar:SetMinMaxValues(0, totalQuantity);
							line.statusBar:SetValue(quantity);
							line.statusBar.text:SetText(quantityString);
							
							local yOffset = -5;
							if ( previousLine.statusBar:IsShown() ) then
								yOffset = -10;
							end
							
							line:SetPoint("TOPRIGHT", previousLine, "BOTTOMRIGHT", 0, yOffset);
							line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", nextXOffset, yOffset);					
							line:Show();
							maxWidth = max(maxWidth, 200);
							criteriaDisplayed = criteriaDisplayed + 2;
							nextXOffset = 0;
							previousLine = line;
						else
							line = WatchFrame_GetAchievementLine();
							line.text:SetText(" - " .. criteriaString);
							line.text:SetTextColor(0.8, 0.8, 0.8);
							local yOffset = WATCHFRAMELINES_FONTSPACING;
							if ( previousLine.statusBar:IsShown() ) then
								yOffset = yOffset - 5;
							end
							
							line:SetPoint("TOPRIGHT", previousLine, "BOTTOMRIGHT", 0, yOffset);
							line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", nextXOffset, yOffset);
							line:Show();
							maxWidth = max(maxWidth, line.text:GetStringWidth());
							criteriaDisplayed = criteriaDisplayed + 1;
							nextXOffset = 0;
							previousLine = line;
						end
					end
				end
			else
				local dash = WatchFrame_GetAchievementLine();
				dash.text:SetText(" - ");
				dash.text:SetTextColor(0.8, 0.8, 0.8);
				local yOffset = WATCHFRAMELINES_FONTSPACING;
				if ( previousLine.statusBar:IsShown() ) then
					yOffset = yOffset - 5;
				end
				
				local dashWidth = dash.text:GetStringWidth();
				
				dash:SetWidth(dashWidth);
				dash:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", nextXOffset, yOffset);
				dash:Show();
				
				line = WatchFrame_GetAchievementLine();
				line.text:SetText(description);
				line.text:SetTextColor(0.8, 0.8, 0.8);
				
				local stringWidth = line.text:GetStringWidth();
				local desiredWidth = math.ceil(stringWidth + dashWidth); -- This is how long we want the line to be with no wrapping
				
				if ( desiredWidth > maxWidth ) then
					maxWidth = min(desiredWidth, MAX_LONG_CRITERIA_WIDTH);
				end
				
				local linesNeeded = math.ceil(stringWidth / (maxWidth - dashWidth));
				
				line:SetPoint("TOPLEFT", dash, "TOPRIGHT");
				line:SetPoint("TOPRIGHT", previousLine, "TOPRIGHT", 0, yOffset);
				line:SetHeight((WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTSPACING) + (WATCHFRAMELINES_FONTHEIGHT * (linesNeeded - 1)));
				line:Show();
				
				nextXOffset = -dashWidth;
				previousLine = line;	
				
				for criteriaID, timedCriteria in next, WATCHFRAME_TIMEDCRITERIA do
					if ( timedCriteria.achievementID == achievementID ) then
						line = WatchFrame_GetAchievementLine();
						line.criteriaID = criteriaID;
						line.duration = timedCriteria.duration;
						line.startTime = timedCriteria.startTime;
						
						local yOffset = WATCHFRAMELINES_FONTSPACING;
						if ( previousLine.statusBar:IsShown() ) then
							yOffset = yOffset - 5;
						end
						line:SetPoint("TOPRIGHT", previousLine, "BOTTOMRIGHT", 0, yOffset);
						line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", nextXOffset, yOffset);
						line:Show()
						previousLine = line;
						nextXOffset = 0;
						WatchFrameLines_AddUpdateFunction(WatchFrame_UpdateTimedAchievements);
					end
				end					
			end
		end
	end

	WatchFrame_ReleaseUnusedAchievementLines();

	return heightUsed, maxWidth;
end

function WatchFrame_GetHeightNeededForQuest (questIndex)
	local numObjectives = GetNumQuestLeaderBoards(questIndex);

	if ( numObjectives == 0 ) then
		return 0;
	else		
		local height = (WATCHFRAME_LINEHEIGHT - WATCHFRAMELINES_FONTSPACING) * (numObjectives + 1); -- +1 for the title line
		if ( GetQuestLogSpecialItemInfo(questIndex) ) then
			height = max(height, WATCHFRAME_QUEST_WITH_ITEM_HEIGHT);
		end
				
		local numWatches = GetNumQuestWatches();
		if ( numWatches > 1 ) then
			height = height + WATCHFRAME_QUEST_OFFSET;
		end
		
		return height;
	end
end

function WatchFrame_DisplayTrackedQuests (lineFrame, initialOffset, maxHeight, frameWidth)
	local _;
	local self = WatchFrame;
	local numObjectives;
	local text, finished;
	local questTitle;
	local watchItemIndex = 0;
	local questIndex;
	local objectivesCompleted;

	WatchFrame_ResetQuestLines();
	
	local line;
	local lastLine;
	local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR;
	local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR;
	local linkButton;
	
	local heightNeeded = 0;
	local heightUsed = 0;
	local maxWidth = 0;
	
	local iconHeightLeft = 0;
	
	local numQuestWatches = GetNumQuestWatches();
	for i = 1, numQuestWatches do
		local questWidth = 0;
		questIndex = GetQuestIndexForWatch(i);
		if ( questIndex ) then
		
			local heightNeeded = WatchFrame_GetHeightNeededForQuest(questIndex);
			if ( heightNeeded > maxHeight + (initialOffset - heightUsed) ) then
				return heightUsed, maxWidth; -- We ran out of space to draw quests, stop.
			else
				heightUsed = heightUsed + heightNeeded;
			end
			
			local itemButton;
			
			numObjectives = GetNumQuestLeaderBoards(questIndex);
			if ( numObjectives > 0 ) then -- How did a quest with 0 objectives end up getting tracked again? Might as well still check it.
				line = WatchFrame_GetQuestLine();
				questTitle = line;
				line.text:SetText(GetQuestLogTitle(questIndex));
				line:Show();
				if ( not lastLine ) then -- First line
					line:SetPoint("TOPRIGHT", lineFrame, "TOPRIGHT", 0, initialOffset);
					line:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, initialOffset);
				else
					local yOffset = 0;
					if ( iconHeightLeft > 0 ) then
						yOffset = -iconHeightLeft;
					end
					
					line:SetPoint("TOPRIGHT", lastLine, "BOTTOMRIGHT", 0, yOffset - WATCHFRAME_QUEST_OFFSET);
					line:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, yOffset - WATCHFRAME_QUEST_OFFSET);
				end
				iconHeightLeft = 0;
				local stringWidth = line.text:GetStringWidth();
				if ( not self.disableButtons ) then
					linkButton = WatchFrame_GetLinkButton();
					linkButton:SetPoint("TOPLEFT", line);
					linkButton:SetPoint("BOTTOMLEFT", line);
					linkButton:SetPoint("RIGHT", line.text);
					linkButton.type = "QUEST"
					linkButton.index = i; -- We want the Watch index, we'll get the quest index later with GetQuestIndexForWatch(i);
					linkButton:Show();
				end
				
				local link, item, charges = GetQuestLogSpecialItemInfo(questIndex);
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
					WatchFrameItem_UpdateCooldown(itemButton);
					itemButton.rangeTimer = -1;
					line.text.clear = true;
					line.text:SetPoint("RIGHT", itemButton, "LEFT", -4, 0);
					iconHeightLeft = WATCHFRAME_QUEST_WITH_ITEM_HEIGHT - WATCHFRAMELINES_FONTHEIGHT - WATCHFRAMELINES_FONTSPACING; -- We've already displayed a line for this
					itemButton.maxStringWidth = stringWidth;
					questWidth = max(stringWidth + WATCHFRAME_ITEM_WIDTH, questWidth);
				else
					questWidth = max(stringWidth, questWidth);
				end
				
				lastLine = line;
				objectivesCompleted = 0;
				for j = 1, numObjectives do
					text, _, finished = GetQuestLogLeaderBoard(j, questIndex);
					line = WatchFrame_GetQuestLine();
					line.text:SetText(" - " .. text);
					if ( finished ) then
						line.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
						objectivesCompleted = objectivesCompleted + 1;
					else
						line.text:SetTextColor(0.8, 0.8, 0.8);
					end
					line:SetPoint("TOPRIGHT", lastLine, "BOTTOMRIGHT", 0, WATCHFRAMELINES_FONTSPACING);
					line:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, WATCHFRAMELINES_FONTSPACING);
					line:Show();
					stringWidth = line.text:GetStringWidth();
					if ( iconHeightLeft > 0 ) then
						line.text.clear = true;
						line.text:SetPoint("RIGHT", itemButton, "LEFT", -4, 0);
						itemButton.maxStringWidth = max(stringWidth, itemButton.maxStringWidth)
						questWidth = max(stringWidth + WATCHFRAME_ITEM_WIDTH, questWidth);
					else
						questWidth = max(stringWidth, questWidth);
					end
					lastLine = line;
					iconHeightLeft = iconHeightLeft - WATCHFRAMELINES_FONTHEIGHT - WATCHFRAMELINES_FONTSPACING;
				end
				
				if ( objectivesCompleted == numObjectives ) then
					questTitle.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				else
					questTitle.text:SetTextColor(0.75, 0.61, 0);
				end			
			end
			
			if ( itemButton ) then
				itemButton:SetPoint("TOPRIGHT", questTitle, "TOPRIGHT", 0, -WATCHFRAMELINES_FONTSPACING);
				itemButton:Show();
			end
			
			if ( itemButton ) then
				maxWidth = max(questWidth + WATCHFRAME_ITEM_WIDTH, maxWidth);
			else
				maxWidth = max(questWidth, maxWidth);
			end
		end
	end
	
	for i = watchItemIndex + 1, WATCHFRAME_NUM_ITEMS do
		_G["WatchFrameItem" .. i]:Hide();
	end
	
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
	ExpandQuestHeader(0);
	QuestLog_OpenToQuestIndex(GetQuestIndexForWatch(arg1));
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
end

function WatchFrame_OpenAchievementFrame (button, arg1, arg2, checked)
	if ( not AchievementFrame ) then
		AchievementFrame_LoadUI();
	end
	
	if ( not AchievementFrame:IsShown() ) then
		AchievementFrame_ToggleAchievementFrame();
	end
	
	AchievementFrame_SelectAchievement(arg1);
end

function WatchFrame_StopTrackingAchievement (button, arg1, arg2, checked)
	RemoveTrackedAchievement(arg1);
	WatchFrame_Update();
	if ( AchievementFrame ) then
		AchievementFrameAchievements_ForceUpdate(); -- Quests handle this automatically because they have spiffy events.
	end
end

function WatchFrame_OpenToObjectivesCategory (button, arg1, arg2, checked)
	InterfaceOptionsFrame_OpenToCategory(OBJECTIVES_LABEL);
end

function WatchFrameDropDown_OnHide ()
	if ( WatchFrameLines:IsShown() ) then 
		UIFrameFadeIn(WatchFrameLines, WATCHFRAME_FADETIME, WatchFrameLines:GetAlpha(), 1); 
	end 
	
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
		
		if ( GetQuestLogPushable(GetQuestIndexForWatch(self.index)) ) then
			info.text = SHARE_QUEST;
			info.func = WatchFrame_ShareQuest;
			info.arg1 = self.index;
			info.checked = false;
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		end
		
		info.text = ABANDON_QUEST;
		info.func = WatchFrame_AbandonQuest;
		info.arg1 = self.index;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
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
	elseif ( self.type == "CONFIG" ) then
		local info = UIDropDownMenu_CreateInfo();
		
		info.text = ((WatchFrame.locked and UNLOCK_WINDOW) or LOCK_WINDOW);
		info.func = WatchFrame_ToggleLock;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		info.text = CHANGE_OPACITY
		info.func = WatchFrame_ShowOpacityFrameBaseAlpha;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
		
		info.text = SETTINGS;
		info.func = WatchFrame_OpenToObjectivesCategory;
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
	if ( self.text.clear ) then
		self.text.clear = nil;
		self.text:ClearAllPoints();
		self.text:SetPoint("TOPLEFT");
		self.text:SetPoint("BOTTOMRIGHT");
	end
	self.text:SetText("");
	self.text:SetTextColor(1, 1, 1);
	self.text:Show();
	self.statusBar:Hide();
	self:SetHeight(WATCHFRAME_LINEHEIGHT);
	self.criteriaID = nil;
end

function WatchFrameLineTemplate_OnLoad (self)
	local name = self:GetName();
	self.text = _G[name .. "Text"];
	self.statusBar = _G[name .. "StatusBar"];
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
			if ( not GetQuestLogSpecialItemInfo(self:GetID()) ) then
				WatchFrame_Update();
				return;
			end
			local count = getglobal(self:GetName().."HotKey");
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
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetQuestLogSpecialItem(self:GetID());
end
		
function WatchFrameItem_OnClick (self, button, down)
	UseQuestLogSpecialItem(self:GetID());
end
