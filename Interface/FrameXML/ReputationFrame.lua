
NUM_FACTIONS_DISPLAYED = 15;
REPUTATIONFRAME_FACTIONHEIGHT = 26;
MAX_PLAYER_LEVEL = 0;
REPUTATIONFRAME_ROWSPACING = 23;
MAX_REPUTATION_REACTION = 8;

local g_selectionBehavior = nil;

function ReputationFrame_OnLoad(self)
	ReputationWatchBar_UpdateMaxLevel();

	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("ReputationBarTemplate", function(button, elementData)
		ReputationFrame_InitReputationRow(button, elementData);
	end);
	view:SetPadding(0,0,0,2,2);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	g_selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive);
	g_selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			ReputationFrame_InitReputationRow(button, elementData);
	end
	end, self);
end

function ReputationFrame_OnShow(self)
	CharacterFrame:SetTitle(UnitPVPName("player"));
	ReputationFrame_Update();
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");

	local parent = self:GetParent();
	if HelpTip:IsShowing(parent, REPUTATION_EXALTED_PLUS_HELP) then
		HelpTip:Hide(parent, REPUTATION_EXALTED_PLUS_HELP);
		SetCVarBitfield("closedInfoFrames",	LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS, true);
	end
end

function ReputationFrame_OnHide(self)
	self:UnregisterEvent("QUEST_LOG_UPDATE");
	self:UnregisterEvent("UPDATE_FACTION");
end

function ReputationFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_FACTION" or event == "QUEST_LOG_UPDATE" ) then
		ReputationFrame_Update();
	elseif ( event == "UPDATE_EXPANSION_LEVEL" ) then
		ReputationWatchBar_UpdateMaxLevel();
	end
end

function ReputationFrame_SetRowType(factionRow, isChild, isHeader, hasRep)	--rowType is a binary table of type isHeader, isChild
	local factionContainer = factionRow.Container;
	local factionBar = factionContainer.ReputationBar;
	local factionTitle = factionContainer.Name;
	local factionButton = factionContainer.ExpandOrCollapseButton;
	local factionBackground = factionContainer.Background;
	local factionStanding = factionBar.FactionStanding;
	local factionLeftTexture = factionBar.LeftTexture;
	local factionRightTexture = factionBar.RightTexture;

	factionLeftTexture:SetWidth(62);
	factionRightTexture:SetWidth(42);
	factionBar:SetPoint("RIGHT", 0, 0);
	if ( isHeader ) then
		if (isChild) then
			factionContainer:SetPoint("LEFT", 21, 0);
		else
			factionContainer:SetPoint("LEFT", 2, 0);
		end

		factionButton:SetPoint("LEFT", factionContainer, "LEFT", 3, 0);
		factionButton:Show();

		factionTitle:SetPoint("LEFT",factionButton,"RIGHT", 10, 0);
		if (hasRep) then
			factionTitle:SetPoint("RIGHT", factionBar, "LEFT", -3, 0);
		else
			factionTitle:SetPoint("RIGHT", factionBar, "RIGHT", -3, 0);
		end

		factionTitle:SetFontObject(GameFontNormalLeft);
		factionBackground:Hide()
		factionLeftTexture:SetHeight(15);
		factionLeftTexture:SetWidth(60);
		factionRightTexture:SetHeight(15);
		factionRightTexture:SetWidth(39);
		factionLeftTexture:SetTexCoord(0.765625, 1.0, 0.046875, 0.28125);
		factionRightTexture:SetTexCoord(0.0, 0.15234375, 0.390625, 0.625);
		factionBar:SetWidth(99);
	else
		if ( isChild ) then
			factionContainer:SetPoint("LEFT", 44, 0);
		else
			factionContainer:SetPoint("LEFT", 25, 0);
		end

		factionButton:Hide();
		factionTitle:SetPoint("LEFT", 10, 0);
		factionTitle:SetPoint("RIGHT", factionBar, "LEFT", -3, 0);
		factionTitle:SetFontObject(GameFontHighlightSmall);
		factionBackground:Show();
		factionLeftTexture:SetHeight(21);
		factionRightTexture:SetHeight(21);
		factionLeftTexture:SetTexCoord(0.7578125, 1.0, 0.0, 0.328125);
		factionRightTexture:SetTexCoord(0.0, 0.1640625, 0.34375, 0.671875);
		factionBar:SetWidth(101)
	end

	if ( (hasRep) or (not isHeader) ) then
		factionStanding:Show();
		factionBar:Show();
		factionBar:GetParent():GetParent().hasRep = true;
	else
		factionStanding:Hide();
		factionBar:Hide();
		factionBar:GetParent():GetParent().hasRep = false;
	end
end

