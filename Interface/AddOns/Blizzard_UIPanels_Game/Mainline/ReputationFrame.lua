
MAX_REPUTATION_REACTION = 8;

local ReputationFilterSortTypeOrder = {
	Enum.ReputationSortType.None,
	Enum.ReputationSortType.Account,
	Enum.ReputationSortType.Character,
};

local function GetReputationSortTypeName(sortType)
	local ReputationSortTypeNames = {
		[Enum.ReputationSortType.None] = REPUTATION_SORT_TYPE_SHOW_ALL,
		[Enum.ReputationSortType.Account] = REPUTATION_SORT_TYPE_ACCOUNT,
		-- [Enum.ReputationSortType.Character] = UnitName("player"),
	};

	-- We don't store the player's name in case it is modified/updated during a play session
	if sortType == Enum.ReputationSortType.Character then
		return UnitName("player");
	end

	return ReputationSortTypeNames[sortType];
end

ReputationFrameMixin = {};

function ReputationFrameMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();

	local function Initializer(button, elementData)
		button:Initialize(elementData);
	end

	view:SetElementIndentCalculator(function(elementData)
		local isTopLevelHeader = elementData.isHeader and not elementData.isChild;
		if isTopLevelHeader then
			return 0;
		end

		local isChildOfSubHeader = not elementData.isHeader and elementData.isChild;
		if isChildOfSubHeader then
			return 46;
		end

		return 2;
	end);

	view:SetElementFactory(function(factory, elementData)
		if not elementData.isHeader then
			factory("ReputationEntryTemplate", Initializer);
			return;
		end

		local isTopLevelHeader = elementData.isHeader and not elementData.isChild;
		if isTopLevelHeader then
			factory("ReputationHeaderTemplate", Initializer);
			return;
		end

		local isSubHeader = elementData.isHeader and elementData.isChild;
		if isSubHeader then
			factory("ReputationSubHeaderTemplate", Initializer);
			return;
		end
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 10, 10, 10, 10;
	local elementSpacing = 3;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, GenerateClosure(self.RefreshAccountWideReputationTutorial), self);

	self.filterDropdown:SetWidth(130);
end

local ReputationFrameEvents = {
	"MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
	"MAJOR_FACTION_UNLOCKED",
	"QUEST_LOG_UPDATE",
	"UPDATE_FACTION",
}

local function IsSortTypeSelected(sortType)
	return C_Reputation.GetReputationSortType() == sortType;
end

local function SetSortTypeSelected(sortType)
	C_Reputation.SetReputationSortType(sortType);
end

local function IsLegacyRepSelected()
	return C_Reputation.AreLegacyReputationsShown();
end

local function SetLegacyRepSelected()
	C_Reputation.SetLegacyReputationsShown(not IsLegacyRepSelected());
end

function ReputationFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ReputationFrameEvents);
	self:Update();

	local parent = self:GetParent();
	if HelpTip:IsShowing(parent, REPUTATION_EXALTED_PLUS_HELP) then
		HelpTip:Hide(parent, REPUTATION_EXALTED_PLUS_HELP);
		SetCVarBitfield("closedInfoFrames",	LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS, true);
	end

	self.filterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_REPUTATION_FRAME_FILTER");

		for index, sortType in ipairs(ReputationFilterSortTypeOrder) do
			rootDescription:CreateRadio(GetReputationSortTypeName(sortType), IsSortTypeSelected, SetSortTypeSelected, sortType);
		end

		local playerOwnsCurrentExpansion = GetExpansionLevel() == GetServerExpansionLevel();
		if playerOwnsCurrentExpansion then
			rootDescription:CreateDivider();
			local checkbox = rootDescription:CreateCheckbox(REPUTATION_CHECKBOX_SHOW_LEGACY_REPUTATIONS, IsLegacyRepSelected, SetLegacyRepSelected);
			checkbox:SetSelectionIgnored();
		end
	end);
end

function ReputationFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ReputationFrameEvents);
end

function ReputationFrameMixin:OnEvent(event, ...)
	if event == "UPDATE_FACTION" or event == "QUEST_LOG_UPDATE" or event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" or event == "MAJOR_FACTION_UNLOCKED" then
		self:Update();
	end
end

