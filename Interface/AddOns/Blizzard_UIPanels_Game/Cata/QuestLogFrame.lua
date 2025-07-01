QUESTS_DISPLAYED = 27;
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
	if ( not QuestMapFrame:IsVisible() ) then
		if ( QuestLogFrame:IsVisible() ) then
			HideUIPanel(QuestLogFrame);
		else
			ShowUIPanel(QuestLogFrame);
		end
	end
end

function QuestLogTitleButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");

	-- anchor the check to the normal text now since we can't do it with the way it's currently setup in XML
	local name = self:GetName();
	self.check:SetPoint("LEFT", name.."NormalText", "RIGHT", 2, 0);
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
	self:RegisterEvent("QUEST_DETAIL");
	self:RegisterEvent("QUEST_WATCH_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("QUEST_ACCEPTED")
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
		QuestLog_Update();
                 QuestLogControlPanel_UpdateState();
	elseif ( event == "QUEST_LOG_UPDATE" or event == "UPDATE_FACTION" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") ) then
		QuestLog_Update();
		if ( QuestLogFrame:IsVisible() ) then
			QuestLog_UpdateQuestDetails(1);
		end
	elseif ( event == "QUEST_WATCH_UPDATE" ) then
		-- Arg1 is the QID
		if ( GetCVar("autoQuestWatch") == "1" ) then
			local questIndex = GetQuestLogIndexByID(arg1);
			if (not IsQuestWatched(questIndex)) then				
				_QuestLog_ToggleQuestWatch(questIndex);
			end
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
		QuestLog_Update();
		if ( event == "PARTY_MEMBERS_CHANGED" ) then
			QuestLogControlPanel_UpdateState();
		end
	elseif ( event == "QUEST_ACCEPTED" ) then
		if ( GetCVar("autoQuestWatch") == "1" ) then
			_QuestLog_ToggleQuestWatch(arg1);
		end
		QuestLog_Update();
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		QuestLog_Update();
	elseif ( event == "QUEST_DETAIL" ) then
		-- Opening a quest from a quest giver
		HideUIPanel(QuestLogDetailFrame);
		HideUIPanel(GossipFrame);
		QuestFrameDetailPanel:Hide();
		QuestFrameDetailPanel:Show();
	else
		QuestLog_Update();
		if ( event == "GROUP_ROSTER_UPDATE" ) then
			-- Determine whether the selected quest is pushable or not
			if ( GetQuestLogPushable() and GetNumGroupMembers() > 0 ) then
				QuestFramePushQuestButton:Enable();
			else
				QuestFramePushQuestButton:Disable();
			end
			QuestLogControlPanel_UpdateState();
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
	QuestLogShowMapPOI_UpdatePosition();
	QuestLog_SetSelection(GetQuestLogSelection());
	QuestLogDetailFrame_AttachToQuestLog();
	QuestLog_Update();
	
end

function QuestLog_OnHide(self)
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
	QuestLogShowMapPOI_UpdatePosition();
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

function QuestLog_UpdateMapButton()
	if ( WatchFrame.showObjectives and GetNumQuestLogEntries() ~= 0 and GetCVarBool("questPOI") and GetCVarBool("questHelper")) then
		QuestLogFrameShowMapButton:Show();
	else
		QuestLogFrameShowMapButton:Hide();
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

	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questHighlight, questCheck;
	local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, color;
	local frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling;
	local numPartyMembers, partyMembersOnQuest, tempWidth, textWidth;


	for i=1, QUESTS_DISPLAYED, 1 do
		questLogTitle = buttons[i];
		questIndex = i + scrollOffset;
		questLogTitle:SetID(questIndex);
		questTitleTag = questLogTitle.tag;
		questNumGroupMates = questLogTitle.groupMates;
		questCheck = questLogTitle.check;
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
				if displayQuestID then
					questLogTitleText = questID .. " - " .. questLogTitleText;
				end

				questLogTitle:SetText("  "..questLogTitleText);
				--Set Dummy text to get text width *SUPER HACK*
				if(QuestLogDummyText) then
					QuestLogDummyText:SetText("  "..questLogTitleText);
				end
				questLogTitle:ClearHighlightTexture();
				questLogTitle:ClearNormalTexture();

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
				-- If there's quest tag position check accordingly
				questTitleTag:Show();
				questCheck:Hide();
			else
				questTitleTag:SetText("");
			end
			if ( IsQuestWatched(questIndex) ) then
				questCheck:Show();
			else
				questCheck:Hide();
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

			-- Resize text
			QuestLogTitleButton_Resize(questLogTitle);

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
		questLogTitleText, level, questTag, isHeader, isCollapsed = GetQuestLogTitle(i);
		if ( questLogTitleText and isHeader ) then
			numHeaders = numHeaders + 1;
			if ( isCollapsed ) then
				notExpanded = notExpanded + 1;
			end
		end
	end

	-- Update Quest Count
	if (numQuests > MAX_QUESTLOG_QUESTS) then
		QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, RED_FONT_COLOR_CODE, numQuests, MAX_QUESTLOG_QUESTS);
	else
		QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, "|cffffffff", numQuests, MAX_QUESTLOG_QUESTS);
	end

	HybridScrollFrame_Update(QuestLogListScrollFrame, numEntries * buttonHeight, displayedHeight);

	-- update the control panel
	QuestLogControlPanel_UpdateState();
