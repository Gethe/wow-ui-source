QUESTS_DISPLAYED = 6;
MAX_QUESTS = 20;
MAX_OBJECTIVES = 10;
QUESTLOG_QUEST_HEIGHT = 16;
UPDATE_DELAY = 0.1;
MAX_QUESTLOG_QUESTS = 20;

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
end

function QuestLog_OnLoad()
	this.selectedButtonID = 2;
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("UPDATE_FACTION");
end

function QuestLog_OnEvent(event)
	if ( event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" ) then
		QuestLog_Update();
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
	for i=1, QUESTS_DISPLAYED, 1 do
		local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		local questLogTitle = getglobal("QuestLogTitle"..i);
		local questTitleTag = getglobal("QuestLogTitle"..i.."Tag");
		local questNormalText = getglobal("QuestLogTitle"..i.."NormalText");
		local questHighlightText = getglobal("QuestLogTitle"..i.."HighlightText");
		local questDisabledText = getglobal("QuestLogTitle"..i.."DisabledText");
		if ( questIndex <= numEntries ) then
			local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questIndex);
			local color;
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
				getglobal("QuestLogTitle"..i.."Highlight"):SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
			else
				questLogTitle:SetText("  "..questLogTitleText);
				questLogTitle:SetNormalTexture("");
				getglobal("QuestLogTitle"..i.."Highlight"):SetTexture("");
			end
			-- Set the quest tag
			if ( isComplete ) then
				questTag = COMPLETE;
			end
			if ( questTag ) then
				questTitleTag:SetText("("..questTag..")");
				-- Shrink text to accomdate quest tags without wrapping
				questNormalText:SetWidth(275 - 5 - questTitleTag:GetWidth());
				questHighlightText:SetWidth(275 - 5 - questTitleTag:GetWidth());
				questDisabledText:SetWidth(275 - 5 - questTitleTag:GetWidth());
			else
				questTitleTag:SetText("");
				-- Reset to max text width
				questNormalText:SetWidth(275);
				questHighlightText:SetWidth(275);
				questDisabledText:SetWidth(275);
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
	if ( GetQuestLogPushable() and GetNumPartyMembers() > 0 ) then
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
		if ( IsShiftKeyDown() and ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(this:GetText());
		end
		QuestLog_SetSelection(this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame))
		QuestLog_Update();
	end
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
