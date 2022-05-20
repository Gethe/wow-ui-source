QUESTS_DISPLAYED = 22;
QUESTLOG_QUEST_HEIGHT = 16;
UPDATE_DELAY = 0.1;
MAX_QUESTWATCH_LINES = 30;
MAX_NUM_PARTY_MEMBERS = 4;

--[[
Array-style table to keep track of watched quests and how long we've been watching them for.
	value.id = The quest ID.
	value.timer = Remaining time that we should watch the quest for (or QUEST_WATCH_NO_EXPIRE if we should always watch the quest).
		Note: The watch timer is a value that lives purely in the UI, so we're the source of truth for it.
]]
QUEST_WATCH_LIST = { };
MAX_QUEST_WATCH_TIMER = 300;
QUEST_WATCH_NO_EXPIRE = 999;

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


function ToggleQuestLog()
	if ( QuestLogFrame:IsVisible() ) then
		HideUIPanel(QuestLogFrame);
	else
		ShowUIPanel(QuestLogFrame);
	end
end

function QuestLogTitleButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
end

function QuestLogTitleButton_OnEvent(self, event)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide();
		QuestLog_UpdatePartyInfoTooltip(self);
	end
end

function QuestLog_OnLoad(self)
	self.selectedButtonID = 2;
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_WATCH_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_LEVEL_UP");
end


