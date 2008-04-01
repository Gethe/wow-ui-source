QUESTS_DISPLAYED = 6;
MAX_QUESTS = 20;
MAX_OBJECTIVES = 10;
QUESTLOG_QUEST_HEIGHT = 16;
UPDATE_DELAY = 0.1;
MAX_QUESTLOG_QUESTS = 20;
MAX_QUESTWATCH_LINES = 30;
MAX_WATCHABLE_QUESTS = 5;
MAX_NUM_PARTY_MEMBERS = 4;

QuestDifficultyColor = { };
QuestDifficultyColor["impossible"] = { r = 1.00, g = 0.10, b = 0.10 };
QuestDifficultyColor["verydifficult"] = { r = 1.00, g = 0.50, b = 0.25 };
QuestDifficultyColor["difficult"] = { r = 1.00, g = 1.00, b = 0.00 };
QuestDifficultyColor["standard"] = { r = 0.25, g = 0.75, b = 0.25 };
QuestDifficultyColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50 };
QuestDifficultyColor["header"]	= { r = 0.7, g = 0.7, b = 0.7 };

function ToggleQuestLog()
	if ( QuestLogFrame:IsVisible() ) then
		HideUIPanel(QuestLogFrame);
	else
		ShowUIPanel(QuestLogFrame);
	end
end

function QuestLogTitleButton_OnLoad()
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	this:RegisterEvent("PARTY_MEMBER_ENABLE");
	this:RegisterEvent("PARTY_MEMBER_DISABLE");
end

function QuestLogTitleButton_OnEvent(event)
	if ( (event == "UNIT_QUEST_LOG_CHANGED" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) and GameTooltip:IsOwned(this) ) then
		GameTooltip:Hide();
		QuestLog_UpdatePartyInfoTooltip();
	end
end

function QuestLog_OnLoad()
	this.selectedButtonID = 2;
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("UPDATE_FACTION");
	this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
end

