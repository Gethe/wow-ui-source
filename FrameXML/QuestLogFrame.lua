-- global constants
MAX_QUESTS = 25;
MAX_OBJECTIVES = 10;
MAX_QUESTLOG_QUESTS = 25;
MAX_WATCHABLE_QUESTS = 25;
MAX_QUEST_WATCH_TIME = 300;

QuestDifficultyColors["impossible"].font = QuestDifficulty_Impossible;
QuestDifficultyColors["verydifficult"].font = QuestDifficulty_VeryDifficult;
QuestDifficultyColors["difficult"].font = QuestDifficulty_Difficult;
QuestDifficultyColors["standard"].font = QuestDifficulty_Standard;
QuestDifficultyColors["trivial"].font = QuestDifficulty_Trivial;
QuestDifficultyColors["header"].font = QuestDifficulty_Header;

-- local constants
local QUEST_TIMER_UPDATE_DELAY = 0.1;
local GROUP_UPDATE_INTERVAL_SEC = 3;

-- update optimizations
local max = max;

-- 
-- local helper functions
--

local function _QuestLog_HighlightQuest(questLogTitle)
	local prevParent = QuestLogHighlightFrame:GetParent();
	if ( prevParent and prevParent ~= questLogTitle ) then
		-- set prev quest's colors back to normal
		local prevName = prevParent:GetName();
		prevParent:UnlockHighlight();
		prevParent.tag:SetTextColor(prevParent.r, prevParent.g, prevParent.b);
		prevParent.groupMates:SetTextColor(prevParent.r, prevParent.g, prevParent.b);
	end
	if ( questLogTitle ) then
		local name = questLogTitle:GetName();
		-- highlight the quest's colors
		questLogTitle.tag:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		questLogTitle.groupMates:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		questLogTitle:LockHighlight();
		-- reposition highlight frames
		QuestLogHighlightFrame:SetParent(questLogTitle);
		QuestLogHighlightFrame:SetPoint("TOPLEFT", questLogTitle, "TOPLEFT", 0, 0);
		QuestLogHighlightFrame:SetPoint("BOTTOMRIGHT", questLogTitle, "BOTTOMRIGHT", 0, 0);
		QuestLogSkillHighlight:SetVertexColor(questLogTitle.r, questLogTitle.g, questLogTitle.b);
		QuestLogHighlightFrame:Show();
	else
		QuestLogHighlightFrame:Hide();
	end
end

-- this function returns the amount needed to adjust the scroll bar in order to get the given quest index to appear in the
-- QuestLogScrollFrame's viewable area
local function _QuestLog_GetQuestScrollOffset(questIndex)
	local scrollBarOffset = 0;
	local buttons = QuestLogScrollFrame.buttons;
	local testButton = buttons[1];
	local testIndex = testButton:GetID();
	local buttonHeight = testButton:GetHeight();
	if ( questIndex <= testIndex ) then
		if ( questIndex < testIndex ) then
			-- selected quest comes before the first visible quest

			-- instead of just offsetting by the delta of the indexes, we offset by 1 more to get the line BEFORE the selected
			-- line to be at the top...if we don't do this, then the selected line would be at the top of the frame, which
			-- isn't bad, but it feels better if we have the previous element at the top
			scrollBarOffset = (testIndex - questIndex + 1) * buttonHeight;
		end
		-- make sure the visible area is aligned to the top of a button by adding the difference between the button's
		-- top and the scroll area's top
		scrollBarOffset = scrollBarOffset - (QuestLogScrollFrame:GetTop() - testButton:GetTop());
	else
		local numButtons = #buttons;
		testButton = buttons[numButtons];
		testIndex = max(testButton:GetID(), numButtons);	--If the buttons aren't initalized, this will default to the last button. The index of the last button should never be greater than it's ID otherwise
		if ( questIndex >= (testIndex - 1) ) then
			if ( questIndex > testIndex ) then
				-- selected quest comes after the last visible quest
				-- instead of just offsetting by the delta of the indexes, we offset by 1 more to get the line AFTER the selected
				-- line to be at the bottom...if we don't do this, then the selected line would be at the bottom of the frame, which
				-- isn't bad, but it feels better if we have the next element at the bottom
				scrollBarOffset = (testIndex - questIndex - 1) * buttonHeight;
			end
			-- make sure the visible area is aligned to the bottom of a button by adding the difference between the button's
			-- bottom and the scroll area's bottom
			if ( questIndex == (testIndex - 1) ) then
				testButton = buttons[numButtons - 1];
			end
			local testBottom = testButton:GetBottom();
			local scrollBottom = QuestLogScrollFrame:GetBottom();
			if ( scrollBottom > testBottom ) then
				-- don't add the offset unless the test button is actually lower than the scroll frame...it feels jumpy if you do
				scrollBarOffset = scrollBarOffset + (testBottom - scrollBottom);
			end
		end
	end
	return scrollBarOffset;