function QuestLog_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "PLAYER_LOGIN" ) then
		QuestWatch_OnLogin();
	elseif ( event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") ) then
		QuestLog_Update();
		QuestWatch_Update();
		if ( QuestLogFrame:IsVisible() ) then
			QuestLog_UpdateQuestDetails(1);
		end
		if ( GetCVar("autoQuestWatch") == "1" ) then
			AutoQuestWatch_CheckDeleted();
		end
	elseif ( event == "QUEST_WATCH_UPDATE" ) then
		if ( GetCVar("autoQuestWatch") == "1" ) then
			local questIndex = GetQuestLogIndexByID(arg1);
			AutoQuestWatch_Update(questIndex);
		end
	elseif ( eventy == "PLAYER_LEVEL_UP" ) then
		QuestLog_Update();
	else
		QuestLog_Update();
		if ( event == "GROUP_ROSTER_UPDATE" ) then
			-- Determine whether the selected quest is pushable or not
			if ( GetQuestLogPushable() and GetNumGroupMembers() > 0 ) then
				QuestFramePushQuestButton:Enable();
			else
				QuestFramePushQuestButton:Disable();
			end
		end
	end

end

function QuestLog_OnShow(self)
	if ( QuestLogDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogDetailFrame);
	end
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
	QuestLogControlPanel_UpdatePosition();
	-- QuestLogShowMapPOI_UpdatePosition();
	QuestLog_SetSelection(GetQuestLogSelection());
	QuestLogDetailFrame_AttachToQuestLog();
	QuestLog_Update();
	
end

function QuestLog_OnHide(self)
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
	QuestLogControlPanel_UpdatePosition();

	QuestLogDetailFrame_DetachFromQuestLog();
end

function QuestLog_OnUpdate(self, elapsed)
	if ( QuestLogFrame.hasTimer ) then
		QuestLogFrame.timePassed = QuestLogFrame.timePassed + elapsed;
		if ( QuestLogFrame.timePassed > UPDATE_DELAY ) then
			QuestLogTimerText:SetText(TIME_REMAINING.." "..SecondsToTime(GetQuestLogTimeLeft()));
			QuestLogFrame.timePassed = 0;
		end
	end
end

function QuestLog_Update(self)
	if ( not QuestLogFrame:IsShown() ) then
		return;
	end
	local numEntries, numQuests = GetNumQuestLogEntries();
	if ( numEntries == 0 ) then
		QuestLogListScrollFrame:Show()
		EmptyQuestLogFrame:Show();
		QuestLogFrameAbandonButton:Disable();
		QuestLogFrame.hasTimer = nil;
		QuestLogDetailScrollFrame:Hide();
	else
		EmptyQuestLogFrame:Hide();
		QuestLogFrameAbandonButton:Enable();
		QuestLogDetailScrollFrame:Show();
		QuestLogListScrollFrame:Show()
	end
	local questLogSelection = GetQuestLogSelection();
	-- If no selection then set it to the first available quest
	if ( questLogSelection == 0 ) then
		QuestLog_SetFirstValidSelection();
		questLogSelection = GetQuestLogSelection();
	end

	-- Update Quest Count
	QuestLogUpdateQuestCount(numQuests);
	local scrollOffset = HybridScrollFrame_GetOffset(QuestLogListScrollFrame);

	-- Update the quest listing
	QuestLogHighlightFrame:Hide();
	
	local buttons = QuestLogListScrollFrame.buttons;
	local buttonHeight = buttons[1]:GetHeight();
	local displayedHeight = 0;

	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questNormalText, questHighlight, questCheck;
	local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, color;
	local numPartyMembers, partyMembersOnQuest, tempWidth, textWidth;


	for i=1, QUESTS_DISPLAYED, 1 do
		questLogTitle = buttons[i];
		questIndex = i + scrollOffset;
		questLogTitle:SetID(questIndex);
		questTitleTag = questLogTitle.tag;
		questNumGroupMates = questLogTitle.groupMates;
		questCheck = questLogTitle.check;
		questNormalText = questLogTitle.normalText;
		-- Need to get the quest info here, for the buttons
		if ( questIndex <= numEntries ) then
			questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questIndex);
			if ( isHeader ) then
				if ( questLogTitleText ) then
					questLogTitle:SetText(questLogTitleText);
				else
					questLogTitle:SetText("");
				end
				
				if ( isCollapsed ) then
					questLogTitle:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				else
					questLogTitle:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
				end
				questLogTitle:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
				questNumGroupMates:SetText("");
				questTitleTag:Hide();
				questCheck:Hide();
			else
				questLogTitle:SetText("  "..questLogTitleText);
				--Set Dummy text to get text width *SUPER HACK*
				QuestLogDummyText:SetText("  "..questLogTitleText);

				questLogTitle:SetNormalTexture("");

				-- If not a header see if any nearby group mates are on this quest
				partyMembersOnQuest = 0;
				for j=1, GetNumSubgroupMembers() do
					if ( IsUnitOnQuest(questIndex, "party"..j) ) then
						partyMembersOnQuest = partyMembersOnQuest + 1;
					end
				end
				if ( partyMembersOnQuest > 0 ) then
					questNumGroupMates:SetText("["..partyMembersOnQuest.."]");
				else
					questNumGroupMates:SetText("");
				end
				-- this isn't a header, hide the header textures
				questLogTitle:SetNormalTexture("");
				questLogTitle:SetHighlightTexture("");
			end
			-- Save if its a header or not
			questLogTitle.isHeader = isHeader;

			-- Set the quest tag
			if ( isComplete and isComplete < 0 ) then
				questTag = FAILED;
			elseif ( isComplete and isComplete > 0 ) then
				questTag = COMPLETE;
			elseif ( frequency == LE_QUEST_FREQUENCY_DAILY ) then
				if ( questTag ) then
					questTag = format(DAILY_QUEST_TAG_TEMPLATE, questTag);
				else
					questTag = DAILY;
				end
			end
			if ( questTag ) then
				questTitleTag:SetText("("..questTag..")");
				-- Shrink text to accomdate quest tags without wrapping
				tempWidth = 275 - 15 - questTitleTag:GetWidth();
				
				if ( QuestLogDummyText:GetWidth() > tempWidth ) then
					textWidth = tempWidth;
				else
					textWidth = QuestLogDummyText:GetWidth();
				end
				
				questNormalText:SetWidth(tempWidth);
				
				-- If there's quest tag position check accordingly
				questCheck:Hide();
				if ( IsQuestWatched(questIndex) ) then
					if ( questNormalText:GetWidth() + 24 < 275 ) then
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", textWidth+24, 0);
					else
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", textWidth+10, 0);
					end
					questCheck:Show();
				end
			else
				-- TODO do logic for  watching
				questTitleTag:SetText("");
				-- -- Reset to max text width
				-- if ( questNormalText:GetWidth() > 275 ) then
				-- 	questNormalText:SetWidth(260);
				-- end

				-- -- Show check if quest is being watched
				-- questCheck:Hide();
				-- if ( IsQuestWatched(questIndex) ) then
				-- 	if ( questNormalText:GetWidth() + 24 < 275 ) then
				-- 		questCheck:SetPoint("LEFT", questLogTitle, "LEFT", QuestLogDummyText:GetWidth()+24, 0);
				-- 	else
				-- 		questCheck:SetPoint("LEFT", questNormalText, "LEFT", questNormalText:GetWidth(), 0);
				-- 	end
				-- 	print("Here2")
				-- 	questCheck:Show();
				-- end
			end

			-- Color the quest title and highlight according to the difficulty level
			if ( isHeader ) then
				color = QuestDifficultyColors["header"];
			else
				color = GetQuestDifficultyColor(level);
			end
			questLogTitle:SetNormalFontObject(color.font);
			questTitleTag:SetTextColor(color.r, color.g, color.b);
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

	-- Set the expand/collapse all button texture
	local numHeaders = 0;
	local notExpanded = 0;
	-- Somewhat redundant loop, but cleaner than the alternatives
	for i=1, numEntries, 1 do
		local index = i;
		local questLogTitleText, level, questTag, isHeader, isCollapsed = GetQuestLogTitle(i);
		if ( questLogTitleText and isHeader ) then
			numHeaders = numHeaders + 1;
			if ( isCollapsed ) then
				notExpanded = notExpanded + 1;
			end
		end
	end

	-- Update Quest Count
	QuestLogQuestCount:SetText(format(QUEST_LOG_COUNT_TEMPLATE, numQuests, MAX_QUESTLOG_QUESTS));

	HybridScrollFrame_Update(QuestLogListScrollFrame, numEntries * buttonHeight, displayedHeight);

	-- update the control panel
	QuestLogControlPanel_UpdateState();