function QuestLog_OnEvent(event)
	if ( event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" or event == "UNIT_QUEST_LOG_CHANGED" ) then
		QuestLog_Update();
		QuestWatch_Update();
		if ( QuestLogFrame:IsVisible() ) then
			QuestLog_UpdateQuestDetails();
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		-- Determine whether the selected quest is pushable or not
		if ( GetQuestLogPushable() and GetNumPartyMembers() > 0 ) then
			QuestFramePushQuestButton:Enable();
		else
			QuestFramePushQuestButton:Disable();
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

function QuestLog_OnUpdate(elapsed)
	if ( QuestLogFrame.hasTimer ) then
		QuestLogFrame.timePassed = QuestLogFrame.timePassed + elapsed;
		if ( QuestLogFrame.timePassed > UPDATE_DELAY ) then
			QuestLogTimerText:SetText(TEXT(TIME_REMAINING).." "..SecondsToTime(GetQuestLogTimeLeft()));
			QuestLogFrame.timePassed = 0;		
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
	QuestLogQuestCount:SetText(format(QUEST_LOG_COUNT_TEMPLATE, numQuests, MAX_QUESTLOG_QUESTS));
	QuestLogCountMiddle:SetWidth(QuestLogQuestCount:GetWidth());

	-- ScrollFrame update
	FauxScrollFrame_Update(QuestLogListScrollFrame, numEntries, QUESTS_DISPLAYED, QUESTLOG_QUEST_HEIGHT, QuestLogHighlightFrame, 293, 316 )
	
	-- Update the quest listing
	QuestLogHighlightFrame:Hide();
	
	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questNormalText, questHighlightText, questDisabledText, questHighlight, questCheck;
	local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, color;
	local numPartyMembers, isOnQuest, partyMembersOnQuest, tempWidth;
	for i=1, QUESTS_DISPLAYED, 1 do
		questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		questLogTitle = getglobal("QuestLogTitle"..i);
		questTitleTag = getglobal("QuestLogTitle"..i.."Tag");
		questNumGroupMates = getglobal("QuestLogTitle"..i.."GroupMates");
		questCheck = getglobal("QuestLogTitle"..i.."Check");
		questNormalText = getglobal("QuestLogTitle"..i.."NormalText");
		questHighlightText = getglobal("QuestLogTitle"..i.."HighlightText");
		questDisabledText = getglobal("QuestLogTitle"..i.."DisabledText");
		questHighlight = getglobal("QuestLogTitle"..i.."Highlight");
		if ( questIndex <= numEntries ) then
			questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questIndex);
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
					isOnQuest = IsUnitOnQuest(questIndex, "party"..j);
					if ( isOnQuest and isOnQuest == 1 ) then
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

			-- Set the quest tag
			if ( isComplete ) then
				questTag = COMPLETE;
			end
			if ( questTag ) then
				questTitleTag:SetText("("..questTag..")");
				-- Shrink text to accomdate quest tags without wrapping
				tempWidth = 275 - 5 - questTitleTag:GetWidth();
				questNormalText:SetWidth(tempWidth);
				questHighlightText:SetWidth(tempWidth);
				questDisabledText:SetWidth(tempWidth);
				
				-- If there's quest tag position check accordingly
				questCheck:Hide();
				if ( IsQuestWatched(questIndex) ) then
					questCheck:SetPoint("LEFT", questLogTitle:GetName(), "LEFT", tempWidth+24, 0);
					questCheck:Show();
				end
			else
				questTitleTag:SetText("");
				-- Reset to max text width
				questNormalText:SetWidth(275);
				questHighlightText:SetWidth(275);
				questDisabledText:SetWidth(275);

				-- Show check if quest is being watched
				questCheck:Hide();
				if ( IsQuestWatched(questIndex) ) then
					questCheck:SetPoint("LEFT", questLogTitle:GetName(), "LEFT", QuestLogDummyText:GetWidth()+24, 0);
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
			questLogTitle:SetTextColor(color.r, color.g, color.b);
			questNumGroupMates:SetTextColor(color.r, color.g, color.b);
			questLogTitle.r = color.r;
			questLogTitle.g = color.g;
			questLogTitle.b = color.b;
			questLogTitle:Show();

			-- Place the highlight and lock the highlight state
			if ( QuestLogFrame.selectedButtonID and GetQuestLogSelection() == questIndex ) then
				QuestLogHighlightFrame:SetPoint("TOPLEFT", "QuestLogTitle"..i, "TOPLEFT", 0, 0);
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
		local questLogTitleText, level, questTag, isHeader, isCollapsed = GetQuestLogTitle(i);
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

	-- Update Quest Count
	QuestLogQuestCount:SetText(format(QUEST_LOG_COUNT_TEMPLATE, numQuests, MAX_QUESTLOG_QUESTS));
	QuestLogCountMiddle:SetWidth(QuestLogQuestCount:GetWidth());

	-- If no selection then set it to the first available quest
	if ( GetQuestLogSelection() == 0 ) then
		QuestLog_SetFirstValidSelection();
	end

	-- Determine whether the selected quest is pushable or not
	if ( numEntries == 0 ) then
		QuestFramePushQuestButton:Disable();
	elseif ( GetQuestLogPushable() and GetNumPartyMembers() > 0 ) then
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
	local questLogTitleText, level, questTag, isHeader, isCollapsed = GetQuestLogTitle(questID);
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
			QuestLogSkillHighlight:SetVertexColor(titleButton.r, titleButton.g, titleButton.b);
			QuestLogHighlightFrame:SetPoint("TOPLEFT", "QuestLogTitle"..id, "TOPLEFT", 5, 0);
			QuestLogHighlightFrame:Show();
		end
	end
	if ( GetQuestLogSelection() > GetNumQuestLogEntries() ) then
		return;
	end
	QuestLog_UpdateQuestDetails();
end

function QuestLog_UpdateQuestDetails()
	local questID = GetQuestLogSelection();
	local questTitle = GetQuestLogTitle(questID);
	if ( not questTitle ) then
		questTitle = "";
	end
	if ( IsCurrentQuestFailed() ) then
		questTitle = questTitle.." - ("..TEXT(FAILED)..")";
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
		QuestLogTimerText:SetText(TEXT(TIME_REMAINING).." "..SecondsToTime(questTimer));
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
			text = text.." ("..TEXT(COMPLETE)..")";
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
			SetMoneyFrameColor("QuestLogRequiredMoneyFrame", 1.0, 0.1, 0.1);
		else
			QuestLogRequiredMoneyText:SetTextColor(0.2, 0.2, 0.2);
			SetMoneyFrameColor("QuestLogRequiredMoneyFrame", 1.0, 1.0, 1.0);
		end
		QuestLogRequiredMoneyText:Show();
		QuestLogRequiredMoneyFrame:Show();
	else
		QuestLogRequiredMoneyText:Hide();
		QuestLogRequiredMoneyFrame:Hide();
	end

	if ( GetQuestLogRequiredMoney() > 0 ) then
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

	if ( (numRewards + numChoices + money) > 0 ) then
		QuestLogRewardTitleText:Show();
		QuestFrame_SetAsLastShown(QuestLogRewardTitleText);
	else
		QuestLogRewardTitleText:Hide();
	end

	QuestFrameItems_Update("QuestLog");
	QuestLogDetailScrollFrameScrollBar:SetValue(0);
	QuestLogDetailScrollFrame:UpdateScrollChildRect();