function ReputationFrameMixin:Update()
	local factionList = {};
	for index = 1, C_Reputation.GetNumFactions() do
		local factionData = C_Reputation.GetFactionDataByIndex(index);
		if factionData then
			factionData.factionIndex = index;
			tinsert(factionList, factionData);
		end
	end

	self.ScrollBox:SetDataProvider(CreateDataProvider(factionList), ScrollBoxConstants.RetainScrollPosition);

	self.ReputationDetailFrame:Refresh();
end

function ReputationFrameMixin:RefreshAccountWideReputationTutorial()
	HelpTip:Hide(self, ACCOUNT_WIDE_REPUTATION_TUTORIAL);

	local tutorialAcknowledged = GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.AccountWideReputation);
	if tutorialAcknowledged then
		return;
	end

	local accountWideReputation = self.ScrollBox:FindFrameByPredicate(function(button, elementData) return elementData.isAccountWide; end);
	if not accountWideReputation then
		return;
	end

	local helpTipInfo = {
		text = ACCOUNT_WIDE_REPUTATION_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = Enum.FrameTutorialAccount.AccountWideReputation,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = 40,
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
		checkCVars = true,
	};
	HelpTip:Show(self, helpTipInfo, accountWideReputation);
end

local ReputationType = EnumUtil.MakeEnum(
	"Standard",
	"Friendship",
	"MajorFaction"
);

local function GetReputationTypeFromElementData(elementData)
	if not elementData then
		return nil;
	end

	local friendshipData = C_GossipInfo.GetFriendshipReputation(elementData.factionID);
	local isFriendshipReputation = friendshipData and friendshipData.friendshipFactionID > 0;
	if isFriendshipReputation then
		return ReputationType.Friendship;
	end

	if C_Reputation.IsMajorFaction(elementData.factionID) then
		return ReputationType.MajorFaction;
	end

	return ReputationType.Standard;
end

ReputationHeaderMixin = {};