end

function QuestLog_SetSelection(questIndex)

	SelectQuestLogEntry(questIndex);
	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
	SetAbandonQuest();
	if ( questIndex == 0 ) then
		QuestLogDetailScrollFrame:Hide();
		return;
	end	

	QuestLog_UpdateQuestDetails();

	local questLogTitleText, level, questTag, isHeader, isCollapsed = GetQuestLogTitle(questIndex);
	if ( isHeader ) then
		if ( isCollapsed ) then
			ExpandQuestHeader(questIndex);
		else
			CollapseQuestHeader(questIndex);
		end
		return;
	end
end

function QuestLog_UpdateQuestDetails(doNotScroll)
	QuestInfo_Display(QUEST_TEMPLATE_LOG, QuestLogDetailScrollChildFrame)
	if (not doNotScroll ) then
		QuestLogDetailScrollFrameScrollBar:SetValue(0);
	end	
	QuestLogDetailScrollFrame:Show();
end

function QuestLogTitleButton_OnClick(self, button)
	local questName = self:GetText();
	local questIndex = self:GetID() + HybridScrollFrame_GetOffset(QuestLogListScrollFrame);
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		-- If header then return
		if ( self.isHeader ) then
			return;
		end
		-- Otherwise trim leading whitespace and put it into chat
		ChatEdit_InsertLink(gsub(self:GetText(), " *(.*)", "%1"));
	elseif ( IsShiftKeyDown() ) then
		-- If header then return
		if ( self.isHeader ) then
			return;
		end

		-- Shift-click toggles quest-watch on this quest.
		if ( IsQuestWatched(questIndex) ) then
			local questID = GetQuestIDFromLogIndex(questIndex);
			for index, value in ipairs(QUEST_WATCH_LIST) do
				if ( value.id == questID ) then
					tremove(QUEST_WATCH_LIST, index);
				end
			end
			RemoveQuestWatch(questIndex);
			QuestWatch_Update();
		else
			-- Set error if no objectives
			if ( GetNumQuestLeaderBoards(questIndex) == 0 ) then
				UIErrorsFrame:AddMessage(QUEST_WATCH_NO_OBJECTIVES, 1.0, 0.1, 0.1, 1.0);
				return;
			end
			-- Set an error message if trying to show too many quests
			if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then
				UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0);
				return;
			end
			AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE);
			QuestWatch_Update();
		end
	end
	QuestLog_SetSelection(self:GetID())
	QuestLog_Update();
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
	if ( self:GetID() ~= GetQuestLogSelection()) then
		local name = self:GetName();
		self.tag:SetTextColor(self.r, self.g, self.b);
		self.groupMates:SetTextColor(self.r, self.g, self.b);
	end
	GameTooltip:Hide();
