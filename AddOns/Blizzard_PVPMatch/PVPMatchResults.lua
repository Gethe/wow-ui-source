local ACTIVE_EVENTS = {
	"PVP_MATCH_COMPLETE",
	"TREASURE_PICKER_CACHE_FLUSH",
	"LFG_ROLE_CHECK_DECLINED",
	"POST_MATCH_ITEM_REWARD_UPDATE",
	"POST_MATCH_CURRENCY_REWARD_UPDATE",
	"LFG_ROLE_CHECK_SHOW",
	"LFG_READY_CHECK_DECLINED",
	"LFG_READY_CHECK_SHOW",
};

local LeaveMatchFormatter = CreateFromMixins(SecondsFormatterMixin);
LeaveMatchFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, true);
LeaveMatchFormatter:SetStripIntervalWhitespace(true);

function LeaveMatchFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

PVPMatchResultsCurrencyRewardMixin = {};
function PVPMatchResultsCurrencyRewardMixin:OnLoad()
	local currencyInfo = self.currencyID and C_CurrencyInfo.GetCurrencyInfo(self.currencyID) or nil;
	if currencyInfo then
		self.Icon:SetTexture(currencyInfo.iconFileID);
	end
end

function PVPMatchResultsCurrencyRewardMixin:OnEnter()
	if self.currencyID then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetCurrencyByID(self.currencyID);
	end
end

function PVPMatchResultsCurrencyRewardMixin:OnLeave()
	GameTooltip_Hide();
end

PVPMatchResultsMixin = {};
function PVPMatchResultsMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
	self:RegisterEvent("PVP_MATCH_ACTIVE");
	
	local tabContainer = self.content.tabContainer;
	self.scrollFrame = self.content.scrollFrame;
	self.scrollCategories = self.content.scrollCategories;
	self.tabGroup = tabContainer.tabGroup;
	self.tab1 = self.tabGroup.tab1;
	self.tab2 = self.tabGroup.tab2;
	self.tab3 = self.tabGroup.tab3;
	self.matchmakingText = tabContainer.matchmakingText;
	self.leaveButton = self.buttonContainer.leaveButton;
	self.requeueButton = self.buttonContainer.requeueButton;
	self.earningsContainer = self.content.earningsContainer;
	self.rewardsContainer = self.earningsContainer.rewardsContainer;
	self.rewardsHeader = self.rewardsContainer.header;
	self.itemContainer = self.rewardsContainer.items;
	self.progressContainer = self.earningsContainer.progressContainer;
	self.progressHeader = self.progressContainer.header;
	self.honorFrame = self.progressContainer.honor;
	self.honorText = self.honorFrame.text;
	self.honorButton = self.honorFrame.button;
	self.legacyHonorButton = self.honorFrame.legacyButton;
	self.conquestFrame = self.progressContainer.conquest;
	self.conquestText = self.conquestFrame.text;
	self.conquestButton = self.conquestFrame.button;
	self.legacyConquestButton = self.conquestFrame.legacyButton;
	self.ratingFrame = self.progressContainer.rating;
	self.ratingText = self.progressContainer.rating.text;
	self.ratingButton = self.progressContainer.rating.button;
	self.earningsArt = self.content.earningsArt;
	self.earningsBackground = self.earningsArt.background;
	self.tintFrames = {self.glowTop, self.earningsBackground, self.scrollFrame.background};
	self.progressFrames = {self.honorFrame, self.conquestFrame, self.ratingFrame};

	self.header:SetShadowOffset(1,-1);

	self.earningsContainer:Hide();
	self.progressHeader:SetText(PVP_PROGRESS_REWARDS_HEADER);
	self.rewardsHeader:SetText(PVP_ITEM_REWARDS_HEADER);

	self.legacyConquestButton:SetTooltipAnchor("ANCHOR_RIGHT");
	self.requeueButton:SetScript("OnClick", function() self:OnRequeueButtonClicked(self.requeueButton) end);
	self.requeueButton:SetText(PVP_QUEUE_AGAIN);
	
	self.leaveButton:SetScript("OnClick", function() self:OnLeaveButtonClicked(self.leaveButton) end);

	self.tab1:SetText(ALL);
	self.Tabs = {self.tab1, self.tab2, self.tab3};
	PanelTemplates_SetNumTabs(self, #self.Tabs);
	for k, tab in pairs(self.Tabs) do
		tab:SetScript("OnClick", function() self:OnTabGroupClicked(tab) end);
	end
	PanelTemplates_SetTab(self, 1);

	HybridScrollFrame_OnLoad(self.scrollFrame);
	HybridScrollFrame_CreateButtons(self.scrollFrame, "PVPTableRowTemplate");
	HybridScrollFrame_SetDoNotHideScrollBar(self.scrollFrame, true);

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-GenericMetal-ExitButtonBorder", -1, 1);

	self.itemPool = CreateFramePool("BUTTON", self.itemContainer, "PVPMatchResultsLoot");
	self.tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.scrollFrame));
	self.tableBuilder:SetHeaderContainer(self.scrollCategories);