end

local function _QuestLog_ToggleQuestWatch(questIndex)
	if ( IsQuestWatched(questIndex) ) then
		RemoveQuestWatch(questIndex);
		WatchFrame_Update();
	else
		if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then -- Check this first though it's less likely, otherwise they could make the frame bigger and be disappointed
			UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0);
			return;
		end
		AddQuestWatch(questIndex);
		WatchFrame_Update();
	end
end

-- 
-- QuestLogTitleButton
--

function QuestLogTitleButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");

	-- anchor the check to the normal text now since we can't do it with the way it's currently setup in XML
	local name = self:GetName();
	self.check:SetPoint("LEFT", name.."NormalText", "RIGHT", 2, 0);
end

function QuestLogTitleButton_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide();
		QuestLog_UpdatePartyInfoTooltip(self);
	end
end

function QuestLogTitleButton_OnClick(self, button)
	local questName = self:GetText();
	local questIndex = self:GetID();
	if ( IsModifiedClick() ) then
		-- If header then return
		if ( self.isHeader ) then
			return;
		end
		-- Otherwise try to track it or put it into chat
		if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
			local questLink = GetQuestLink(questIndex);
			if ( questLink ) then
				ChatEdit_InsertLink(questLink);
			end
			QuestLog_SetSelection(questIndex);
		elseif ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			_QuestLog_ToggleQuestWatch(questIndex);
			QuestLog_SetSelection(questIndex);
			QuestLog_Update();
		end
	else
		QuestLog_SetSelection(questIndex);
	end
end

function QuestLogTitleButton_OnEnter(self)
	-- Set highlight
	local name = self:GetName();
	self.tag:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.groupMates:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	-- Set group info tooltip
	QuestLog_UpdatePartyInfoTooltip(self);
end

function QuestLogTitleButton_OnLeave(self)
	if ( self:GetID() ~= QuestLogFrame.selectedIndex ) then
		local name = self:GetName();
		self.tag:SetTextColor(self.r, self.g, self.b);
		self.groupMates:SetTextColor(self.r, self.g, self.b);
	end
	GameTooltip:Hide();
end