function ReputationFrame_InitReputationRow(factionRow, elementData)
	local factionIndex = elementData.index;
	local factionContainer = factionRow.Container;
	local factionBar = factionContainer.ReputationBar;
	local factionTitle = factionContainer.Name;
	local factionButton = factionContainer.ExpandOrCollapseButton;
	local factionStanding = factionBar.FactionStanding;

	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive = GetFactionInfo(factionIndex);
	factionTitle:SetText(name);
	if ( isCollapsed ) then
		factionButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	else
		factionButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	end
	factionRow.index = factionIndex;
	factionRow.isCollapsed = isCollapsed;

	local colorIndex = standingID;
	local factionStandingtext;

	local isParagon = factionID and C_Reputation.IsFactionParagon(factionID);
	if ( isParagon ) then
		local paragonFrame = factionContainer.Paragon;
		paragonFrame.factionID = factionID;
		local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
		C_Reputation.RequestFactionParagonPreloadRewardData(factionID);
		paragonFrame.Glow:SetShown(not tooLowLevelForParagon and hasRewardPending);
		paragonFrame.Check:SetShown(not tooLowLevelForParagon and hasRewardPending);
	end
	factionContainer.Paragon:SetShown(isParagon);

	local isCapped;
	if (standingID == MAX_REPUTATION_REACTION) then
		isCapped = true;
	end
	-- check if this is a friendship faction
	local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
	if (friendID ~= nil) then
		factionStandingtext = friendTextLevel;
		if ( nextFriendThreshold ) then
			barMin, barMax, barValue = friendThreshold, nextFriendThreshold, friendRep;
		else
			-- max rank, make it look like a full bar
			barMin, barMax, barValue = 0, 1, 1;
			isCapped = true;
		end
		colorIndex = 5;								-- always color friendships green
		factionRow.friendshipID = friendID;			-- for doing friendship tooltip
	else
		local gender = UnitSex("player");
		factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
		factionRow.friendshipID = nil;
	end

	factionStanding:SetText(factionStandingtext);

	--Normalize Values
	barMax = barMax - barMin;
	barValue = barValue - barMin;
	barMin = 0;

	factionRow.standingText = factionStandingtext;
	if ( isCapped ) then
		factionRow.rolloverText = nil;
	else
		factionRow.rolloverText = HIGHLIGHT_FONT_COLOR_CODE.." "..format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax))..FONT_COLOR_CODE_CLOSE;
	end
	factionBar:SetFillStyle("STANDARD_NO_RANGE_FILL");
	factionBar:SetMinMaxValues(0, barMax);
	factionBar:SetValue(barValue);
	local color = FACTION_BAR_COLORS[colorIndex];
	factionBar:SetStatusBarColor(color.r, color.g, color.b);

	factionBar.BonusIcon:SetShown(hasBonusRepGain);

	ReputationFrame_SetRowType(factionRow, isChild, isHeader, hasRep);

	factionRow:Show();

	-- Update details if this is the selected faction
	if ( atWarWith ) then
		factionContainer.ReputationBar.AtWarHighlight1:Show();
		factionContainer.ReputationBar.AtWarHighlight2:Show();
	else
		factionContainer.ReputationBar.AtWarHighlight1:Hide();
		factionContainer.ReputationBar.AtWarHighlight2:Hide();
	end
	if ( factionIndex == GetSelectedFaction() ) then
		if ( ReputationDetailFrame:IsShown() ) then
			ReputationDetailFactionName:SetText(name);
			ReputationDetailFactionDescription:SetText(description);
			if ( atWarWith ) then
				ReputationDetailAtWarCheckBox:SetChecked(true);
			else
				ReputationDetailAtWarCheckBox:SetChecked(false);
			end
			if ( canToggleAtWar and (not isHeader)) then
				ReputationDetailAtWarCheckBox:Enable();
				ReputationDetailAtWarCheckBoxText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			else
				ReputationDetailAtWarCheckBox:Disable();
				ReputationDetailAtWarCheckBoxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			if ( canSetInactive ) then
				ReputationDetailInactiveCheckBox:Enable();
				ReputationDetailInactiveCheckBoxText:SetTextColor(ReputationDetailInactiveCheckBoxText:GetFontObject():GetTextColor());
			else
				ReputationDetailInactiveCheckBox:Disable();
				ReputationDetailInactiveCheckBoxText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			if ( IsFactionInactive(factionIndex) ) then
				ReputationDetailInactiveCheckBox:SetChecked(true);
			else
				ReputationDetailInactiveCheckBox:SetChecked(false);
			end
			if ( isWatched ) then
				ReputationDetailMainScreenCheckBox:SetChecked(true);
			else
				ReputationDetailMainScreenCheckBox:SetChecked(false);
			end
			factionContainer.ReputationBar.Highlight1:Show();
			factionContainer.ReputationBar.Highlight2:Show();
		end
	else
		factionContainer.ReputationBar.Highlight1:Hide();
		factionContainer.ReputationBar.Highlight2:Hide();
	end