end

function PVPMatchResultsMixin:Init()
	if self.isInitialized then
		return;
	end
	self.isInitialized = true;

	local winner = C_PvP.GetActiveMatchWinner();
	local factionIndex = GetBattlefieldArenaFaction();
	local enemyFactionIndex = (factionIndex+1)%2;
	local GetOutcomeText = function()
		if winner == factionIndex then
			return PVP_MATCH_VICTORY;
		elseif winner == enemyFactionIndex then
			return PVP_MATCH_DEFEAT;
		else
			return PVP_MATCH_DRAW;
		end
	end
	self.header:SetText(GetOutcomeText());

	-- Using reference text size before adding a margin sufficiently sized
	-- to allow space for the remaining time.
	self.leaveButton:SetText(PVP_MATCH_LEAVE_BUTTON);
	local baseWidth = self.leaveButton:GetFontString():GetStringWidth();
	local timeWidthMargin = 100;
	self.leaveButton:SetWidth(baseWidth + timeWidthMargin);

	self.UpdateLeaveButton = function()
		local shutdownTime = GetBattlefieldInstanceExpiration()/1000;
		if shutdownTime > 0 then
			local formattedTime = LeaveMatchFormatter:Format(shutdownTime);
			self.leaveButton:SetText(PVP_LEAVE_BUTTON_TIME:format(PVP_MATCH_LEAVE_BUTTON, formattedTime));
		else
			self.leaveButton:SetText(PVP_MATCH_LEAVE_BUTTON);
		end
	end;

	local isArenaSkirmish = IsArenaSkirmish();
	self.requeueButton:SetEnabled(isArenaSkirmish);
	self.requeueButton:SetShown(isArenaSkirmish);
	
	if isArenaSkirmish then
		self.leaveButton:SetPoint("LEFT", self.requeueButton, "RIGHT", 30, 0 );
	else
		self.leaveButton:SetPoint("LEFT", self.buttonContainer, "LEFT", 0, 0 );
	end
	self.buttonContainer:MarkDirty();

	local isFactionalMatch = C_PvP.IsMatchFactional();
	if isFactionalMatch then
		local teamInfos = { 
			C_PvP.GetTeamInfo(0),
			C_PvP.GetTeamInfo(1), 
		};
		self.tab2:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_ALLIANCE, teamInfos[2].size));
		self.tab3:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_HORDE, teamInfos[1].size));
		PanelTemplates_ResizeTabsToFit(self, 600);
	end
	self.tabGroup:SetShown(isFactionalMatch);

	PVPMatchUtil.UpdateMatchmakingText(self.matchmakingText);

	self:SetupArtwork(factionIndex, isFactionalMatch);

	ConstructPVPMatchTable(self.tableBuilder, not isFactionalMatch);
end
function PVPMatchResultsMixin:Shutdown()
	FrameUtil.UnregisterFrameForEvents(self, ACTIVE_EVENTS);
	self:UnregisterEvent("QUEST_LOG_UPDATE");
	self.isInitialized = false;
	self.hasRewardTimerElapsed = false;
	self.rewardTimer = false;
	self.haveConquestData = false;
	self.hasDisplayedRewards = false;
	self.earningsContainer:Hide();
	HideUIPanel(self);