-- HACK ALERT --
-- QuestLogTitleButton_Resize contains a couple of big hacks to compensate for some weaknesses in the UI system
function QuestLogTitleButton_Resize(questLogTitle)
	-- the purpose of this function is to resize the contents of the questLogTitle button to fit inside its width

	-- first reset the width of the button's font string (called normal text)
	local questNormalText = questLogTitle.normalText;
	-- HACK: in order to reset the width of the font string to be exactly the width of the quest title text,
	-- we have to explicitly set the font string's width to 0 and then call SetText on the button
	questNormalText:SetWidth(0);
	questLogTitle:SetText(questLogTitle:GetText());

	local questTitleTag = questLogTitle.tag;
	local questCheck = questLogTitle.check;

	-- find the right edge of the text
	-- HACK: Unfortunately we can't just call questTitleTag:GetLeft() or questLogTitle:GetRight() to find right edges.
	-- The reason why is because SetWidth may be called on the questLogTitle button before we enter this function. The
	-- results of a SetWidth are not calculated until the next update tick; so in order to get the most up-to-date
	-- right edge, we call GetLeft() + GetWidth() instead of just GetRight()
	local rightEdge;
	if ( questTitleTag:IsShown() ) then
		-- adjust the normal text to not overrun the title tag
		if ( questCheck:IsShown() ) then
			--rightEdge = questTitleTag:GetLeft() - questCheck:GetWidth() - 2;
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth() - questTitleTag:GetWidth() - 4 - questCheck:GetWidth() - 2;
		else
			--rightEdge = questTitleTag:GetLeft();
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth() - questTitleTag:GetWidth() - 4;
		end
	else
		-- adjust the normal text to not overrun the button
		if ( questCheck:IsShown() ) then
			--rightEdge = questLogTitle:GetRight() - questCheck:GetWidth() - 2;
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth() - questCheck:GetWidth() - 2;
		else
			--rightEdge = questLogTitle:GetRight();
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth();
		end
	end
	-- subtract from the text width the number of pixels that overrun the right edge
	local questNormalTextWidth = questNormalText:GetWidth() - max(questNormalText:GetRight() - rightEdge, 0);
	questNormalText:SetWidth(questNormalTextWidth);
end


function QuestLogScrollFrame_OnLoad(self)
	HybridScrollFrame_OnLoad(self);
	self.update = QuestLog_Update;
	HybridScrollFrame_CreateButtons(self, "QuestLogTitleButtonTemplate");
end


-- 
-- QuestLogFrame
--

