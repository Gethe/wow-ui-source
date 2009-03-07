QUESTS_DISPLAYED = 6;
MAX_QUESTS = 25;
MAX_OBJECTIVES = 10;
QUESTLOG_QUEST_HEIGHT = 16;
UPDATE_DELAY = 0.1;
MAX_QUESTLOG_QUESTS = 25;
MAX_QUESTWATCH_LINES = 30;
MAX_ACHIEVEMENTWATCH_LINES = 10;
MAX_WATCHABLE_QUESTS = 10;
MAX_NUM_PARTY_MEMBERS = 4;
MAX_QUEST_WATCH_TIME = 300;
NUM_QUESTLOG_SPECIAL_ITEMS = 0;
QUEST_WATCH_NO_EXPIRE = -1;
ACHIEVEMENTWATCH_TIMEDWIDTH = 160;
ACHIEVEMENTWATCH_MAXWIDTH = 210;

NUM_ACHIEVEMENTWATCH_LINES_USED = 0;

QuestDifficultyColor = { };
QuestDifficultyColor["impossible"] = { r = 1.00, g = 0.10, b = 0.10, font = QuestDifficulty_Impossible };
QuestDifficultyColor["verydifficult"] = { r = 1.00, g = 0.50, b = 0.25, font = QuestDifficulty_Verydifficult };
QuestDifficultyColor["difficult"] = { r = 1.00, g = 1.00, b = 0.00, font = QuestDifficulty_Difficult };
QuestDifficultyColor["standard"] = { r = 0.25, g = 0.75, b = 0.25, font = QuestDifficulty_Standard };
QuestDifficultyColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50, font = QuestDifficulty_Trivial };
QuestDifficultyColor["header"]	= { r = 0.7, g = 0.7, b = 0.7, font = QuestDifficulty_Header };

function QuestLogTitleButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
end

function QuestLogTitleButton_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide();
		QuestLog_UpdatePartyInfoTooltip(self);
	end
end

function QuestLog_OnLoad(self)
	self.selectedButtonID = 2;
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("QUEST_WATCH_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
end

function QuestLog_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") ) then
		QuestLog_Update();
		WatchFrame_Update();
		if ( QuestLogFrame:IsVisible() ) then
			QuestLog_UpdateQuestDetails(1);
		end
	elseif ( event == "QUEST_ACCEPTED" ) then
		if ( AUTO_QUEST_WATCH == "1" and 
			 GetNumQuestLeaderBoards(arg1) > 0 and 
			 GetNumQuestWatches() < MAX_WATCHABLE_QUESTS and 
			 WatchFrame_GetRemainingSpace() >= WatchFrame_GetHeightNeededForQuest(arg1) ) then
			AddQuestWatch(arg1);
			QuestLog_Update();
			WatchFrame_Update();
		end
	elseif ( event == "QUEST_WATCH_UPDATE" ) then
		if ( AUTO_QUEST_PROGRESS == "1" and 
			 GetNumQuestLeaderBoards(arg1) > 0 and 
			 GetNumQuestWatches() < MAX_WATCHABLE_QUESTS and 
			 WatchFrame_GetRemainingSpace() >= WatchFrame_GetHeightNeededForQuest(arg1) ) then
			AddQuestWatch(arg1,MAX_QUEST_WATCH_TIME);
			QuestLog_Update();
			WatchFrame_Update();
		end
	else
		QuestLog_Update();
		if ( event == "PARTY_MEMBERS_CHANGED" ) then
			-- Determine whether the selected quest is pushable or not
			if ( GetQuestLogPushable() and ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1 ) ) then
				QuestFramePushQuestButton:Enable();
			else
				QuestFramePushQuestButton:Disable();
			end
		end
	end

end

function QuestLog_OnShow()
	UpdateMicroButtons();
	PlaySound("igQuestLogOpen");
	QuestLog_SetSelection(GetQuestLogSelection());
	QuestLog_Update();
end

function QuestLog_OnHide()
	UpdateMicroButtons();
	PlaySound("igQuestLogClose");
end