end
function PVPMatchResultsMixin:OnEvent(event, ...)
	if event == "PVP_MATCH_ACTIVE" or (event == "PLAYER_ENTERING_WORLD" and C_PvP.GetActiveMatchState() ~= Enum.PvPMatchState.Inactive) then
		FrameUtil.RegisterFrameForEvents(self, ACTIVE_EVENTS);
	elseif event == "PLAYER_LEAVING_WORLD" then
		self:Shutdown();
	elseif event == "PVP_MATCH_COMPLETE" then
		if not C_Commentator.IsSpectating() then
		self:BeginShow();
		end
	elseif event == "TREASURE_PICKER_CACHE_FLUSH" then
		self.haveConquestData = self:HaveConquestData();
		if not haveConquestData then
			self:RegisterEvent("QUEST_LOG_UPDATE");
		end
	elseif event == "QUEST_LOG_UPDATE" then
		self.haveConquestData = self:HaveConquestData();
		if self.haveConquestData then
			self:UnregisterEvent("QUEST_LOG_UPDATE");
			self:DisplayRewards();
		end
	elseif event == "POST_MATCH_ITEM_REWARD_UPDATE" or event == "POST_MATCH_CURRENCY_REWARD_UPDATE" then
		if self.hasRewardTimerElapsed then
			-- 820FIXME We've received an item reward late. Reinitialize the reward section. This is a stopgap
			-- until we've included the full set of item details as part of the match complete message.
			self:DisplayRewards();
		end
	elseif event == "LFG_ROLE_CHECK_DECLINED" or event == "LFG_READY_CHECK_DECLINED" then
		self.requeueButton:Enable();
	elseif event == "LFG_ROLE_CHECK_SHOW" or event == "LFG_READY_CHECK_SHOW" then
		self.requeueButton:Disable();
	end
end
function PVPMatchResultsMixin:BeginShow()
	-- Get the conquest information if necessary. This will normally be cached
	-- at the beginning of the match, but this is to deal with any rare cases
	-- where the sparse item or treasure picker db's have been flushed on us.
	self.haveConquestData = self:HaveConquestData();
	if not self.haveConquestData then
		self:RegisterEvent("QUEST_LOG_UPDATE");
	end

	-- See POST_MATCH_ITEM_REWARD_UPDATE
	if not self.hasRewardTimerElapsed and not self.rewardTimer then
		self.rewardTimer = C_Timer.NewTimer(1.0, 
			function()
				self.rewardTimer = nil;
				self.hasRewardTimerElapsed = true;
				self:DisplayRewards();
			end
		);
	end

	self:Init();
	ShowUIPanel(self);
end
function PVPMatchResultsMixin:DisplayRewards()
	if self.hasDisplayedRewards or not self.hasRewardTimerElapsed then
		return;
	end

	local conquestQuestID = select(3, PVPGetConquestLevelInfo());
	if conquestQuestID ~= 0 and not self.haveConquestData then
		return;
	end
	self.hasDisplayedRewards = true;
	
	self.itemPool:ReleaseAll();

	for k, item in pairs(C_PvP.GetPostMatchItemRewards()) do
		-- Conquest is displayed in the progress section, so ignore it if found.
		if not (item.type == "currency" and C_CurrencyInfo.GetCurrencyIDFromLink(item.link) == Constants.CurrencyConsts.CONQUEST_CURRENCY_ID) then
			self:AddItemReward(item);
		end
	end

	for k, frame in pairs(self.progressFrames) do
		frame:Hide();
	end

	for k, currency in pairs(C_PvP.GetPostMatchCurrencyRewards()) do
		if currency.currencyType == Constants.CurrencyConsts.HONOR_CURRENCY_ID then
			self:InitHonorFrame(currency);
		elseif currency.currencyType == Constants.CurrencyConsts.CONQUEST_CURRENCY_ID then
			self:InitConquestFrame(currency);
		end
	end
	
	-- Skirmish is considered rated, ignore it.
	if C_PvP.IsRatedMap() and not IsArenaSkirmish() then
		self:InitRatingFrame();
	end

	local previousItemFrame;
	for itemFrame in self.itemPool:EnumerateActive() do
		if previousItemFrame then
			itemFrame:SetPoint("TOPLEFT", previousItemFrame, "TOPRIGHT", 17, 0);
		else
			itemFrame:SetPoint("TOPLEFT");
		end

		itemFrame:Show();
		previousItemFrame = itemFrame;
	end
	
	local showItems = previousItemFrame ~= nil;
	self.rewardsContainer:SetShown(showItems);

	-- Visibility of the progress elements can be mixed, but are expected to be in the order of
	-- honor, then conquest, then rating.
	local progressFramesShown = {};
	for k, frame in pairs(self.progressFrames) do
		if frame:IsShown() then
			tinsert(progressFramesShown, frame);
		end

		-- Want assurance that all points are cleared and cannot affect
		-- the result of the anchoring to follow.
		frame:ClearAllPoints();
	end

	local previousProgressFrame;
	for i, progressFrame in ipairs(progressFramesShown) do
		if previousProgressFrame then
			progressFrame:SetPoint("LEFT", previousProgressFrame, "RIGHT", 22, 0);
		else
			progressFrame:SetPoint("TOPLEFT", self.progressHeader, "BOTTOMLEFT", 3, -11);
		end

		progressFrame:MarkDirty();
		previousProgressFrame = progressFrame;
	end
	
	local showProgress = previousProgressFrame ~= nil;
	self.progressContainer:SetShown(showProgress);
	if showProgress then
		if previousItemFrame then
			-- Anchor the progress rewards container to the item rewards container if items are present present, otherwise,
			-- the progress rewards will be centered when arranged by the resize layout frame.
			self.progressContainer:SetPoint("TOPLEFT", self.rewardsContainer, "TOPRIGHT", 50, 0);
		else
			self.progressContainer:SetPoint("TOPLEFT");
		end
	end
	
	if showItems or showProgress then
		self.earningsContainer:Show();
		self.earningsContainer:MarkDirty();
		self.earningsContainer.FadeInAnim:Play();
		self.earningsArt.BurstBgAnim:Play();

		local AddDelayToAnimations = function(delay, ...)
			for animIndex = 1, select("#", ...) do
				local anim = select(animIndex, ...);
				if not anim.initialStartDelay then
					anim.initialStartDelay = anim:GetStartDelay() or 0;
				end
				anim:SetStartDelay(anim.initialStartDelay + delay);
			end
		end

		local itemStartDelay = .35;
		for itemFrame in self.itemPool:EnumerateActive() do
			local animGroup = itemFrame.IconAnim;
			AddDelayToAnimations(itemStartDelay, animGroup:GetAnimations());
			animGroup:Play();
		end
	end