end

function QuestLog_SetSelection(questIndex)

	SelectQuestLogEntry(questIndex);
	StaticPopup_Hide("ABANDON_QUEST");
	StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
	QuestLogControlPanel_UpdateState();
	SetAbandonQuest();
	if ( questIndex == 0 ) then
		QuestLogDetailScrollChildFrame:Hide();
		return;
	else
		QuestLogDetailScrollChildFrame:Show();
	end

	QuestLog_UpdateQuestDetails();

	local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(questIndex);
	if ( isHeader ) then
		if ( isCollapsed ) then
			ExpandQuestHeader(questIndex);
		else
			CollapseQuestHeader(questIndex);
		end
		return;
	end

	if(CanAbandonQuest(questID)) then
		QuestLogFrameAbandonButton:Enable();
	else
		QuestLogFrameAbandonButton:Disable();
	end

	QuestLog_UpdatePortrait();

	-- For selection from the watchFrame
	if ( not QuestLogFrame:IsShown() ) then
		ShowUIPanel(QuestLogDetailFrame);
	end
end

function QuestLog_UpdateQuestDetails(doNotScroll)
	QuestInfo_Display(QUEST_TEMPLATE_LOG, QuestLogDetailScrollChildFrame);
	QuestInfoDescriptionText:SetAlphaGradient(1024, QUEST_DESCRIPTION_GRADIENT_LENGTH);
	local numEntries, numQuests = GetNumQuestLogEntries();
	if (not doNotScroll ) then
		QuestLogDetailScrollFrameScrollBar:SetValue(0);
	end	
	if (numEntries > 1) then
		QuestLogDetailScrollFrame:Show();
	end
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
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth() - questTitleTag:GetWidth() - 4 - questCheck:GetWidth() - 2;
		else
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth() - questTitleTag:GetWidth() - 4;
		end
	else
		-- adjust the normal text to not overrun the button
		if ( questCheck:IsShown() ) then
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth() - questCheck:GetWidth() - 2;
		else
			rightEdge = questLogTitle:GetLeft() + questLogTitle:GetWidth();
		end
	end
	-- subtract from the text width the number of pixels that overrun the right edge
	local questNormalTextWidth = questNormalText:GetWidth() - max(questNormalText:GetRight() - rightEdge, 0);
	questNormalText:SetWidth(questNormalTextWidth);
end

function QuestLogTitleButton_OnClick(self, button)
	local questName = self:GetText();
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		-- If header then return
		if ( self.isHeader ) then
			return;
		end

		local questIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		local questLink = GetQuestLink(GetQuestIDFromLogIndex(questIndex));
		if ( questLink ) then
			ChatEdit_InsertLink(questLink);
		end
	elseif ( IsShiftKeyDown() ) then
		-- If header then return
		if ( self.isHeader ) then
			return;
		end

		-- Shift-click toggles quest-watch on this quest.
		_QuestLog_ToggleQuestWatch(self:GetID());
		-- Set an error message if trying to show too many quests
		if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then
			UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0);
			return;
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
	EventRegistry:TriggerEvent("QuestLogFrame.MouseOver", self, self:GetID());
end

function QuestLogTitleButton_OnLeave(self)
	if ( self:GetID() ~= GetQuestLogSelection()) then
		local name = self:GetName();
		self.tag:SetTextColor(self.r, self.g, self.b);
		self.groupMates:SetTextColor(self.r, self.g, self.b);
	end
	GameTooltip:Hide();