function ReputationHeaderMixin:Initialize(elementData)
	self.elementData = elementData;
	self.factionIndex = elementData.factionIndex;
	self.factionID = elementData.factionID;

	self.Name:SetText(self.elementData.name or "");

	self.Right:SetAtlas(self:IsCollapsed() and "Options_ListExpand_Right" or "Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize);
	self.HighlightRight:SetAtlas(self:IsCollapsed() and "Options_ListExpand_Right" or "Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize);
end

function ReputationHeaderMixin:IsCollapsed()
	return self.elementData.isCollapsed;
end

function ReputationHeaderMixin:ToggleCollapsed()
	if self:IsCollapsed() then
		C_Reputation.ExpandFactionHeader(self.factionIndex);
	else
		C_Reputation.CollapseFactionHeader(self.factionIndex);
	end
end

function ReputationHeaderMixin:OnMouseDown()
	self.Name:AdjustPointsOffset(1, -1);
end

function ReputationHeaderMixin:OnMouseUp()
	self.Name:AdjustPointsOffset(-1, 1);
end

function ReputationHeaderMixin:OnClick()
	self:ToggleCollapsed();
end

ReputationEntryMixin = CreateFromMixins(CallbackRegistryMixin);

function ReputationEntryMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(EventRegistry, "ReputationFrame.NewFactionSelected", self.RefreshHighlightVisuals);

	self.Content.AccountWideIcon:SetScript("OnLeave", function()
		GameTooltip_Hide();
		self:OnLeave();
	end);

	self.Content.BackgroundHighlight:SetFrameLevel(self:GetFrameLevel() - 1);
end

function ReputationEntryMixin:Initialize(elementData)
	self.factionIndex = elementData.factionIndex;
	self.factionID = elementData.factionID;
	self.elementData = elementData;

	self.Content.Name:SetText(self.elementData.name or "");

	self.reputationType = GetReputationTypeFromElementData(self.elementData);
	self:InitializeReputationBarForReputationType();

	self:TryInitParagonDisplay();

	self:RefreshHighlightVisuals();
end

function ReputationEntryMixin:TryInitParagonDisplay()
	local factionID = self.factionID;
	local paragonIcon = self.Content.ParagonIcon;
	if not C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		paragonIcon:Hide();
		return;
	end

	local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
	C_Reputation.RequestFactionParagonPreloadRewardData(factionID);
	paragonIcon.Glow:SetShown(not tooLowLevelForParagon and hasRewardPending);
	paragonIcon.Check:SetShown(not tooLowLevelForParagon and hasRewardPending);
	paragonIcon:Show();
end

function ReputationEntryMixin:OnClick()
	local alreadySelected = self:IsSelected();
	C_Reputation.SetSelectedFaction(not alreadySelected and self.factionIndex or 0);

	-- Hide this faction's tooltip when it is selected (since we're showing the options for this reputation)
	if self:IsSelected() then
		self:HideTooltip();
	-- If we just deselected the faction, then we're clear to show the tooltip again
	elseif self:IsMouseOver() then
		self:ShowTooltipForReputationType();
	end

	EventRegistry:TriggerEvent("ReputationFrame.NewFactionSelected");
end

function ReputationEntryMixin:OnMouseDown()
	self.Content:AdjustPointsOffset(1, -1);
end

function ReputationEntryMixin:OnMouseUp()
	self.Content:AdjustPointsOffset(-1, 1);
end

function ReputationEntryMixin:OnEnter()
	self.Content.ReputationBar:TryShowBarProgressText();

	self:RefreshHighlightVisuals();

	if not self:IsSelected() then
		self:ShowTooltipForReputationType();
	end
end

function ReputationEntryMixin:ShowTooltipForReputationType()
	if C_Reputation.IsFactionParagonForCurrentPlayer(self.elementData.factionID) then
		self:ShowParagonRewardsTooltip();
	elseif self.reputationType == ReputationType.Friendship then
		local canClickForOptions = true;
		self:ShowFriendshipReputationTooltip(self.elementData.factionID, "ANCHOR_RIGHT", canClickForOptions);
	elseif self.reputationType == ReputationType.MajorFaction then
		self:ShowMajorFactionRenownTooltip();
	elseif self.reputationType == ReputationType.Standard then
		self:ShowStandardTooltip();
	end
end

function ReputationEntryMixin:ShowParagonRewardsTooltip()
	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	ReputationParagonFrame_SetupParagonTooltip(self);
	GameTooltip_SetBottomText(EmbeddedItemTooltip, REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION, GREEN_FONT_COLOR);
	EmbeddedItemTooltip:Show();
end

function ReputationEntryMixin:ShowFriendshipReputationTooltip(factionID, anchor, canClickForOptions)
	local friendshipData = C_GossipInfo.GetFriendshipReputation(factionID);
	if not friendshipData or friendshipData.friendshipFactionID < 0 then
		return;
	end

	GameTooltip:SetOwner(self, anchor);
	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID);
	if rankInfo.maxLevel > 0 then
		GameTooltip_SetTitle(GameTooltip, friendshipData.name.." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", HIGHLIGHT_FONT_COLOR);
	else
		GameTooltip_SetTitle(GameTooltip, friendshipData.name, HIGHLIGHT_FONT_COLOR);
	end

	ReputationUtil.TryAppendAccountReputationLineToTooltip(GameTooltip, factionID);

	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip:AddLine(friendshipData.text, nil, nil, nil, true);
	if friendshipData.nextThreshold then
		local current = friendshipData.standing - friendshipData.reactionThreshold;
		local max = friendshipData.nextThreshold - friendshipData.reactionThreshold;
		local wrapText = true;
		GameTooltip_AddHighlightLine(GameTooltip, friendshipData.reaction.." ("..current.." / "..max..")", wrapText);
	else
		local wrapText = true;
		GameTooltip_AddHighlightLine(GameTooltip, friendshipData.reaction, wrapText);
	end

	-- This tooltip code is shared between Gossips (no click functionality) and the Reputation UI (can click button for options)
	if canClickForOptions then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddInstructionLine(GameTooltip, REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION);
	end

	GameTooltip:Show();
end

function ReputationEntryMixin:ShowMajorFactionRenownTooltip()
	local factionID = self.elementData.factionID;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	RenownRewardUtil.AddMajorFactionToTooltip(GameTooltip, factionID, GenerateClosure(self.ShowMajorFactionRenownTooltip, self));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddInstructionLine(GameTooltip, REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION);
	EventRegistry:TriggerEvent("ShowMajorFactionRenown.Tooltip.OnEnter", self, GameTooltip, factionID);
	GameTooltip:Show();
end

function ReputationEntryMixin:ShowStandardTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.elementData.name);
	ReputationUtil.TryAppendAccountReputationLineToTooltip(GameTooltip, self.elementData.factionID);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddInstructionLine(GameTooltip, REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION);
	GameTooltip:Show();
end

function ReputationEntryMixin:OnLeave()
	self.Content.ReputationBar:TryShowReputationStandingText();

	self:RefreshHighlightVisuals();

	self:HideTooltip();