function QuestLog_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("QUEST_WATCH_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	
	QuestLog_SetSelection(0);
end

function QuestLog_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") ) then
		QuestLog_Update();
		if ( QuestLogDetailScrollFrame:IsVisible() ) then
			QuestLog_UpdateQuestDetails(false);
			QuestLog_UpdateMap();
		end
	elseif ( event == "QUEST_ACCEPTED" ) then
		if ( AUTO_QUEST_WATCH == "1" and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS ) then
			AddQuestWatch(arg1);
			QuestLog_Update();
		end
	elseif ( event == "QUEST_WATCH_UPDATE" ) then
		if ( AUTO_QUEST_PROGRESS == "1" and 
			 GetNumQuestLeaderBoards(arg1) > 0 and 
			 GetNumQuestWatches() < MAX_WATCHABLE_QUESTS ) then
			AddQuestWatch(arg1,MAX_QUEST_WATCH_TIME);
			QuestLog_Update();
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
		QuestLog_Update();
		if ( event == "PARTY_MEMBERS_CHANGED" ) then
			QuestLogControlPanel_UpdateState();
		end
	elseif ( event == "DISPLAY_SIZE_CHANGED" and self:IsShown() ) then
		for _, questTitleButton in pairs(QuestLogScrollFrame.buttons) do
			QuestLogTitleButton_Resize(questTitleButton);
		end
	end
end

function QuestLog_OnShow(self)
	if ( QuestLogDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogDetailFrame);
	end
	UpdateMicroButtons();
	PlaySound("igQuestLogOpen");
	QuestLogControlPanel_UpdatePosition();
	QuestLogShowMapPOI_UpdatePosition();
	QuestLog_SetSelection(GetQuestLogSelection());
	QuestLog_Update();
	
	QuestLogDetailFrame_AttachToQuestLog();
end

function QuestLog_OnHide(self)
	UpdateMicroButtons();
	PlaySound("igQuestLogClose");
	QuestLogShowMapPOI_UpdatePosition();
	QuestLogControlPanel_UpdatePosition();
	
	QuestLogDetailFrame_DetachFromQuestLog();
end

function QuestLog_OnUpdate(self, elapsed)
	if ( self.groupUpdateTimer ) then
		-- this updates the quest log periodically so we can accurately update the number of group members sharing
		-- quests with the player
		self.groupUpdateTimer = self.groupUpdateTimer + elapsed;
		if ( self.groupUpdateTimer > GROUP_UPDATE_INTERVAL_SEC ) then
			QuestLog_Update();
			self.groupUpdateTimer = 0;
		end
	end
end

function QuestLog_UpdateMapButton()
	if ( WatchFrame.showObjectives and GetNumQuestLogEntries() ~= 0 ) then
		QuestLogFrameShowMapButton:Show();
	else
		QuestLogFrameShowMapButton:Hide();
	end
end

function QuestLog_Update()
	if ( not QuestLogFrame:IsShown() ) then
		return;
	end
	
	local numEntries, numQuests = GetNumQuestLogEntries();
	if ( numEntries == 0 ) then
		HideUIPanel(QuestLogDetailFrame);
		QuestLogDetailFrame.timeLeft = nil;
		EmptyQuestLogFrame:Show();
		QuestLog_SetSelection(0);
	else
		EmptyQuestLogFrame:Hide();
	end

	QuestLog_UpdateMapButton();
	
	-- Update Quest Count
	QuestLog_UpdateQuestCount(numQuests);

	-- If no selection then set it to the first available quest
	local questLogSelection = GetQuestLogSelection();
	local haveSelection = questLogSelection ~= 0;
	if ( numQuests > 0 and not haveSelection ) then
		if ( QuestLogFrame.selectedIndex ) then
			QuestLog_SetNearestValidSelection();
		else
			QuestLog_SetFirstValidSelection();
		end
		questLogSelection = GetQuestLogSelection();
	end
	QuestLogFrame.selectedIndex = questLogSelection;
    
    --The counts may have changed with SetNearestValidSelection expanding quest headers.
    --Bug ID 170644
    numEntries, numQuests = GetNumQuestLogEntries();

	-- hide the details if we don't have a selected quest
	if ( not haveSelection ) then
		HideUIPanel(QuestLogDetailFrame);
	end

	-- update the group timer
	local haveGroup = GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1;
	if ( haveGroup ) then
		QuestLogFrame.groupUpdateTimer = 0;
	else
		QuestLogFrame.groupUpdateTimer = nil;
	end

	-- hide the highlight frame initially, it may be shown when we loop through the quest listing if a quest is selected
	QuestLogHighlightFrame:Hide();

	-- Update the quest listing
	local buttons = QuestLogScrollFrame.buttons;
	local numButtons = #buttons;
	local scrollOffset = HybridScrollFrame_GetOffset(QuestLogScrollFrame);
	local buttonHeight = buttons[1]:GetHeight();
	local displayedHeight = 0;

	local numPartyMembers = GetNumPartyMembers();
	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questNormalText, questCheck;
	local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, displayQuestID;
	local color;
	local partyMembersOnQuest, tempWidth, textWidth;
	for i=1, numButtons do
		questLogTitle = buttons[i];
		questIndex = i + scrollOffset;
		questLogTitle:SetID(questIndex);
		questTitleTag = questLogTitle.tag;
		questNumGroupMates = questLogTitle.groupMates;
		questCheck = questLogTitle.check;
		questNormalText = questLogTitle.normalText;
		if ( questIndex <= numEntries ) then
			title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, displayQuestID = GetQuestLogTitle(questIndex);

			if ( isHeader ) then
				-- set the title
				if ( title ) then
					questLogTitle:SetText(title);
				else
					questLogTitle:SetText("");
				end

				-- set the normal texture based on the header's collapsed state
				if ( isCollapsed ) then
					questLogTitle:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				else
					questLogTitle:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
				end
				questLogTitle:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");

				questNumGroupMates:Hide();
				questTitleTag:Hide();
				questCheck:Hide();
			else
				-- set the title
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					title = "["..level.."] " .. title;
				end
				if (questID and displayQuestID) then
					questLogTitle:SetText("  "..questID.." - "..title);
				else
					questLogTitle:SetText("  "..title);
				end

				-- this isn't a header, hide the header textures
				questLogTitle:SetNormalTexture("");
				questLogTitle:SetHighlightTexture("");

				-- If not a header see if any nearby group mates are on this quest
				partyMembersOnQuest = 0;
				for j=1, numPartyMembers do
					if ( IsUnitOnQuest(questIndex, "party"..j) ) then
						partyMembersOnQuest = partyMembersOnQuest + 1;
					end
				end
				if ( partyMembersOnQuest > 0 ) then
					questNumGroupMates:SetText("["..partyMembersOnQuest.."]");
					questNumGroupMates:Show();
				else
					questNumGroupMates:Hide();
				end

				-- figure out which tag to show, if any
				if ( isComplete and isComplete < 0 ) then
					questTag = FAILED;
				elseif ( isComplete and isComplete > 0 ) then
					questTag = COMPLETE;
				elseif ( isDaily ) then
					if ( questTag ) then
						questTag = format(DAILY_QUEST_TAG_TEMPLATE, questTag);
					else
						questTag = DAILY;
					end
				end
				if ( questTag ) then
					questTitleTag:SetText("("..questTag..")");
					questTitleTag:Show();
				else
					questTitleTag:Hide();
				end

				-- show the quest check if the quest is being watched
				if ( IsQuestWatched(questIndex) ) then
					questCheck:Show();
				else
					questCheck:Hide();
				end
			end

			-- Save if its a header or not
			questLogTitle.isHeader = isHeader;

			-- resize the title button so everything fits where it's supposed to
			QuestLogTitleButton_Resize(questLogTitle);

			-- Color the quest title and highlight according to the difficulty level
			if ( isHeader ) then
				color = QuestDifficultyColors["header"];
			else
				color = GetQuestDifficultyColor(level);
			end
			questTitleTag:SetTextColor(color.r, color.g, color.b);
			questLogTitle:SetNormalFontObject(color.font);
			questNumGroupMates:SetTextColor(color.r, color.g, color.b);
			questLogTitle.r = color.r;
			questLogTitle.g = color.g;
			questLogTitle.b = color.b;
			questLogTitle:Show();

			-- Place the highlight and lock the highlight state
			if ( questLogSelection == questIndex ) then
				_QuestLog_HighlightQuest(questLogTitle);
			else
				questLogTitle:UnlockHighlight();
			end
		else
			questLogTitle:Hide();
		end
		displayedHeight = displayedHeight + buttonHeight;
	end
	HybridScrollFrame_Update(QuestLogScrollFrame, numEntries * buttonHeight, displayedHeight);

	-- update the control panel
	QuestLogControlPanel_UpdateState();
end

function QuestLog_UpdateQuestCount(numQuests)
	QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, numQuests, MAX_QUESTLOG_QUESTS);
	local textHeight = 12;
	local hPadding = 15;
	local vPadding = 8;
	local dailyQuestsComplete = GetDailyQuestsCompleted();
	local parent = QuestLogCount:GetParent();
	local width = QuestLogQuestCount:GetWidth();

	if ( dailyQuestsComplete > 0 ) then
		QuestLogDailyQuestCount:SetFormattedText(QUEST_LOG_DAILY_COUNT_TEMPLATE, dailyQuestsComplete, GetMaxDailyQuests());
		QuestLogDailyQuestCount:Show();
		QuestLogDailyQuestCountMouseOverFrame:Show();
		if ( QuestLogDailyQuestCount:GetWidth() > width ) then
			width = QuestLogDailyQuestCount:GetWidth();
		end
		QuestLogCount:SetHeight(textHeight*2+vPadding);
		QuestLogCount:SetPoint("TOPLEFT", parent, "TOPLEFT", 80, -38);
	else
		QuestLogDailyQuestCount:Hide();
		QuestLogDailyQuestCountMouseOverFrame:Hide();
		QuestLogCount:SetHeight(textHeight+vPadding);
		QuestLogCount:SetPoint("TOPLEFT", parent, "TOPLEFT", 80, -41);
	end
	QuestLogCount:SetWidth(width+hPadding);