end

function QuestLog_UpdatePartyInfoTooltip(questLogTitle)
	local numPartyMembers = GetNumSubgroupMembers();
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
		GameTooltip:Hide();
	else
		GameTooltip:Show();
	end
end

function QuestLog_UpdatePortrait()
	local questPortrait, questPortraitText, questPortraitName, questPortraitMount, questPortraitModelSceneID = GetQuestLogPortraitGiver();
	if (questPortrait and questPortrait ~= 0 and QuestLogShouldShowPortrait()) then
		if (QuestLogDetailFrame.attached) then
			QuestFrame_ShowQuestPortrait(QuestLogFrame, questPortrait, questPortraitMount, questPortraitModelSceneID, questPortraitText, questPortraitName, -5, -42);
		else
			QuestFrame_ShowQuestPortrait(QuestLogDetailFrame, questPortrait, questPortraitMount, questPortraitModelSceneID, questPortraitText, questPortraitName, -3, -42);
		end
	else
		QuestFrame_HideQuestPortrait();
	end
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
			link = GetSpellLink(self:GetID());
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

function GetQuestIDFromLogIndex(questIndex)
	local questID = select(8, GetQuestLogTitle(questIndex));
	return questID;
end

function QuestLogUpdateQuestCount(numQuests)
	if (numQuests > MAX_QUESTLOG_QUESTS) then
		QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, RED_FONT_COLOR_CODE, numQuests, MAX_QUESTLOG_QUESTS);
	else
		QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, "|cffffffff", numQuests, MAX_QUESTLOG_QUESTS);
	end
end
-- Wrath new stuff here

function QuestLog_OpenToQuest(questIndex, keepOpen)
	local selectedIndex = GetQuestLogSelection();

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
-- QuestLogDetailFrame
--

function QuestLogDetailFrame_OnShow(self)
	QuestLogControlPanel_UpdatePosition();
	QuestLogShowMapPOI_UpdatePosition();
	QuestLog_UpdateQuestDetails();
end

function QuestLogDetailFrame_OnHide(self)
	-- this function effectively deselects the selected quest
	QuestLogControlPanel_UpdatePosition();
	QuestLogShowMapPOI_UpdatePosition();
end

function QuestLogDetailFrame_AttachToQuestLog()
	QuestLogDetailFrame.attached = true;
	QuestLogDetailScrollFrame:SetParent(QuestLogFrame);
	QuestLogDetailScrollFrame:ClearAllPoints();
	QuestLogDetailScrollFrame:SetPoint("TOPRIGHT", QuestLogFrame, "TOPRIGHT", -33, -65);
	QuestLogDetailScrollFrameScrollBar:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -13);
	QuestLog_UpdatePortrait();
end

function QuestLogDetailFrame_DetachFromQuestLog()
	QuestLogDetailFrame.attached = false;
	QuestLogDetailScrollFrame:SetParent(QuestLogDetailFrame);
	QuestLogDetailScrollFrame:ClearAllPoints();
	QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogDetailFrame, "TOPLEFT", 8, -65);
	QuestLogDetailScrollFrameScrollBar:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", 6, -14);
	QuestLog_UpdatePortrait();
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
		QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 4, 1);
		QuestLogControlPanel:SetWidth(307);
	elseif ( QuestLogDetailFrame:IsShown() ) then
		parent = QuestLogDetailFrame;
		QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 4, 1);
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
		local _, _, _, _, _, _, _, questID = GetQuestLogTitle(questLogSelection);
		if ( GetAbandonQuestName() and CanAbandonQuest(questID)) then
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

function QuestLogShowMapPOI_UpdatePosition()
	local parent;
	if ( QuestLogFrame:IsShown() ) then
		parent = QuestLogFrame;
	elseif ( QuestLogDetailFrame:IsShown() ) then
		parent = QuestLogDetailFrame;
	end
	
	if ( parent ) then
		QuestLogFrameShowMapButton:SetParent(parent);
		QuestLogFrameShowMapButton:SetPoint("TOPRIGHT", -24, -25);
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
function _QuestLog_ToggleQuestWatch(questIndex)
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
	QuestMapFrame_UpdateAll();
end

function QuestLogFrameTrackButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	_QuestLog_ToggleQuestWatch(GetQuestLogSelection());
	QuestLog_Update();
end