end

function ReputationEntryMixin:HideTooltip()
	-- Hide the reputation progress tooltip or the paragon progress tooltip (whichever is up)
	if GameTooltip:GetOwner() == self then
		GameTooltip_Hide();
	elseif EmbeddedItemTooltip:GetOwner() == self then
		EmbeddedItemTooltip_Hide(EmbeddedItemTooltip);
	end
end

function ReputationEntryMixin:IsSelected()
	return C_Reputation.GetSelectedFaction() == self.factionIndex;
end

function ReputationEntryMixin:RefreshHighlightVisuals()
	self:RefreshAccountWideIcon();
	self:RefreshBackgroundHighlight();
end

function ReputationEntryMixin:RefreshAccountWideIcon()
	local showAccountWideIcon = C_Reputation.IsAccountWideReputation(self.factionID) and (self:IsSelected() or self:IsMouseOver());
	self.Content.AccountWideIcon:SetShown(showAccountWideIcon);
end

function ReputationEntryMixin:RefreshBackgroundHighlight()
	self:RefreshBackgroundHighlightColor();
	self:RefreshBackgroundHighlightOpacity();
end

function ReputationEntryMixin:RefreshBackgroundHighlightColor()
	local highlightColor = self:IsAtWar() and FACTION_AT_WAR_COLOR or WHITE_FONT_COLOR;
	for index, region in ipairs(self.Content.BackgroundHighlight.TextureRegions) do
		region:SetVertexColor(highlightColor:GetRGB());
	end
end

function ReputationEntryMixin:RefreshBackgroundHighlightOpacity()
	-- "At War" entries always have a highlight, even if not selected or moused over.
	local isSelected, isMouseOver, isAtWar = self:IsSelected(), self:IsMouseOver(), self:IsAtWar();
	local entryNeedsHighlight = isSelected or isMouseOver or isAtWar;
	if not entryNeedsHighlight then
		self.Content.BackgroundHighlight:SetAlpha(0);
		return;
	end

	local alpha = 0;
	if isAtWar then
		alpha = (isSelected and 0.85) or (isMouseOver and 0.65) or 0.50;
	else
		alpha = (isSelected and 0.20) or (isMouseOver and 0.10) or 0;
	end
	self.Content.BackgroundHighlight:SetAlpha(alpha);
end

function ReputationEntryMixin:IsAtWar()
	return self.elementData.atWarWith;
end

ReputationEntryAccountWideIconMixin = {};

function ReputationEntryAccountWideIconMixin:OnEnter()
	if not self:IsShown() then
		return;
	end

	self:ShowTooltip();
end

function ReputationEntryAccountWideIconMixin:ShowTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL);
	GameTooltip:Show();
end

local function NormalizeBarValues(minValue, maxValue, currentValue)
	maxValue = maxValue - minValue;
	currentValue = currentValue - minValue;
	minValue = 0;

	return minValue, maxValue, currentValue;
end

local function InitializeBarForStandardReputation(factionData, reputationBar)
	local isCapped = factionData.reaction == MAX_REPUTATION_REACTION;
	local minValue, maxValue, currentValue;
	if isCapped then
		-- Max rank, make it look like a full bar
		minValue, maxValue, currentValue = 0, 1, 1;
	else
		minValue, maxValue, currentValue = factionData.currentReactionThreshold, factionData.nextReactionThreshold, factionData.currentStanding;
	end
	minValue, maxValue, currentValue = NormalizeBarValues(minValue, maxValue, currentValue);
	reputationBar:UpdateBarValues(minValue, maxValue, currentValue);

	local progressText = not isCapped and HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(REPUTATION_PROGRESS_FORMAT:format(BreakUpLargeNumbers(currentValue), BreakUpLargeNumbers(maxValue))) or nil;
	reputationBar:UpdateBarProgressText(progressText);
	local gender = UnitSex("player");
	local reputationStandingtext = GetText("FACTION_STANDING_LABEL" .. factionData.reaction, gender);
	reputationBar:UpdateReputationStandingText(reputationStandingtext);
	reputationBar:TryShowReputationStandingText();

	local colorIndex = factionData.reaction;
	reputationBar:UpdateBarColor(FACTION_BAR_COLORS[colorIndex]);
end