function QuestLog_OnUpdate(self, elapsed)
	if ( self.hasTimer ) then
		self.timePassed = self.timePassed + elapsed;
		if ( self.timePassed > UPDATE_DELAY ) then
			QuestLogTimerText:SetText(TIME_REMAINING.." "..SecondsToTime(GetQuestLogTimeLeft()));
			self.timePassed = 0;		
		end
	end
end

function QuestLog_Update()
	local numEntries, numQuests = GetNumQuestLogEntries();
	if ( numEntries == 0 ) then
		EmptyQuestLogFrame:Show();
		QuestLogFrameAbandonButton:Disable();
		QuestLogFrame.hasTimer = nil;
		QuestLogDetailScrollFrame:Hide();
		QuestLogExpandButtonFrame:Hide();
	else
		EmptyQuestLogFrame:Hide();
		QuestLogFrameAbandonButton:Enable();
		QuestLogDetailScrollFrame:Show();
		QuestLogExpandButtonFrame:Show();
	end

	-- Update Quest Count
	QuestLogUpdateQuestCount(numQuests);

	-- ScrollFrame update
	FauxScrollFrame_Update(QuestLogListScrollFrame, numEntries, QUESTS_DISPLAYED, QUESTLOG_QUEST_HEIGHT, nil, nil, nil, QuestLogHighlightFrame, 293, 316 )
	
	-- Update the quest listing
	QuestLogHighlightFrame:Hide();

	-- If no selection then set it to the first available quest
	if ( GetQuestLogSelection() == 0 ) then
		QuestLog_SetFirstValidSelection();
	end

	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questNormalText, questHighlight, questCheck;
	local questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, color;
	local numPartyMembers, partyMembersOnQuest, tempWidth, textWidth;
	for i=1, QUESTS_DISPLAYED, 1 do
		questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		questLogTitle = getglobal("QuestLogTitle"..i);
		questTitleTag = getglobal("QuestLogTitle"..i.."Tag");
		questNumGroupMates = getglobal("QuestLogTitle"..i.."GroupMates");
		questCheck = getglobal("QuestLogTitle"..i.."Check");
		questNormalText = getglobal("QuestLogTitle"..i.."NormalText");
		questHighlight = getglobal("QuestLogTitle"..i.."Highlight");
		if ( questIndex <= numEntries ) then
			questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(questIndex);
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
				questHighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
				questNumGroupMates:SetText("");
				questCheck:Hide();
			else
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					questLogTitleText = "["..level.."] " .. questLogTitleText;
				end
				questLogTitle:SetText("  "..questLogTitleText);
				--Set Dummy text to get text width *SUPER HACK*
				QuestLogDummyText:SetText("  "..questLogTitleText);

				questLogTitle:SetNormalTexture("");
				questHighlight:SetTexture("");

				-- If not a header see if any nearby group mates are on this quest
				numPartyMembers = GetNumPartyMembers();
				if ( numPartyMembers == 0 ) then
					--return;
				end
				partyMembersOnQuest = 0;
				for j=1, numPartyMembers do
					if ( IsUnitOnQuest(questIndex, "party"..j) ) then
						partyMembersOnQuest = partyMembersOnQuest + 1;
					end
				end
				if ( partyMembersOnQuest > 0 ) then
					questNumGroupMates:SetText("["..partyMembersOnQuest.."]");
				else
					questNumGroupMates:SetText("");
				end
			end
			-- Save if its a header or not
			questLogTitle.isHeader = isHeader;

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
				questTitleTag:SetText("");
				questNormalText:SetWidth(275);

				-- Show check if quest is being watched
				questCheck:Hide();
				if ( IsQuestWatched(questIndex) ) then
					if ( questNormalText:GetWidth() + 24 < 275 ) then
						questCheck:SetPoint("LEFT", questNormalText, "LEFT", questNormalText:GetWidth()+24, 0);
					else
						questCheck:SetPoint("LEFT", questNormalText, "LEFT", questNormalText:GetWidth()-10, 0);
					end
					questCheck:Show();
				end
			end

			-- Color the quest title and highlight according to the difficulty level
			local playerLevel = UnitLevel("player");
			if ( isHeader ) then
				color = QuestDifficultyColor["header"];
			else
				color = GetDifficultyColor(level);
			end
			questTitleTag:SetTextColor(color.r, color.g, color.b);
			questLogTitle:SetNormalFontObject(color.font);
			questNumGroupMates:SetTextColor(color.r, color.g, color.b);
			questLogTitle.r = color.r;
			questLogTitle.g = color.g;
			questLogTitle.b = color.b;
			questLogTitle:Show();

			-- Place the highlight and lock the highlight state
			if ( QuestLogFrame.selectedButtonID and GetQuestLogSelection() == questIndex ) then
				QuestLogHighlightFrame:SetPoint("TOPLEFT", "QuestLogTitle"..i, "TOPLEFT", 0, 0);
				QuestLogSkillHighlight:SetVertexColor(questLogTitle.r, questLogTitle.g, questLogTitle.b);
				QuestLogHighlightFrame:Show();
				questTitleTag:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				questLogTitle:LockHighlight();
			else
				questLogTitle:UnlockHighlight();
			end

		else
			questLogTitle:Hide();
		end
	end

	-- Set the expand/collapse all button texture
	local numHeaders = 0;
	local notExpanded = 0;
	-- Somewhat redundant loop, but cleaner than the alternatives
	for i=1, numEntries, 1 do
		local index = i;
		local questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(i);
		if ( questLogTitleText and isHeader ) then
			numHeaders = numHeaders + 1;
			if ( isCollapsed ) then
				notExpanded = notExpanded + 1;
			end
		end
	end
	-- If all headers are not expanded then show collapse button, otherwise show the expand button
	if ( notExpanded ~= numHeaders ) then
		QuestLogCollapseAllButton.collapsed = nil;
		QuestLogCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	else
		QuestLogCollapseAllButton.collapsed = 1;
		QuestLogCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	end

	-- Determine whether the selected quest is pushable or not
	if ( numEntries == 0 ) then
		QuestFramePushQuestButton:Disable();
	elseif ( GetQuestLogPushable() and ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1 ) ) then
		QuestFramePushQuestButton:Enable();
	else
		QuestFramePushQuestButton:Disable();
	end