end

function QuestLog_UpdateQuestDetails(resetScrollBar)
	QuestInfo_Display(QUEST_TEMPLATE_LOG, QuestLogDetailScrollChildFrame)
	if ( resetScrollBar ) then
		QuestLogDetailScrollFrameScrollBar:SetValue(0);
	end	
	QuestLogDetailScrollFrame:Show();
end

function QuestLog_UpdateMap()
	-- Fill in map tiles
	local mapFileName, textureHeight = GetMapInfo();
	if ( not mapFileName ) then
		return;
	end
	local texName;
	local dungeonLevel = GetCurrentMapDungeonLevel();
	local completeMapFileName;
	if ( dungeonLevel > 0 ) then
		completeMapFileName = mapFileName..dungeonLevel.."_";
	else
		completeMapFileName = mapFileName;
	end
	local mapFrameWidth = QuestLogMapFrame:GetRight() - QuestLogMapFrame:GetLeft();
	local mapFrameHeight = QuestLogMapFrame:GetTop() - QuestLogMapFrame:GetBottom();
	local tileWidth = mapFrameWidth / NUM_WORLDMAP_DETAIL_TILE_COLS;
	-- there are a few unused pixels on the bottom of the bottom row's map tiles, so fudge the map height
	-- to account for these extra pixels
	local tileHeight = (mapFrameHeight) / NUM_WORLDMAP_DETAIL_TILE_ROWS;
	local tile;
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		tile = _G["QuestLogMapFrame"..i];
		tile:SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..completeMapFileName..i);