end

function QuestLog_UpdatePartyInfoTooltip(self)
	local index = self:GetID();
	local questName = tostring(self:GetText());
	local questID = GetQuestIDFromLogIndex(index);
	local numPartyMembers = GetNumSubgroupMembers();

	if ( numPartyMembers == 0 or self.isHeader ) then
		EventRegistry:TriggerEvent("QuestLogFrame.MouseOver", self, questName, questID, false);
		return;
	end
	EventRegistry:TriggerEvent("QuestLogFrame.MouseOver", self, questName, questID, true);
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	
	local questLogTitleText = GetQuestLogTitle(index);
	GameTooltip:SetText(questLogTitleText);

	local partyMemberOnQuest;
	for i=1, numPartyMembers do
		if ( IsUnitOnQuest(index, "party"..i) ) then
			if ( not partyMemberOnQuest ) then
				GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..PARTY_QUEST_STATUS_ON..FONT_COLOR_CODE_CLOSE);
				partyMemberOnQuest = 1;
			end
			GameTooltip:AddLine(LIGHTYELLOW_FONT_COLOR_CODE..UnitName("party"..i)..FONT_COLOR_CODE_CLOSE);
		end
	end
	if ( not partyMemberOnQuest ) then
		GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..PARTY_QUEST_STATUS_NONE..FONT_COLOR_CODE_CLOSE);
	end
	GameTooltip:Show();
end

function QuestLogRewardItem_OnClick(self)
	if ( IsModifiedClick("DRESSUP") ) then
		if ( self.rewardType ~= "spell" ) then
			DressUpItemLink(GetQuestLogItemLink(self.type, self:GetID()));
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local link;
		if (self.rewardType == "item") then
			link = GetQuestLogItemLink(self.type, self:GetID());
		elseif (self.rewardType== "spell") then
			link = GetQuestLogSpellLink(self:GetID());
		end

		if ( ChatEdit_InsertLink(link) ) then
			return true;
		elseif ( SocialPostFrame and Social_IsShown() and Social_InsertLink(link) ) then
			return true;
		end
	end
end


function QuestLog_GetFirstSelectableQuest()
	local numEntries = GetNumQuestLogEntries();
	local index = 0;
	local questLogTitleText, level, questTag, isHeader, isCollapsed;
	for i=1, numEntries, 1 do
		index = i;
		questLogTitleText, level, questTag, isHeader, isCollapsed = GetQuestLogTitle(i);
		if ( questLogTitleText and not isHeader ) then
			return index;
		end
	end
	return index;
end

function QuestLog_SetFirstValidSelection()
	local selectableQuest = QuestLog_GetFirstSelectableQuest();
	QuestLog_SetSelection(selectableQuest);
end

-- QuestWatch functions
function QuestWatch_OnLogin()
	-- Clear QUEST_WATCH_LIST, just to be safe.
	QUEST_WATCH_LIST = { };

	-- Initialize QUEST_WATCH_LIST.
	for i=1, GetNumQuestWatches() do
		local questIndex = GetQuestIndexForWatch(i);
		if ( questIndex ) then
			AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE);
		end
	end
end