end

function QuestLog_SetSelection(questID)
	local selectedQuest;
	if ( questID == 0 ) then
		QuestLogDetailScrollFrame:Hide();
		return;
	end

	-- Get xml id
	local id = questID - FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
	
	SelectQuestLogEntry(questID);
	local titleButton = getglobal("QuestLogTitle"..id);
	local titleButtonTag = getglobal("QuestLogTitle"..id.."Tag");
	local questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(questID);
	if ( isHeader ) then
		if ( isCollapsed ) then
			ExpandQuestHeader(questID);
			return;
		else
			CollapseQuestHeader(questID);
			return;
		end
	else
		-- Set newly selected quest and highlight it
		QuestLogFrame.selectedButtonID = questID;
		local scrollFrameOffset = FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		if ( questID > scrollFrameOffset and questID <= (scrollFrameOffset + QUESTS_DISPLAYED) and questID <= GetNumQuestLogEntries() ) then
			titleButton:LockHighlight();
			titleButtonTag:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			--QuestLogSkillHighlight:SetVertexColor(titleButton.r, titleButton.g, titleButton.b);
			QuestLogHighlightFrame:SetPoint("TOPLEFT", "QuestLogTitle"..id, "TOPLEFT", 5, 0);
			QuestLogHighlightFrame:Show();
		end
	end
	QuestLog_UpdateQuestDetails();
end