--[[
		tile:SetWidth(tileWidth);
--]]
		tile:SetHeight(tileHeight);
	end
end

function QuestLog_UpdatePartyInfoTooltip(questLogTitle)
	local numPartyMembers = GetNumPartyMembers();
	if ( numPartyMembers == 0 or questLogTitle.isHeader ) then
		return;
	end

	GameTooltip_SetDefaultAnchor(GameTooltip, questLogTitle);

	local questIndex = questLogTitle:GetID();
	local title = GetQuestLogTitle(questIndex);
	GameTooltip:SetText(title);

	local partyMemberOnQuest = false;
	for i=1, numPartyMembers do
		if ( IsUnitOnQuest(questIndex, "party"..i) ) then
			if ( not partyMemberOnQuest ) then
				GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..PARTY_QUEST_STATUS_ON..FONT_COLOR_CODE_CLOSE);
				partyMemberOnQuest = true;
			end
			GameTooltip:AddLine(LIGHTYELLOW_FONT_COLOR_CODE..UnitName("party"..i)..FONT_COLOR_CODE_CLOSE);
		end
	end
	if ( not partyMemberOnQuest ) then
		--GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..PARTY_QUEST_STATUS_NONE..FONT_COLOR_CODE_CLOSE);
		GameTooltip:Hide();
	else
		GameTooltip:Show();
	end
end

function QuestLog_SetSelection(questIndex)
	SelectQuestLogEntry(questIndex);
	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
	SetAbandonQuest();

	QuestLogControlPanel_UpdateState();

	if ( questIndex == 0 ) then
		QuestLogFrame.selectedIndex = nil;
		HideUIPanel(QuestLogDetailFrame);
		QuestLogDetailScrollFrame:Hide();
		return;
	end

	local title, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(questIndex);
	if ( isHeader ) then
		if ( isCollapsed ) then
			ExpandQuestHeader(questIndex);
		else
			CollapseQuestHeader(questIndex);
		end
		return;
	end

	QuestLogFrame.selectedIndex = questIndex;

	local scrollBarOffset = _QuestLog_GetQuestScrollOffset(questIndex);
	if ( scrollBarOffset ~= 0 ) then
		-- adjust the scroll bar to show the quest, if necessary
		-- NOTE: this must be done BEFORE you highlight the quest (otherwise, the button you need to highlight may not be visible)
		QuestLogScrollFrameScrollBar:SetValue(QuestLogScrollFrameScrollBar:GetValue() - scrollBarOffset);
	end
	-- find and highlight the selected quest
	local buttons = QuestLogScrollFrame.buttons;
	local numButtons = #buttons;
	local min = 1;
	local max = #buttons;
	local mid;
	local titleButton, id;
	while ( min <= max ) do
		mid = bit.rshift(min + max, 1);
		titleButton = buttons[mid];
		id = titleButton:GetID();
		if ( id == questIndex ) then
			_QuestLog_HighlightQuest(titleButton);
			break;
		end
		if ( id > questIndex ) then
			max = mid - 1;
		else
			min = mid + 1;
		end
	end

	-- update the quest
	QuestLog_UpdateQuestDetails(true);
	QuestLog_UpdateMap();
	if ( not QuestLogFrame:IsShown() ) then
		ShowUIPanel(QuestLogDetailFrame);
	end