local function InitializeBarForFriendship(factionData, reputationBar)
	local minValue, maxValue, currentValue;
	local friendshipData = C_GossipInfo.GetFriendshipReputation(factionData.factionID);
	local isMaxRank = friendshipData.nextThreshold == nil;
	if isMaxRank then
		-- Max rank, make it look like a full bar
		minValue, maxValue, currentValue = 0, 1, 1;
	else
		minValue, maxValue, currentValue = friendshipData.reactionThreshold, friendshipData.nextThreshold, friendshipData.standing;
	end
	minValue, maxValue, currentValue = NormalizeBarValues(minValue, maxValue, currentValue);
	reputationBar:UpdateBarValues(minValue, maxValue, currentValue);

	local progressText = not isMaxRank and HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(REPUTATION_PROGRESS_FORMAT:format(BreakUpLargeNumbers(currentValue), BreakUpLargeNumbers(maxValue))) or nil;
	reputationBar:UpdateBarProgressText(progressText)
	reputationBar:UpdateReputationStandingText(friendshipData.reaction);
	reputationBar:TryShowReputationStandingText();

	local friendshipColorIndex = 5; -- Always color friendships green
	reputationBar:UpdateBarColor(FACTION_BAR_COLORS[friendshipColorIndex]);
end

local function InitializeBarForMajorFaction(factionData, reputationBar)
	local minValue, maxValue, currentValue;
	local majorFactionData = C_MajorFactions.GetMajorFactionData(factionData.factionID);
	local isMaxRenown = C_MajorFactions.HasMaximumRenown(factionData.factionID);
	if isMaxRenown then
		-- Max renown, make it look like a full bar
		minValue, maxValue, currentValue = 0, 1, 1;
	elseif majorFactionData then
		minValue, maxValue, currentValue = 0, majorFactionData.renownLevelThreshold, majorFactionData.renownReputationEarned;
	else
		minValue, maxValue, currentValue = 0, 0, 0;
	end
	minValue, maxValue, currentValue = NormalizeBarValues(minValue, maxValue, currentValue);
	reputationBar:UpdateBarValues(minValue, maxValue, currentValue);

	local progressText = not isMaxRenown and HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(REPUTATION_PROGRESS_FORMAT:format(BreakUpLargeNumbers(currentValue), BreakUpLargeNumbers(maxValue))) or nil;
	reputationBar:UpdateBarProgressText(progressText);
	reputationBar:UpdateReputationStandingText(RENOWN_LEVEL_LABEL:format(majorFactionData and majorFactionData.renownLevel or 0));
	reputationBar:TryShowReputationStandingText();

	reputationBar:UpdateBarColor(BLUE_FONT_COLOR);
end

local BarInitializerByReputationType = {
	[ReputationType.Standard] = InitializeBarForStandardReputation,
	[ReputationType.Friendship] = InitializeBarForFriendship,
	[ReputationType.MajorFaction] = InitializeBarForMajorFaction,
};

function ReputationEntryMixin:InitializeReputationBarForReputationType()
	local BarInitializer = BarInitializerByReputationType[self.reputationType];

	if not BarInitializer then
		return;
	end

	BarInitializer(self.elementData, self.Content.ReputationBar);

	self.Content.ReputationBar.BonusIcon:SetShown(self.elementData.hasBonusRepGain);
end

ReputationSubHeaderMixin = CreateFromMixins(ReputationEntryMixin);

function ReputationSubHeaderMixin:Initialize(elementData)
	ReputationEntryMixin.Initialize(self, elementData);

	self.Content.Name:ClearAllPoints();
	self.Content.Name:SetPoint("LEFT", self.ToggleCollapseButton, "RIGHT", 4, 0);
	self.Content.Name:SetPoint("RIGHT", self.Content.ReputationBar, "LEFT", -10, 0);

	self.Content.ReputationBar:SetShown(elementData.isHeaderWithRep);
	self.Content.BackgroundHighlight:SetShown(elementData.isHeaderWithRep);
	self:EnableMouse(elementData.isHeaderWithRep);

	self.ToggleCollapseButton:RefreshIcon();
end

function ReputationSubHeaderMixin:IsCollapsed()
	return self.elementData.isCollapsed;
end

function ReputationSubHeaderMixin:ToggleCollapsed()
	if self:IsCollapsed() then
		C_Reputation.ExpandFactionHeader(self.factionIndex);
	else
		C_Reputation.CollapseFactionHeader(self.factionIndex);
	end
end

ReputationSubHeaderToggleCollapseButtonMixin = {};