end

--Used to attach an empty spacer frame to the last shown object
function QuestFrame_SetAsLastShown(frame, spacerFrame)
	if ( not spacerFrame ) then
		spacerFrame = QuestLogSpacerFrame;
	end
	spacerFrame:SetPoint("TOP", frame:GetName(), "BOTTOM", 0, 0);
end

function QuestLogTitleButton_OnClick(button)
	if ( button == "LeftButton" ) then
		local questName = this:GetText();
		local questIndex = this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		if ( IsShiftKeyDown() ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				-- Trim leading whitespace
				ChatFrameEditBox:Insert(gsub(this:GetText(), " *(.*)", "%1"));
			else
				-- Shift-click toggles quest-watch on this quest.
				if ( IsQuestWatched(questIndex) ) then
					RemoveQuestWatch(questIndex);
					QuestWatch_Update();
				else
					-- Set error if no objectives
					if ( GetNumQuestLeaderBoards(questIndex) == 0 ) then
						UIErrorsFrame:AddMessage(QUEST_WATCH_NO_OBJECTIVES, 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME);
						return;
					end
					-- Set an error message if trying to show too many quests
					if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then
						UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME);
						return;
					end
					AddQuestWatch(questIndex);
					QuestWatch_Update();
				end
			end
		end
		QuestLog_SetSelection(questIndex)
		QuestLog_Update();
	end
end

function QuestLogTitleButton_OnEnter()
	-- Set highlight
	getglobal(this:GetName().."Tag"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	-- Set group info tooltip
	QuestLog_UpdatePartyInfoTooltip();
end

function QuestLog_UpdatePartyInfoTooltip()
	local index = this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
	local numPartyMembers = GetNumPartyMembers();
	if ( numPartyMembers == 0 or this.isHeader ) then
		return;
	end
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	
	local questLogTitleText = GetQuestLogTitle(index);
	GameTooltip:SetText(questLogTitleText);

	local isOnQuest, unitName, partyMemberOnQuest;
	for i=1, numPartyMembers do
		isOnQuest = IsUnitOnQuest( index, "party"..i);
		unitName = UnitName("party"..i);
		if ( isOnQuest and isOnQuest == 1 ) then
			if ( not partyMemberOnQuest ) then
				GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..PARTY_QUEST_STATUS_ON..FONT_COLOR_CODE_CLOSE);
				partyMemberOnQuest = 1;
			end
			GameTooltip:AddLine(LIGHTYELLOW_FONT_COLOR_CODE..unitName..FONT_COLOR_CODE_CLOSE);
		end
	end
	if ( not partyMemberOnQuest ) then
		GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..PARTY_QUEST_STATUS_NONE..FONT_COLOR_CODE_CLOSE);
	end
	GameTooltip:Show();
end

function QuestLogRewardItem_OnClick()
	if ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(GetQuestLogItemLink(this.type, this:GetID()));
		end
	end
end

function QuestLogCollapseAllButton_OnClick()
	if (this.collapsed) then
		this.collapsed = nil;
		ExpandQuestHeader(0);
	else
		this.collapsed = 1;
		QuestLogListScrollFrameScrollBar:SetValue(0);
		CollapseQuestHeader(0);
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

-- Used for quests and enemy coloration
function GetDifficultyColor(level)
	local levelDiff = level - UnitLevel("player");
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

-- QuestWatch functions
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
			if ( numObjectives > 0 ) then
				-- Set title
				watchText = getglobal("QuestWatchLine"..watchTextIndex);
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
					watchText = getglobal("QuestWatchLine"..watchTextIndex);
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
				watchText = getglobal("QuestWatchLine"..watchTextIndex-numObjectives-1);
				if ( objectivesCompleted == numObjectives ) then
					watchText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				else
					watchText:SetTextColor(0.75, 0.61, 0);
				end
			end
		end
	end

	-- Set tracking indicator
	if ( GetNumQuestWatches() > 0 ) then
		QuestLogTrackTracking:SetVertexColor(0, 1.0, 0);
	else
		QuestLogTrackTracking:SetVertexColor(1.0, 0, 0);
	end
	
	-- If no watch lines used then hide the frame and return
	if ( watchTextIndex == 1 ) then
		QuestWatchFrame:Hide();
		return;
	else
		QuestWatchFrame:Show();
		QuestWatchFrame:SetHeight(watchTextIndex * 13);
		QuestWatchFrame:SetWidth(questWatchMaxWidth + 10);
	end

	-- Hide unused watch lines
	for i=watchTextIndex, MAX_QUESTWATCH_LINES do
		getglobal("QuestWatchLine"..i):Hide();
	end

	UIParent_ManageRightSideFrames();
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