end

-- If this function returns false, it also comes with the side-effect of assigning
-- a callback and signalling QUEST_LOG_UPDATE. Unfortunately, this function needs to be called
-- until it succeeds, which occurs after every QUEST_LOG_UPDATE event.
function PVPMatchResultsMixin:HaveConquestData()
	local conquestQuestID = select(3, PVPGetConquestLevelInfo());
	return HaveQuestRewardData(conquestQuestID);
end
function PVPMatchResultsMixin:OnUpdate()
	if self.UpdateLeaveButton then
		self:UpdateLeaveButton();
	end

	PVPMatchUtil.UpdateTable(self.tableBuilder, self.scrollFrame);
end
local scoreWidgetSetID = 249;
local function ScoreWidgetLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;
	local maxWidgetWidth = 1;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOPRIGHT", widgetContainer, "TOPRIGHT", 0, 0);
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOPRIGHT", relative, "BOTTOMRIGHT", 0, 0);
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetWidgetHeight();

		local widgetWidth = widgetFrame:GetWidgetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
	end

	widgetContainer:SetHeight(math.max(widgetsHeight, 1));
	widgetContainer:SetWidth(maxWidgetWidth);
end
function PVPMatchResultsMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	self.Score:RegisterForWidgetSet(scoreWidgetSetID, ScoreWidgetLayout);
end
function PVPMatchResultsMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	self.Score:UnregisterForWidgetSet(scoreWidgetSetID);
end
function PVPMatchResultsMixin:AddItemReward(item)
	local frame = self.itemPool:Acquire();

	local unusedSpecID;
	local isCurrency = item.type == "currency";
	local isIconBorderShown = true;
	local isIconBorderDropShadowShown = true;
	frame:Init(item.link, item.quantity, unusedSpecID, isCurrency, item.isUpgraded, isIconBorderShown, isIconBorderDropShadowShown);
	frame:SetScale(.7931);
end
function PVPMatchResultsMixin:InitHonorFrame(currency)
	local deltaString = FormatValueWithSign(math.floor(currency.quantityChanged));
	self.honorText:SetText(PVP_HONOR_CHANGE:format(deltaString));
	self.honorButton:Show();
	self.legacyHonorButton:Hide();
	self.honorFrame:Show();
end
function PVPMatchResultsMixin:InitConquestFrame(currency)
	local deltaString = FormatValueWithSign(math.floor(currency.quantityChanged / 100));
	self.conquestText:SetText(PVP_CONQUEST_CHANGE:format(deltaString));
	self.conquestButton:Show();
	self.legacyConquestButton:Hide();
	self.conquestFrame:Show();