function ReputationSubHeaderToggleCollapseButtonMixin:GetHeader()
	return self:GetParent();
end

function ReputationSubHeaderToggleCollapseButtonMixin:RefreshIcon()
	local header = self:GetHeader();
	self:GetNormalTexture():SetAtlas(header:IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open", TextureKitConstants.UseAtlasSize);
	self:GetPushedTexture():SetAtlas(header:IsCollapsed() and "campaign_headericon_closedpressed" or "campaign_headericon_openpressed", TextureKitConstants.UseAtlasSize);
end

function ReputationSubHeaderToggleCollapseButtonMixin:OnClick()
	self:GetHeader():ToggleCollapsed();
end

ReputationBarMixin = {};

function ReputationBarMixin:UpdateBarValues(minValue, maxValue, currentValue)
	self:SetMinMaxValues(minValue, maxValue);
	self:SetValue(currentValue);
end

function ReputationBarMixin:UpdateBarColor(color)
	self:SetStatusBarColor(color:GetRGB());
end

function ReputationBarMixin:UpdateBarProgressText(barProgressText)
	self.barProgressText = barProgressText;
end

function ReputationBarMixin:UpdateReputationStandingText(reputationStandingText)
	self.reputationStandingText = reputationStandingText;
end

function ReputationBarMixin:TryShowBarProgressText()
	if not self.barProgressText then
		return;
	end

	self.BarText:SetText(self.barProgressText);
end

function ReputationBarMixin:TryShowReputationStandingText()
	if not self.reputationStandingText then
		return;
	end

	self.BarText:SetText(self.reputationStandingText);
end

ReputationBarBonusIconMixin = {};

function ReputationBarBonusIconMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, BONUS_REPUTATION_TITLE, HIGHLIGHT_FONT_COLOR);
	local wrapText = true;
	GameTooltip_AddNormalLine(GameTooltip, BONUS_REPUTATION_TOOLTIP, wrapText);
	GameTooltip:Show();
end

function ReputationBarBonusIconMixin:OnLeave()
	GameTooltip_Hide();
end

ReputationBarParagonIconMixin = {};

function ReputationBarParagonIconMixin:OnUpdate()
	if not self.Glow:IsShown() then
		return;
	end

	local alpha;
	local time = GetTime();
	local value = time - floor(time);
	local direction = mod(floor(time), 2);
	if direction == 0 then
		alpha = value;
	else
		alpha = 1 - value;
	end
	self.Glow:SetAlpha(alpha);
end

function ReputationParagonFrame_SetupParagonTooltip(frame)
	local factionID = frame.factionID;
	EmbeddedItemTooltip.factionID = frame.factionID;
	ReputationUtil.AddParagonRewardsToTooltip(EmbeddedItemTooltip, factionID);
end

function ReputationParagonWatchBar_OnEnter(self)
	if not C_Reputation.IsFactionParagonForCurrentPlayer(self.factionID) then
		return;
	end

	self.UpdateTooltip = ReputationParagonFrame_SetupParagonTooltip;
	GameTooltip_SetDefaultAnchor(EmbeddedItemTooltip, self);
	ReputationParagonFrame_SetupParagonTooltip(self);
	EmbeddedItemTooltip:Show();
end

function ReputationParagonWatchBar_OnLeave(self)
	EmbeddedItemTooltip_Hide(EmbeddedItemTooltip);
	self.UpdateTooltip = nil;
end

ReputationDetailFrameMixin = CreateFromMixins(CallbackRegistryMixin);

function ReputationDetailFrameMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddStaticEventMethod(EventRegistry, "ReputationFrame.NewFactionSelected", self.Refresh);

	ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollingDescription:GetScrollBox(), self.ScrollingDescriptionScrollBar);
end

function ReputationDetailFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function ReputationDetailFrameMixin:OnHide()
	self:ClearSelectedFaction();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function ReputationDetailFrameMixin:Refresh()
	local selectedFactionIndex = C_Reputation.GetSelectedFaction();
	local factionData = C_Reputation.GetFactionDataByIndex(selectedFactionIndex);
	if not factionData or factionData.factionID <= 0 then
		self:Hide();
		return;
	end

	self.Title:SetText(factionData.name);
	self.ScrollingDescription:SetText(factionData.description);

	self.AtWarCheckbox:SetEnabled(factionData.canToggleAtWar and not factionData.isHeader);
	self.AtWarCheckbox:SetChecked(factionData.atWarWith);
	local atWarTextColor = factionData.canToggleAtWar and not factionData.isHeader and RED_FONT_COLOR or GRAY_FONT_COLOR;
	self.AtWarCheckbox.Label:SetTextColor(atWarTextColor:GetRGB());

	self.MakeInactiveCheckbox:SetEnabled(factionData.canSetInactive);
	self.MakeInactiveCheckbox:SetChecked(not C_Reputation.IsFactionActive(selectedFactionIndex));
	local inactiveTextColor = factionData.canSetInactive and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
	self.MakeInactiveCheckbox.Label:SetTextColor(inactiveTextColor:GetRGB());

	self.WatchFactionCheckbox:SetChecked(factionData.isWatched);

	local isMajorFaction = C_Reputation.IsMajorFaction(factionData.factionID);
	self:SetHeight(isMajorFaction and 228 or 203);
	self.ViewRenownButton:Refresh();

	self:Show();
end

function ReputationDetailFrameMixin:ClearSelectedFaction()
	C_Reputation.SetSelectedFaction(0);
	EventRegistry:TriggerEvent("ReputationFrame.NewFactionSelected");
end

ReputationDetailViewRenownButtonMixin = {};

function ReputationDetailViewRenownButtonMixin:Refresh()
	local factionData = C_Reputation.GetFactionDataByIndex(C_Reputation.GetSelectedFaction());
	self.factionID = factionData and factionData.factionID or nil;
	if not self.factionID or not C_Reputation.IsMajorFaction(self.factionID) then
		self:Disable();
		self:Hide();
		return;
	end

	local majorFactionData = C_MajorFactions.GetMajorFactionData(self.factionID);

	self.disabledTooltip = majorFactionData and majorFactionData.unlockDescription or "";
	self:SetEnabled(majorFactionData and majorFactionData.isUnlocked or false);
	self:Show();
end

function ReputationDetailViewRenownButtonMixin:OnClick()
	if not EncounterJournal then
		EncounterJournal_LoadUI();
	end

	if not EncounterJournal:IsShown() then
		ShowUIPanel(EncounterJournal);
	end

	EJ_ContentTab_Select(EncounterJournal.JourneysTab:GetID());
	EncounterJournalJourneysFrame:ResetView(nil, self.factionID);
end

ReputationDetailAtWarCheckboxMixin = {};

function ReputationDetailAtWarCheckboxMixin:OnClick()
	C_Reputation.ToggleFactionAtWar(C_Reputation.GetSelectedFaction());

	local clickSound = self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF;
	PlaySound(clickSound);

	ReputationFrame:Update();
end

function ReputationDetailAtWarCheckboxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local wrapText = true;
	GameTooltip_AddNormalLine(GameTooltip, REPUTATION_AT_WAR_DESCRIPTION, wrapText);
	GameTooltip:Show();
end

function ReputationDetailAtWarCheckboxMixin:OnLeave()
	GameTooltip_Hide();
end

ReputationDetailInactiveCheckboxMixin = {};

function ReputationDetailInactiveCheckboxMixin:OnClick()
	local shouldBeActive = not self:GetChecked();
	C_Reputation.SetFactionActive(C_Reputation.GetSelectedFaction(), shouldBeActive);

	local clickSound = self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF;
	PlaySound(clickSound);
end

function ReputationDetailInactiveCheckboxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local wrapText = true;
	GameTooltip_AddNormalLine(GameTooltip, REPUTATION_MOVE_TO_INACTIVE, wrapText);
	GameTooltip:Show();
end

function ReputationDetailInactiveCheckboxMixin:OnLeave()
	GameTooltip_Hide();
end

ReputationDetailWatchFactionCheckboxMixin = {};

function ReputationDetailWatchFactionCheckboxMixin:OnClick()
	C_Reputation.SetWatchedFactionByIndex(self:GetChecked() and C_Reputation.GetSelectedFaction() or 0);

	StatusTrackingBarManager:UpdateBarsShown();

	local clickSound = self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF;
	PlaySound(clickSound);
end

function ReputationDetailWatchFactionCheckboxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local wrapText = true;
	GameTooltip_AddNormalLine(GameTooltip, REPUTATION_SHOW_AS_XP, wrapText);
	GameTooltip:Show();
end

function ReputationDetailWatchFactionCheckboxMixin:OnLeave()
	GameTooltip_Hide();
end