-- TODO, need to update with correct LKC watchframe
function QuestWatch_Update()
	local numObjectives;
	local questWatchMaxWidth = 0;
	local tempWidth;
	local watchText;
	local text, type, finished;
	local questTitle
	local watchTextIndex = 1;
	local questIndex;
	local objectivesCompleted;

	for i=1, GetNumQuestWatches() do
		questIndex = GetQuestIndexForWatch(i);
		if ( questIndex ) then
			numObjectives = GetNumQuestLeaderBoards(questIndex);
		
			--If there are objectives set the title
			if ( false ) then
				-- Set title
				watchText:SetText(GetQuestLogTitle(questIndex));
				tempWidth = watchText:GetWidth();
				-- Set the anchor of the title line a little lower
				if ( watchTextIndex > 1 ) then
					watchText:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -4);
				end
				watchText:Show();
				if ( tempWidth > questWatchMaxWidth ) then
					questWatchMaxWidth = tempWidth;
				end
				watchTextIndex = watchTextIndex + 1;
				objectivesCompleted = 0;
				for j=1, numObjectives do
					text, type, finished = GetQuestLogLeaderBoard(j, questIndex);
					if ( text == nil ) then
						text = "";
					end
					if ( finished == nil ) then
						finished = true;
					end
					watchText = _G["QuestWatchLine"..watchTextIndex];
					-- Set Objective text
					watchText:SetText(" - "..text);
					-- Color the objectives
					if ( finished ) then
						watchText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
						objectivesCompleted = objectivesCompleted + 1;
					else
						watchText:SetTextColor(0.8, 0.8, 0.8);
					end
					tempWidth = watchText:GetWidth();
					if ( tempWidth > questWatchMaxWidth ) then
						questWatchMaxWidth = tempWidth;
					end
					watchText:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, 0);
					watchText:Show();
					watchTextIndex = watchTextIndex + 1;
				end
				-- Brighten the quest title if all the quest objectives were met
				watchText = _G["QuestWatchLine"..watchTextIndex-numObjectives-1];
				if ( objectivesCompleted == numObjectives ) then
					watchText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				else
					watchText:SetTextColor(0.75, 0.61, 0);
				end
			end
		end
	end

	-- Set tracking indicator
	-- TODO will need to change
	-- if ( GetNumQuestWatches() > 0 ) then
	-- 	QuestLogTrackTracking:SetVertexColor(0, 1.0, 0);
	-- else
	-- 	QuestLogTrackTracking:SetVertexColor(1.0, 0, 0);
	-- end
	

	-- TODO also check what the reference does for this
	-- If no watch lines used then hide the frame and return
	-- if ( watchTextIndex == 1 ) then
	-- 	QuestWatchFrame:Hide();
	-- 	return;
	-- else
	-- 	QuestWatchFrame:Show();
	-- 	QuestWatchFrame:SetHeight(watchTextIndex * 13);
	-- 	QuestWatchFrame:SetWidth(questWatchMaxWidth + 10);
	-- end

	-- -- Hide unused watch lines
	-- for i=watchTextIndex, MAX_QUESTWATCH_LINES do
	-- 	_G["QuestWatchLine"..i]:Hide();
	-- end

	UIParent_ManageFramePositions();
end

function GetQuestLogIndexByName(name)
	local numEntries = GetNumQuestLogEntries();
	local questLogTitleText;
	for i=1, numEntries, 1 do
		questLogTitleText = GetQuestLogTitle(i);
		if ( "  "..questLogTitleText == name ) then
			return i;
		end
	end
	return nil;
end

function AutoQuestWatch_Insert(questIndex, watchTimer)
	local watch = {};
	watch.id = GetQuestIDFromLogIndex(questIndex);
	watch.timer = watchTimer;

	if ( getn(QUEST_WATCH_LIST) < MAX_WATCHABLE_QUESTS ) then
		tinsert(QUEST_WATCH_LIST, watch);
		AddQuestWatch(questIndex);
	else
		local lowestTimer = MAX_QUEST_WATCH_TIMER;
		local lowestIndex;
		for index, value in ipairs(QUEST_WATCH_LIST) do
			if ( ( value.timer <= lowestTimer ) and ( value.timer ~= QUEST_WATCH_NO_EXPIRE ) ) then
				lowestTimer = value.timer;
				lowestIndex = index;
				lowestID = value.id;
			end
		end

		if ( lowestIndex ) then
			tremove(QUEST_WATCH_LIST, lowestIndex);
			RemoveQuestWatch(GetQuestLogIndexByID(lowestID));
			tinsert(QUEST_WATCH_LIST, watch);
			AddQuestWatch(questIndex);
		end
	end
end

function AutoQuestWatch_CheckDeleted()
	for index, value in ipairs(QUEST_WATCH_LIST) do
		local questLogIndex = GetQuestLogIndexByID(value.id);
		if ( not questLogIndex or questLogIndex <= 0 ) then -- Not found.
			tremove(QUEST_WATCH_LIST, index);
		end
	end
end