function QuestLog_UpdateQuestDetails(doNotScroll)
	local questID = GetQuestLogSelection();
	local questTitle = GetQuestLogTitle(questID);
	if ( not questTitle ) then
		questTitle = "";
	end
	if ( IsCurrentQuestFailed() ) then
		questTitle = questTitle.." - ("..FAILED..")";
	end
	QuestLogQuestTitle:SetText(questTitle);

	local questDescription;
	local questObjectives;
	questDescription, questObjectives = GetQuestLogQuestText();
	QuestLogObjectivesText:SetText(questObjectives);
	
	local questTimer = GetQuestLogTimeLeft();
	if ( questTimer ) then
		QuestLogFrame.hasTimer = 1;
		QuestLogFrame.timePassed = 0;
		QuestLogTimerText:Show();
		QuestLogTimerText:SetText(TIME_REMAINING.." "..SecondsToTime(questTimer));
		QuestLogObjective1:SetPoint("TOPLEFT", "QuestLogTimerText", "BOTTOMLEFT", 0, -10);
	else
		QuestLogFrame.hasTimer = nil;
		QuestLogTimerText:Hide();
		QuestLogObjective1:SetPoint("TOPLEFT", "QuestLogObjectivesText", "BOTTOMLEFT", 0, -10);
	end
	
	-- Show Quest Watch if track quest is checked
	local numObjectives = GetNumQuestLeaderBoards();
	
	for i=1, numObjectives, 1 do
		local string = getglobal("QuestLogObjective"..i);
		local text;
		local type;
		local finished;
		text, type, finished = GetQuestLogLeaderBoard(i);
		if ( not text or strlen(text) == 0 ) then
			text = type;
		end
		if ( finished ) then
			string:SetTextColor(0.2, 0.2, 0.2);
			text = text.." ("..COMPLETE..")";
		else
			string:SetTextColor(0, 0, 0);
		end
		string:SetText(text);
		string:Show();
		QuestFrame_SetAsLastShown(string);
	end

	for i=numObjectives + 1, MAX_OBJECTIVES, 1 do
		getglobal("QuestLogObjective"..i):Hide();
	end
	-- If there's money required then anchor and display it
	if ( GetQuestLogRequiredMoney() > 0 ) then
		if ( numObjectives > 0 ) then
			QuestLogRequiredMoneyText:SetPoint("TOPLEFT", "QuestLogObjective"..numObjectives, "BOTTOMLEFT", 0, -4);
		else
			QuestLogRequiredMoneyText:SetPoint("TOPLEFT", "QuestLogObjectivesText", "BOTTOMLEFT", 0, -10);
		end
		
		MoneyFrame_Update("QuestLogRequiredMoneyFrame", GetQuestLogRequiredMoney());
		
		if ( GetQuestLogRequiredMoney() > GetMoney() ) then
			-- Not enough money
			QuestLogRequiredMoneyText:SetTextColor(0, 0, 0);
			SetMoneyFrameColor("QuestLogRequiredMoneyFrame", "red");
		else
			QuestLogRequiredMoneyText:SetTextColor(0.2, 0.2, 0.2);
			SetMoneyFrameColor("QuestLogRequiredMoneyFrame", "white");
		end
		QuestLogRequiredMoneyText:Show();
		QuestLogRequiredMoneyFrame:Show();
	else
		QuestLogRequiredMoneyText:Hide();
		QuestLogRequiredMoneyFrame:Hide();
	end

	if ( GetQuestLogGroupNum() > 0 ) then
		local suggestedGroupString = format(QUEST_SUGGESTED_GROUP_NUM, GetQuestLogGroupNum());
		QuestLogSuggestedGroupNum:SetText(suggestedGroupString);
		QuestLogSuggestedGroupNum:Show();
		QuestLogSuggestedGroupNum:ClearAllPoints();
		if ( GetQuestLogRequiredMoney() > 0 ) then
			QuestLogSuggestedGroupNum:SetPoint("TOPLEFT", "QuestLogRequiredMoneyText", "BOTTOMLEFT", 0, -4);
		elseif ( numObjectives > 0 ) then
			QuestLogSuggestedGroupNum:SetPoint("TOPLEFT", "QuestLogObjective"..numObjectives, "BOTTOMLEFT", 0, -4);
		elseif ( questTimer ) then
			QuestLogSuggestedGroupNum:SetPoint("TOPLEFT", "QuestLogTimerText", "BOTTOMLEFT", 0, -10);
		else
			QuestLogSuggestedGroupNum:SetPoint("TOPLEFT", "QuestLogObjectivesText", "BOTTOMLEFT", 0, -10);
		end
	else
		QuestLogSuggestedGroupNum:Hide();
	end

	if ( GetQuestLogGroupNum() > 0 ) then
		QuestLogDescriptionTitle:SetPoint("TOPLEFT", "QuestLogSuggestedGroupNum", "BOTTOMLEFT", 0, -10);
	elseif ( GetQuestLogRequiredMoney() > 0 ) then
		QuestLogDescriptionTitle:SetPoint("TOPLEFT", "QuestLogRequiredMoneyText", "BOTTOMLEFT", 0, -10);
	elseif ( numObjectives > 0 ) then
		QuestLogDescriptionTitle:SetPoint("TOPLEFT", "QuestLogObjective"..numObjectives, "BOTTOMLEFT", 0, -10);
	else
		if ( questTimer ) then
			QuestLogDescriptionTitle:SetPoint("TOPLEFT", "QuestLogTimerText", "BOTTOMLEFT", 0, -10);
		else
			QuestLogDescriptionTitle:SetPoint("TOPLEFT", "QuestLogObjectivesText", "BOTTOMLEFT", 0, -10);
		end
	end
	if ( questDescription ) then
		QuestLogQuestDescription:SetText(questDescription);
		QuestFrame_SetAsLastShown(QuestLogQuestDescription);
	end
	local numRewards = GetNumQuestLogRewards();
	local numChoices = GetNumQuestLogChoices();
	local money = GetQuestLogRewardMoney();
	local honor = GetQuestLogRewardHonor();
	local talents = GetQuestLogRewardTalents();
	local playerTitle = GetQuestLogRewardTitle();

	if ( playerTitle or (numRewards + numChoices + money + honor + talents) > 0 ) then
		QuestLogRewardTitleText:Show();
		QuestFrame_SetAsLastShown(QuestLogRewardTitleText);
	else
		QuestLogRewardTitleText:Hide();
	end

	QuestFrameItems_Update("QuestLog");
	if ( not doNotScroll ) then
		QuestLogDetailScrollFrameScrollBar:SetValue(0);
	end