end

function QuestLog_UnsetSelection()
	QuestLog_SetSelection(0);
	QuestLog_Update();
end

function QuestLog_GetFirstSelectableQuest()
	local numEntries = GetNumQuestLogEntries();
	local title, level, questTag, suggestedGroup, isHeader, isCollapsed;
	for i=1, numEntries do
		title, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(i);
		if ( title and not isHeader ) then
			return i;
		end
	end
	return 0;
end

function QuestLog_SetFirstValidSelection()
	local selectableQuest = QuestLog_GetFirstSelectableQuest();
	QuestLog_SetSelection(selectableQuest);
	QuestLogDetailScrollFrameScrollBar:SetValue(0);
end

-- this function assumes that QuestLogFrame.selectedIndex points to an invalid quest
-- the most likely cause of this case is that the selected quest was abandoned
function QuestLog_SetNearestValidSelection()
	local numEntries = GetNumQuestLogEntries();
	if ( numEntries == 0 ) then
		QuestLog_SetSelection(0);
		return;
	end

	local questIndex = QuestLogFrame.selectedIndex;
	if ( questIndex > numEntries ) then
		-- if the index is now past the end of the list, treat it as if it were at the end of the list
		questIndex = numEntries;
	end

	local title, level, questTag, suggestedGroup, isHeader, isCollapsed;

	-- 1. try to select the quest that is currently under the selected index
	title, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(questIndex);
	if ( title and not isHeader ) then
		QuestLog_SetSelection(questIndex);
		QuestLogDetailScrollFrameScrollBar:SetValue(0);
		return;
	end

	-- 2. try to select the previous quest
	title, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(questIndex - 1);
	if ( title ) then
		if ( not isHeader ) then
			-- the previous quest is not a header, select it
			QuestLog_SetSelection(questIndex - 1);
			QuestLogDetailScrollFrameScrollBar:SetValue(0);
			return;
		else
			-- the previous quest is a header
			-- at this point, we will just expand the header if it is collapsed, then we will select the first quest under the header
			if ( isCollapsed ) then
				ExpandQuestHeader(questIndex - 1);
			end
			QuestLog_SetSelection(questIndex);
			QuestLogDetailScrollFrameScrollBar:SetValue(0);
			return;
		end
	end
	
	-- 3, Found nothing, so deselect
	QuestLog_SetSelection(0);
end

function QuestLog_OpenToQuest(questIndex, keepOpen)
	local selectedIndex = GetQuestLogSelection();
--[[
	if ( selectedIndex ~= 0 and questIndex == selectedIndex and QuestLogFrame:IsShown() and
		 _QuestLog_GetQuestScrollOffset(questIndex) == 0 ) then
		-- if the current quest is selected and is visible, then treat this as a toggle
		HideUIPanel(QuestLogFrame);
		return;
	end

	local numEntries, numQuests = GetNumQuestLogEntries();
	if ( questIndex < 1 or questIndex > numEntries ) then
		return;
	end

	ExpandQuestHeader(0);
	ShowUIPanel(QuestLogFrame);
	QuestLog_SetSelection(questIndex);
--]]

	if ( not keepOpen and selectedIndex ~= 0 and questIndex == selectedIndex and QuestLogDetailFrame:IsShown() ) then
		-- if the current quest is selected and is visible, then treat this as a toggle
		HideUIPanel(QuestLogDetailFrame);
		return;
	end

	local numEntries, numQuests = GetNumQuestLogEntries();
	if ( questIndex < 1 or questIndex > numEntries ) then
		return;
	end
	HideUIPanel(QuestFrame);
	QuestLog_SetSelection(questIndex);
