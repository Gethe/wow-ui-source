
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
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED");
	self:RegisterEvent("MAJOR_FACTION_UNLOCKED");

	local parent = self:GetParent();
	if HelpTip:IsShowing(parent, REPUTATION_EXALTED_PLUS_HELP) then
		HelpTip:Hide(parent, REPUTATION_EXALTED_PLUS_HELP);
		SetCVarBitfield("closedInfoFrames",	LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS, true);
	end
end

function ReputationFrame_OnHide(self)
	self:UnregisterEvent("QUEST_LOG_UPDATE");
	self:UnregisterEvent("UPDATE_FACTION");
	self:UnregisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED");
	self:UnregisterEvent("MAJOR_FACTION_UNLOCKED");
end

function ReputationFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_FACTION" or event == "QUEST_LOG_UPDATE" or event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" or event == "MAJOR_FACTION_UNLOCKED" ) then
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
		local isMajorFactionHeader = factionRow.factionID and C_Reputation.IsMajorFaction(factionRow.factionID);

		local xOffset = isMajorFactionHeader and 25 or isChild and 21 or 2;
		local yOffset = 0;
		factionContainer:SetPoint("LEFT", xOffset, yOffset);

		factionButton:SetPoint("LEFT", factionContainer, "LEFT", 3, 0);
		factionButton:Show();

		factionTitle:SetPoint("LEFT", factionButton, "RIGHT", 10, 0);
		local relativePoint = hasRep and "LEFT" or "RIGHT";
		factionTitle:SetPoint("RIGHT", factionBar, relativePoint, -3, 0);
		factionTitle:SetFontObject(isMajorFactionHeader and GameFontHighlightSmall or GameFontNormalLeft);

		factionBackground:SetShown(isMajorFactionHeader);

		if isMajorFactionHeader then
			factionLeftTexture:SetHeight(21);
			factionRightTexture:SetHeight(21);
			factionLeftTexture:SetTexCoord(0.7578125, 1.0, 0.0, 0.328125);
			factionRightTexture:SetTexCoord(0.0, 0.1640625, 0.34375, 0.671875);
			factionBar:SetWidth(101);
		else
			factionLeftTexture:SetHeight(15);
			factionLeftTexture:SetWidth(60);
			factionRightTexture:SetHeight(15);
			factionRightTexture:SetWidth(39);
			factionLeftTexture:SetTexCoord(0.765625, 1.0, 0.046875, 0.28125);
			factionRightTexture:SetTexCoord(0.0, 0.15234375, 0.390625, 0.625);
			factionBar:SetWidth(99);
		end
	else
		local xOffset = isChild and 44 or 25;
		local yOffset = 0;
		factionContainer:SetPoint("LEFT", xOffset, yOffset);

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

	factionStanding:SetShown(hasRep or not isHeader);
	factionBar:SetShown(hasRep or not isHeader);
	factionBar:GetParent():GetParent().hasRep = hasRep or not isHeader;
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
	factionRow.factionID = factionID;
	factionRow.isCollapsed = isCollapsed;

	local colorIndex = standingID;
	local barColor = FACTION_BAR_COLORS[colorIndex];
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
	-- check if this is a friendship faction or a Major Faction
	local isMajorFaction = factionID and C_Reputation.IsMajorFaction(factionID);
	local repInfo = factionID and C_GossipInfo.GetFriendshipReputation(factionID);
	if (repInfo and repInfo.friendshipFactionID > 0) then
		factionStandingtext = repInfo.reaction;
		if ( repInfo.nextThreshold ) then
			barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
		else
			-- max rank, make it look like a full bar
			barMin, barMax, barValue = 0, 1, 1;
			isCapped = true;
		end
		local friendshipColorIndex = 5;
		barColor = FACTION_BAR_COLORS[colorIndex];						-- always color friendships green
		factionRow.friendshipID = repInfo.friendshipFactionID;			-- for doing friendship tooltip
	elseif ( isMajorFaction ) then
		local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);

		barMin, barMax = 0, majorFactionData.renownLevelThreshold;
		isCapped = C_MajorFactions.HasMaximumRenown(factionID);
		barValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0;
		barColor = BLUE_FONT_COLOR;

		factionRow.friendshipID = nil;
		factionStandingtext = RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel;
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
	factionBar:SetStatusBarColor(barColor.r, barColor.g, barColor.b);

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

			ReputationDetailAtWarCheckBox:SetEnabled(canToggleAtWar and (not isHeader));
			ReputationDetailAtWarCheckBox:SetChecked(atWarWith);
			local atWarTextColor = canToggleAtWar and not isHeader and RED_FONT_COLOR or GRAY_FONT_COLOR
			ReputationDetailAtWarCheckBoxText:SetTextColor(atWarTextColor:GetRGB())

			ReputationDetailInactiveCheckBox:SetEnabled(canSetInactive);			
			ReputationDetailInactiveCheckBox:SetChecked(IsFactionInactive(factionIndex));
			local inactiveTextColor = canSetInactive and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
			ReputationDetailInactiveCheckBoxText:SetTextColor(inactiveTextColor:GetRGB());

			ReputationDetailMainScreenCheckBox:SetChecked(isWatched);
			
			local isMajorFaction = factionID and C_Reputation.IsMajorFaction(factionID);
			ReputationDetailFrame:SetHeight(isMajorFaction and 228 or 203);
			ReputationDetailViewRenownButton:Refresh();

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

function ReputationWatchBar_UpdateMaxLevel()
	-- Initialize max player level
	MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion();
end