end

--Used to attach an empty spacer frame to the last shown object
function QuestFrame_SetAsLastShown(frame, spacerFrame)
	if ( not spacerFrame ) then
		spacerFrame = QuestLogSpacerFrame;
	end
	spacerFrame:SetPoint("TOP", frame, "BOTTOM", 0, 0);
end

function QuestLogTitleButton_OnClick(self, button)
	local questName = self:GetText();
	local questIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
	if ( IsModifiedClick() ) then
		-- If header then return
		if ( self.isHeader ) then
			return;
		end
		-- Otherwise try to track it or put it into chat
		if ( IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() ) then
			local questLink = GetQuestLink(questIndex);
			if ( questLink ) then
				ChatEdit_InsertLink(questLink);
			end
		elseif ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
			if ( IsQuestWatched(questIndex) ) then
				RemoveQuestWatch(questIndex);
				WatchFrame_Update();
			else
				-- Set error if no objectives
				if ( GetNumQuestLeaderBoards(questIndex) == 0 ) then
					UIErrorsFrame:AddMessage(QUEST_WATCH_NO_OBJECTIVES, 1.0, 0.1, 0.1, 1.0);
					return;
				end
				-- Set an error message if trying to show too many quests
				
				if ( (not WatchFrame:IsUserPlaced()) and ArenaEnemyFrames and ArenaEnemyFrames:IsShown() ) then
					UIErrorsFrame:AddMessage(OBJECTIVES_WATCH_QUESTS_ARENA, 1.0, 0.1, 0.1, 1.0);
					return;
				elseif ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then -- Check this first though it's less likely, otherwise they could make the frame bigger and be disappointed
					UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0);
					return;
				elseif ( WatchFrame_GetRemainingSpace() < WatchFrame_GetHeightNeededForQuest(questIndex) ) then
					UIErrorsFrame:AddMessage(OBJECTIVES_WATCH_TOO_MANY, 1.0, 0.1, 0.1, 1.0);
					return					
				end
				AddQuestWatch(questIndex);
				QuestLog_Update();
				WatchFrame_Update();
			end
		end
	end
	QuestLog_SetSelection(questIndex)
	QuestLog_Update();
end