end

--
-- QuestLogFrameTrackButton
--

function QuestLogFrameTrackButton_OnClick(self)
	_QuestLog_ToggleQuestWatch(GetQuestLogSelection());
	QuestLog_Update();
end


--
-- QuestLogDetailFrame
--

function QuestLogDetailFrame_OnShow(self)
	PlaySound("igQuestLogOpen");
	QuestLogControlPanel_UpdatePosition();	
	QuestLogShowMapPOI_UpdatePosition();
	QuestLog_UpdateQuestDetails();
end

function QuestLogDetailFrame_OnHide(self)
	-- this function effectively deselects the selected quest
	PlaySound("igQuestLogClose");	
	QuestLogControlPanel_UpdatePosition();
	QuestLogShowMapPOI_UpdatePosition();
end

function QuestLogDetailFrame_AttachToQuestLog()
	QuestLogDetailScrollFrame:SetParent(QuestLogFrame);
	QuestLogDetailScrollFrame:ClearAllPoints();
	QuestLogDetailScrollFrame:SetPoint("TOPRIGHT", QuestLogFrame, "TOPRIGHT", -32, -77);
	QuestLogDetailScrollFrame:SetHeight(333);
	QuestLogDetailScrollFrameScrollBar:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -13);
	QuestLogDetailScrollFrameScrollBackgroundBottomRight:Hide();
	QuestLogDetailScrollFrameScrollBackgroundTopLeft:Hide();
end

function QuestLogDetailFrame_DetachFromQuestLog()
	QuestLogDetailScrollFrame:SetParent(QuestLogDetailFrame);
	QuestLogDetailScrollFrame:ClearAllPoints();
	QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogDetailFrame, "TOPLEFT", 19, -76);
	QuestLogDetailScrollFrame:SetHeight(334);
	QuestLogDetailScrollFrameScrollBar:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -16);
	QuestLogDetailScrollFrameScrollBackgroundBottomRight:Show();
	QuestLogDetailScrollFrameScrollBackgroundTopLeft:Show();
end

function QuestLogDetailFrame_OnLoad(self)
	QuestLogDetailFrame_DetachFromQuestLog();
end

--
-- QuestLogControlPanel
--

function QuestLogControlPanel_UpdatePosition()
	local parent;
	if ( QuestLogFrame:IsShown() ) then
		parent = QuestLogFrame;
		QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 18, 11);
		QuestLogControlPanel:SetWidth(307);
	elseif ( QuestLogDetailFrame:IsShown() ) then
		parent = QuestLogDetailFrame;
		QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 18, 5);
		QuestLogControlPanel:SetWidth(327);
	end
	if ( parent ) then
		QuestLogControlPanel:SetParent(parent);
		QuestLogControlPanel:Show();
	else
		QuestLogControlPanel:Hide();
	end
end

function QuestLogControlPanel_UpdateState()
	local questLogSelection = GetQuestLogSelection();

	if ( questLogSelection == 0 ) then
		QuestLogFrameAbandonButton:Disable();
		QuestLogFrameTrackButton:Disable();
		QuestLogFramePushQuestButton:Disable();
	else
		if ( GetAbandonQuestName() ) then
			QuestLogFrameAbandonButton:Enable();
		else
			QuestLogFrameAbandonButton:Disable();
		end

		QuestLogFrameTrackButton:Enable();

		if ( GetQuestLogPushable() and ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1 ) ) then
			QuestLogFramePushQuestButton:Enable();
		else
			QuestLogFramePushQuestButton:Disable();
		end
	end
end

function QuestLogShowMapPOI_UpdatePosition()
	local parent;
	if ( QuestLogFrame:IsShown() ) then
		parent = QuestLogFrame;
	elseif ( QuestLogDetailFrame:IsShown() ) then
		parent = QuestLogDetailFrame;
	end
	
	if ( parent ) then
		QuestLogFrameShowMapButton:SetParent(parent);
		QuestLogFrameShowMapButton:SetPoint("TOPRIGHT", -25, -38);
	end
end