function ReputationParagonFrame_SetupParagonTooltip(frame)
	GameTooltip.owner = frame;
	GameTooltip.factionID = frame.factionID;

	local factionStandingtext;
	local factionName, _, standingID = GetFactionInfoByID(frame.factionID);
	local reputationInfo = C_GossipInfo.GetFriendshipReputation(frame.factionID);
	if reputationInfo and reputationInfo.friendshipFactionID > 0 then
		factionStandingtext = reputationInfo.reaction;
	elseif C_Reputation.IsMajorFaction(frame.factionID) then
		factionStandingtext = MAJOR_FACTION_MAX_RENOWN_REACHED;
	else
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

ReputationDetailViewRenownButtonMixin = {};

function ReputationDetailViewRenownButtonMixin:Refresh()
	self.factionID = select(14, GetFactionInfo(GetSelectedFaction()));
	if not self.factionID or not C_Reputation.IsMajorFaction(self.factionID) then
		self:Disable();
		self:Hide();
		return;
	end

	local majorFactionData = C_MajorFactions.GetMajorFactionData(self.factionID);

	self.disabledTooltip = majorFactionData.unlockDescription;
	self:SetEnabled(majorFactionData.isUnlocked);
	self:Show();
end


function ReputationDetailViewRenownButtonMixin:OnClick()
	MajorFactions_LoadUI();

	if MajorFactionRenownFrame:IsShown() and MajorFactionRenownFrame:GetCurrentFactionID() == self.factionID then
		ToggleMajorFactionRenown();
	else
		HideUIPanel(MajorFactionRenownFrame);
		EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", self.factionID);
		ShowUIPanel(MajorFactionRenownFrame);
	end
end

ReputationBarMixin = {};

function ReputationBarMixin:OnLoad()
	self.Container.ReputationBar.Highlight1:SetPoint("TOPLEFT",self.Container,"TOPLEFT",-2, 4);
	self.Container.ReputationBar.Highlight1:SetPoint("BOTTOMRIGHT",self.Container,"BOTTOMRIGHT",-10, -4);
	self.Container.ReputationBar.AtWarHighlight1:SetPoint("TOPLEFT",self.Container,"TOPLEFT",3,-2);
	self.Container.ReputationBar.AtWarHighlight2:SetPoint("TOPRIGHT",self.Container,"TOPRIGHT",-1,-2);
	self.Container.ReputationBar.AtWarHighlight1:SetAlpha(0.2);
	self.Container.ReputationBar.AtWarHighlight2:SetAlpha(0.2);
	self.Container.Background:SetPoint("TOPRIGHT", self.Container.ReputationBar.LeftTexture, "TOPLEFT", 0, 0);
end

function ReputationBarMixin:OnClick(button, down)
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

function ReputationBarMixin:OnEnter()
	if (self.rolloverText) then
		self.Container.ReputationBar.FactionStanding:SetText(self.rolloverText);
	end

	self.Container.ReputationBar.Highlight1:Show();
	self.Container.ReputationBar.Highlight2:Show();
	
	if ( self.friendshipID ) then
		self:ShowFriendshipReputationTooltip(self.friendshipID, "ANCHOR_BOTTOMRIGHT");
	elseif self.factionID and C_Reputation.IsMajorFaction(self.factionID) and not C_MajorFactions.HasMaximumRenown(self.factionID) then
		self:ShowMajorFactionRenownTooltip();
	elseif self.Container.Name:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.Container.Name:GetText(), nil, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function ReputationBarMixin:OnLeave()
	self.Container.ReputationBar.FactionStanding:SetText(self.standingText);

	if ((GetSelectedFaction() ~= self.index) or (not ReputationDetailFrame:IsShown())) then
		self.Container.ReputationBar.Highlight1:Hide();
		self.Container.ReputationBar.Highlight2:Hide();
	end

	GameTooltip:Hide();
end

function ReputationBarMixin:ShowFriendshipReputationTooltip(friendshipID, anchor)
	local repInfo = C_GossipInfo.GetFriendshipReputation(friendshipID);
	if ( repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0) then
		GameTooltip:SetOwner(self, anchor);
		local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(repInfo.friendshipFactionID);
		if ( rankInfo.maxLevel > 0 ) then
			GameTooltip:SetText(repInfo.name.." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", 1, 1, 1);
		else
			GameTooltip:SetText(repInfo.name, 1, 1, 1);
		end
		GameTooltip:AddLine(repInfo.text, nil, nil, nil, true);
		if ( repInfo.nextThreshold ) then
			local current = repInfo.standing - repInfo.reactionThreshold;
			local max = repInfo.nextThreshold - repInfo.reactionThreshold;
			GameTooltip:AddLine(repInfo.reaction.." ("..current.." / "..max..")" , 1, 1, 1, true);
		else
			GameTooltip:AddLine(repInfo.reaction, 1, 1, 1, true);
		end
		GameTooltip:Show();
	end
end

function ReputationBarMixin:ShowMajorFactionRenownTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local majorFactionData = C_MajorFactions.GetMajorFactionData(self.factionID);

	local tooltipTitle = majorFactionData.name;
	GameTooltip_SetTitle(GameTooltip, tooltipTitle, NORMAL_FONT_COLOR);
	GameTooltip_AddColoredLine(GameTooltip, RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel, BLUE_FONT_COLOR);

	GameTooltip_AddBlankLineToTooltip(GameTooltip);


	GameTooltip_AddHighlightLine(GameTooltip, MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS:format(majorFactionData.name));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(self.factionID, C_MajorFactions.GetCurrentRenownLevel(self.factionID) + 1);
	if #nextRenownRewards > 0 then
		RenownRewardUtil.AddRenownRewardsToTooltip(GameTooltip, nextRenownRewards, GenerateClosure(self.ShowMajorFactionRenownTooltip, self));
	end

	GameTooltip:Show();
end