end

function ReputationFrame_Update()
	local newDataProvider = CreateDataProviderByIndexCount(GetNumFactions());
	ReputationFrame.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);

	if ( GetSelectedFaction() == 0 ) then
		ReputationDetailFrame:Hide();
	end
end

function ReputationBar_OnClick(self)
	if ( ReputationDetailFrame:IsShown() and (GetSelectedFaction() == self.index) ) then
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
		ReputationDetailFrame:Hide();
	else
		if ( self.hasRep ) then
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
			SetSelectedFaction(self.index);
			ReputationDetailFrame:Show();
		end
	end

	g_selectionBehavior:ToggleSelect(self);
end

function ReputationWatchBar_UpdateMaxLevel()
	-- Initialize max player level
	MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion();
end

function ShowFriendshipReputationTooltip(friendshipID, parent, anchor)
	local id, rep, maxRep, name, text, texture, reaction, threshold, nextThreshold = GetFriendshipReputation(friendshipID);
	if ( id and id > 0) then
		GameTooltip:SetOwner(parent, anchor);
		local currentRank, maxRank = GetFriendshipReputationRanks(id);
		if ( maxRank > 0 ) then
			GameTooltip:SetText(name.." ("..currentRank.." / "..maxRank..")", 1, 1, 1);
		else
			GameTooltip:SetText(name, 1, 1, 1);
		end
		GameTooltip:AddLine(text, nil, nil, nil, true);
		if ( nextThreshold ) then
			local current = rep - threshold;
			local max = nextThreshold - threshold;
			GameTooltip:AddLine(reaction.." ("..current.." / "..max..")" , 1, 1, 1, true);
		else
			GameTooltip:AddLine(reaction, 1, 1, 1, true);
		end
		GameTooltip:Show();
	end
end

function ReputationParagonFrame_SetupParagonTooltip(frame)
	GameTooltip.owner = frame;
	GameTooltip.factionID = frame.factionID;

	local factionName, _, standingID = GetFactionInfoByID(frame.factionID);
	local factionStandingtext = select(7, GetFriendshipReputation(frame.factionID));
	if not factionStandingtext then
		local gender = UnitSex("player");
		factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
	end
	local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(frame.factionID);

	if ( tooLowLevelForParagon ) then
		GameTooltip_SetTitle(GameTooltip, PARAGON_REPUTATION_TOOLTIP_TEXT_LOW_LEVEL, NORMAL_FONT_COLOR);
	else
		GameTooltip_SetTitle(GameTooltip, factionStandingtext, NORMAL_FONT_COLOR);
		local description = PARAGON_REPUTATION_TOOLTIP_TEXT:format(factionName);
		if ( hasRewardPending ) then
			local questIndex = C_QuestLog.GetLogIndexForQuestID(rewardQuestID);
			local text = GetQuestLogCompletionText(questIndex);
			if ( text and text ~= "" ) then
				description = text;
			end
		end
		GameTooltip_AddHighlightLine(GameTooltip, description);
		if ( not hasRewardPending ) then
			local value = mod(currentValue, threshold);
			-- show overflow if reward is pending
			if ( hasRewardPending ) then
				value = value + threshold;
			end
			GameTooltip_ShowProgressBar(GameTooltip, 0, threshold, value, REPUTATION_PROGRESS_FORMAT:format(value, threshold));
		end
		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, rewardQuestID);
	end
	GameTooltip:Show();
end

function ReputationParagonWatchBar_OnEnter(self)
	if C_Reputation.IsFactionParagon(self.factionID) then
		self.UpdateTooltip = ReputationParagonFrame_SetupParagonTooltip;
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		ReputationParagonFrame_SetupParagonTooltip(self);
	end
end

function ReputationParagonWatchBar_OnLeave(self)
	GameTooltip:Hide();
	self.UpdateTooltip = nil;
end

function ReputationParagonFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self.UpdateTooltip = ReputationParagonFrame_SetupParagonTooltip;
	ReputationParagonFrame_SetupParagonTooltip(self);
end

function ReputationParagonFrame_OnLeave(self)
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
end

function ReputationParagonFrame_OnUpdate(self)
	if ( self.Glow:IsShown() ) then
		local alpha;
		local time = GetTime();
		local value = time - floor(time);
		local direction = mod(floor(time), 2);
		if ( direction == 0 ) then
			alpha = value;
		else
			alpha = 1 - value;
		end
		self.Glow:SetAlpha(alpha);
	end
end

function ReputationDetailMainScreenCheckBox_OnClick(self)
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		SetWatchedFactionIndex(GetSelectedFaction());
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		SetWatchedFactionIndex(0);
	end
	StatusTrackingBarManager:UpdateBarsShown();
end