function AutoQuestWatch_Update(questIndex)
	local questID = GetQuestIDFromLogIndex(questIndex);
	-- Check the array for an existing matching entry.  Remove if matched, then add the quest to the watch list.
	for index, value in ipairs(QUEST_WATCH_LIST) do
		if ( value.id == questID and value.timer == QUEST_WATCH_NO_EXPIRE ) then
			return;
		elseif ( not value.id and QuestIsWatched(questIndex) ) then
			value.id = questID;
			value.timer = QUEST_WATCH_NO_EXPIRE;
			tinsert(QUEST_WATCH_LIST, value)
		elseif ( value.id == questID and ( value.timer ~= QUEST_WATCH_NO_EXPIRE ) ) then
			tremove(QUEST_WATCH_LIST, index);
			value.id = questID;
			value.timer = MAX_QUEST_WATCH_TIMER;
			tinsert(QUEST_WATCH_LIST, value);
			return;
		end
	end
	AutoQuestWatch_Insert(questIndex, MAX_QUEST_WATCH_TIMER);
end



function AutoQuestWatch_OnUpdate(self, elapsed)
	for index, value in ipairs(QUEST_WATCH_LIST) do
		if ( value.timer ~= QUEST_WATCH_NO_EXPIRE ) then
			value.timer = value.timer - elapsed;	
			if ( value.timer < 0 ) then
				RemoveQuestWatch(GetQuestLogIndexByID(value.id));
				tremove(QUEST_WATCH_LIST, index);
				QuestWatch_Update();
				QuestLog_Update();
			end
		end
	end
end

function GetQuestIDFromLogIndex(questIndex)
	local questID = select(8, GetQuestLogTitle(questIndex));
	return questID;
end

function QuestLogUpdateQuestCount(numQuests)
	QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, numQuests, MAX_QUESTLOG_QUESTS);
	local width = QuestLogQuestCount:GetWidth();
	local textHeight = 12;
	local hPadding = 15;
	local vPadding = 8;
	local dailyQuestsComplete = GetDailyQuestsCompleted();
	
	if ( dailyQuestsComplete > 0 ) then
		QuestLogDailyQuestCount:SetFormattedText(QUEST_LOG_DAILY_COUNT_TEMPLATE, dailyQuestsComplete, GetMaxDailyQuests());
		QuestLogDailyQuestCount:Show();
		--DailyQuestCountButton:Show();
		-- Use this width
		if ( QuestLogDailyQuestCount:GetWidth() > width ) then
			width = QuestLogDailyQuestCount:GetWidth();
		end
		QuestLogCount:SetHeight(textHeight*2+vPadding);
		QuestLogCount:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", 80, -38);
	else
		QuestLogDailyQuestCount:Hide();
		--DailyQuestCountButton:Hide();
		width = QuestLogQuestCount:GetWidth();
		QuestLogCount:SetHeight(textHeight+vPadding);
		QuestLogCount:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", 80, -41);
	end
	QuestLogCount:SetWidth(width+hPadding);
end
-- Wrath new stuff here


--
-- QuestLogDetailFrame
--

function QuestLogDetailFrame_OnShow(self)
	QuestLogControlPanel_UpdatePosition();
	--QuestLogShowMapPOI_UpdatePosition();
	QuestLog_UpdateQuestDetails();
end

function QuestLogDetailFrame_OnHide(self)
	-- this function effectively deselects the selected quest
	QuestLogControlPanel_UpdatePosition();
	--QuestLogShowMapPOI_UpdatePosition();
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
		QuestFramePushQuestButton:Disable();
	else
		if ( GetAbandonQuestName() ) then
			QuestLogFrameAbandonButton:Enable();
		else
			QuestLogFrameAbandonButton:Disable();
		end

		QuestLogFrameTrackButton:Enable();

		if ( GetQuestLogPushable() and IsInGroup()) then
			QuestFramePushQuestButton:Enable();
		else
			QuestFramePushQuestButton:Disable();
		end
	end
end

--
-- QuestLogListScrollFrame
--
function QuestLogListScrollFrame_OnLoad(self)
	HybridScrollFrame_OnLoad(self);
	self.update = QuestLog_Update;
	HybridScrollFrame_CreateButtons(self, "QuestLogTitleButtonTemplate");
end

--
-- QuestLogFrameTrackButton
--
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

function QuestLogFrameTrackButton_OnClick(self)
	_QuestLog_ToggleQuestWatch(GetQuestLogSelection());
	QuestLog_Update();
end