end
function PVPMatchResultsMixin:InitRatingFrame()
	local localPlayerScoreInfo = C_PvP.GetScoreInfoByPlayerGuid(GetPlayerGuid());
	if localPlayerScoreInfo then
	local ratingChange = localPlayerScoreInfo.ratingChange;
	local rating = localPlayerScoreInfo.rating;
	self.ratingButton:Init(rating, ratingChange);

	local personalRatedInfo = C_PvP.GetPVPActiveMatchPersonalRatedInfo();
	if personalRatedInfo then
		local tierInfo = C_PvP.GetPvpTierInfo(personalRatedInfo.tier);
		self.ratingButton:Setup(tierInfo, ranking);
	end

	if ratingChange and ratingChange ~= 0 then
		local deltaString = FormatValueWithSign(ratingChange);
		self.ratingText:SetText(PVP_RATING_CHANGE:format(deltaString));
	else
		self.ratingText:SetText(PVP_RATING_UNCHANGED);
	end
	
	self.ratingFrame:Show();
	end
end
function PVPMatchResultsMixin:SetupArtwork(factionIndex, isFactionalMatch)
	local useAlternateColor = not isFactionalMatch;
	local buttons = HybridScrollFrame_GetButtons(self.scrollFrame);
	for k, button in pairs(buttons) do
		button:Init(useAlternateColor);
	end

	local r, g, b = PVPMatchStyle.GetTeamColor(factionIndex, useAlternateColor):GetRGB();
	for k, frame in pairs(self.tintFrames) do
		frame:SetVertexColor(r, g, b);
	end

	local themeDecoration = self.overlay.decorator;
	local theme;
	if isFactionalMatch then
		theme = PVPMatchStyle.GetFactionPanelThemeByIndex(factionIndex);
		themeDecoration:SetPoint("BOTTOM", self, "TOP", 0, theme.decoratorOffsetY);
		themeDecoration:SetAtlas(theme.decoratorTexture, true);
	else
		theme = PVPMatchStyle.GetNeutralPanelTheme();
	end

	themeDecoration:SetShown(isFactionalMatch);

	NineSliceUtil.ApplyLayoutByName(self, theme.nineSliceLayout);
end
function PVPMatchResultsMixin:OnLeaveButtonClicked(button)
	if IsInLFDBattlefield() then
		ConfirmOrLeaveLFGParty();
    else
		ConfirmOrLeaveBattlefield();
    end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end
function PVPMatchResultsMixin:OnRequeueButtonClicked(button)
	button:Disable();
    RequeueSkirmish();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end
function PVPMatchResultsMixin:OnTabGroupClicked(tab)
	PanelTemplates_SetTab(self, tab:GetID());
	SetBattlefieldScoreFaction(tab.factionEnum);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

PVPMatchResultsRatingMixin = {};
function PVPMatchResultsRatingMixin:Init(rating, ratingChange)
	self.rating = rating;
	self.ratingChange = ratingChange;
	self.ratingNew = rating + ratingChange;

	local teamInfos = { 
		C_PvP.GetTeamInfo(0),
		C_PvP.GetTeamInfo(1), 
	};
	local factionIndex = GetBattlefieldArenaFaction();
	self.friendlyMMR = BATTLEGROUND_YOUR_AVERAGE_RATING:format(teamInfos[factionIndex+1].ratingMMR);
	local enemyFactionIndex = (factionIndex+1)%2;
	self.enemyMMR = BATTLEGROUND_ENEMY_AVERAGE_RATING:format(teamInfos[enemyFactionIndex+1].ratingMMR);
end
function PVPMatchResultsRatingMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, PVP_RATING_HEADER);

	local ratingChange = self.ratingChange;
	if ratingChange and ratingChange ~= 0 then
		GameTooltip_AddNormalLine(GameTooltip, PVP_RATING_PREVIOUS:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(self.rating)));
		GameTooltip_AddNormalLine(GameTooltip, PVP_RATING_GAINED:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(FormatValueWithSign(ratingChange))));
		GameTooltip_AddNormalLine(GameTooltip, PVP_RATING_NEW:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(self.ratingNew)));
	else
		GameTooltip_AddNormalLine(GameTooltip, PVP_RATING_CURRENT:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(self.ratingNew)));
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, self.friendlyMMR);
	GameTooltip_AddNormalLine(GameTooltip, self.enemyMMR);
	
	GameTooltip:Show();
end
function PVPMatchResultsRatingMixin:OnLeave()
	GameTooltip:Hide();
end