function QuestLogTitleButton_OnEnter(self)
	-- Set highlight
	getglobal(self:GetName().."Tag"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	-- Set group info tooltip
	QuestLog_UpdatePartyInfoTooltip(self);
end

function QuestLog_UpdatePartyInfoTooltip(self)
	local index = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
	local numPartyMembers = GetNumPartyMembers();
	if ( numPartyMembers == 0 or self.isHeader ) then
		return;
	end
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

function QuestLogCollapseAllButton_OnClick(self)
	if (self.collapsed) then
		self.collapsed = nil;
		ExpandQuestHeader(0);
	else
		self.collapsed = 1;
		QuestLogListScrollFrameScrollBar:SetValue(0);
		CollapseQuestHeader(0);
	end
end

function QuestLog_GetFirstSelectableQuest()
	local numEntries = GetNumQuestLogEntries();
	local index = 0;
	local questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed;
	for i=1, numEntries, 1 do
		index = i;
		questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed = GetQuestLogTitle(i);
		if ( questLogTitleText and not isHeader ) then
			return index;
		end
	end
	return index;
end

function QuestLog_SetFirstValidSelection()
	local selectableQuest = QuestLog_GetFirstSelectableQuest();
	QuestLog_SetSelection(selectableQuest);
	QuestLogListScrollFrameScrollBar:SetValue(0);
end

function QuestLog_OpenToQuestIndex (index)
	ExpandQuestHeader(0);
	
	local numEntries, numQuests = GetNumQuestLogEntries();
	
	ShowUIPanel(QuestLogFrame);
	
	if ( numEntries <= QUESTS_DISPLAYED ) then
		_G["QuestLogTitle" .. index]:Click();
	elseif ( numEntries > QUESTS_DISPLAYED ) then
		if ( index <= QUESTS_DISPLAYED ) then
			-- The quest we want is on the first page, open and select it
			FauxScrollFrame_OnVerticalScroll(QuestLogListScrollFrame, 0, QUESTLOG_QUEST_HEIGHT, QuestLog_Update);
			_G["QuestLogTitle" .. index]:Click();
		elseif ( index > (numEntries - QUESTS_DISPLAYED)  ) then
			-- The quest we want is on the last page, scroll to the bottom;
			local buttonNum = index - (numEntries - QUESTS_DISPLAYED);
			local offset = numEntries - QUESTS_DISPLAYED;
			FauxScrollFrame_OnVerticalScroll(QuestLogListScrollFrame, offset * QUESTLOG_QUEST_HEIGHT, QUESTLOG_QUEST_HEIGHT, QuestLog_Update);
			_G["QuestLogTitle" .. buttonNum]:Click();
		else
			-- Scroll to the quest we want
			FauxScrollFrame_OnVerticalScroll(QuestLogListScrollFrame, (index - 1) * QUESTLOG_QUEST_HEIGHT, QUESTLOG_QUEST_HEIGHT, QuestLog_Update)
			QuestLogTitle1:Click();	
		end
	end
end

-- Used for quests and enemy coloration
function GetDifficultyColor(level)
	local levelDiff = level - UnitLevel("player");
	local color
	if ( levelDiff >= 5 ) then
		color = QuestDifficultyColor["impossible"];
	elseif ( levelDiff >= 3 ) then
		color = QuestDifficultyColor["verydifficult"];
	elseif ( levelDiff >= -2 ) then
		color = QuestDifficultyColor["difficult"];
	elseif ( -levelDiff <= GetQuestGreenRange() ) then
		color = QuestDifficultyColor["standard"];
	else
		color = QuestDifficultyColor["trivial"];
	end
	return color;
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
		DailyQuestCountButton:Show();
		-- Use this width
		if ( QuestLogDailyQuestCount:GetWidth() > width ) then
			width = QuestLogDailyQuestCount:GetWidth();
		end
		QuestLogCount:SetHeight(textHeight*2+vPadding);
		QuestLogCount:SetPoint("TOPRIGHT", QuestLogFrame, "TOPRIGHT", -44, -38);
	else
		QuestLogDailyQuestCount:Hide();
		DailyQuestCountButton:Hide();
		width = QuestLogQuestCount:GetWidth();
		QuestLogCount:SetHeight(textHeight+vPadding);
		QuestLogCount:SetPoint("TOPRIGHT", QuestLogFrame, "TOPRIGHT", -44, -41);
	end
	QuestLogCount:SetWidth(width+hPadding);
end
