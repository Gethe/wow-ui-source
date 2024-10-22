
TooltipConstants = {
	WrapText = true,
}

--[[ Optionals:
	headerText - string
	headerColor - color
	wrapHeaderText - bool
	atLeastShowAzerite - bool
	fullItemDescription - bool
	prioritizeCurrencyOverItem - bool
	showCollectionText - bool
--]]

TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_WORLD_QUEST = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	fullItemDescription = true,
	showCollectionText = true,
	showFirstTimeRepRewardNotice = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_NO_HEADER = {
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 0,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_CONTRIBUTION = {
	headerText = CONTRIBUTION_REWARD_TOOLTIP_TEXT,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	wrapHeaderText = false,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY = {
	headerText = PVP_BOUNTY_REWARD_TITLE,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = false,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_ISLANDS_QUEUE = {
	headerText = ISLAND_QUEUE_REWARD_FOR_WINNING,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	wrapHeaderText = false,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_EMISSARY_REWARD = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	atLeastShowAzerite = true,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_CALLING_REWARD = {
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	atLeastShowAzerite = true,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_PRIORITIZE_CURRENCY_OVER_ITEM = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	prioritizeCurrencyOverItem = true,
	atLeastShowAzerite = true,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_QUEST_CHOICE = {
	-- Doesn't include a header to allow individual player choice responses to set their own
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_NONE = {
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 0,
}

function GameTooltip_UnitColor(unit)
	local r, g, b;
	if ( UnitPlayerControlled(unit) ) then
		if ( UnitCanAttack(unit, "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", unit) ) then
				--[[
				r = 1.0;
				g = 0.5;
				b = 0.5;
				]]
				--[[
				r = 0.0;
				g = 0.0;
				b = 1.0;
				]]
				r = 1.0;
				g = 1.0;
				b = 1.0;
			else
				r = FACTION_BAR_COLORS[2].r;
				g = FACTION_BAR_COLORS[2].g;
				b = FACTION_BAR_COLORS[2].b;
			end
		elseif ( UnitCanAttack("player", unit) ) then
			-- Players we can attack but which are not hostile are yellow
			r = FACTION_BAR_COLORS[4].r;
			g = FACTION_BAR_COLORS[4].g;
			b = FACTION_BAR_COLORS[4].b;
		elseif ( UnitIsPVP(unit) ) then
			-- Players we can assist but are PvP flagged are green
			r = FACTION_BAR_COLORS[6].r;
			g = FACTION_BAR_COLORS[6].g;
			b = FACTION_BAR_COLORS[6].b;
		else
			-- All other players are blue (the usual state on the "blue" server)
			--[[
			r = 0.0;
			g = 0.0;
			b = 1.0;
			]]
			r = 1.0;
			g = 1.0;
			b = 1.0;
		end
	else
		local reaction = UnitReaction(unit, "player");
		if ( reaction ) then
			r = FACTION_BAR_COLORS[reaction].r;
			g = FACTION_BAR_COLORS[reaction].g;
			b = FACTION_BAR_COLORS[reaction].b;
		else
			--[[
			r = 0.0;
			g = 0.0;
			b = 1.0;
			]]
			r = 1.0;
			g = 1.0;
			b = 1.0;
		end
	end
	return r, g, b;
end

function GameTooltip_SetBasicTooltip(tooltip, text, x, y, wrap)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:ClearAllPoints();
	tooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y);
	local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB();
	tooltip:SetText(text, r, g, b, 1, wrap);
end

function GameTooltip_AddQuestRewardsToTooltip(tooltip, questID, style)
	style = style or TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT;

	if ( GetQuestLogRewardXP(questID) > 0 or C_QuestInfoSystem.HasQuestRewardCurrencies(questID) or GetNumQuestLogRewards(questID) > 0 or
		GetQuestLogRewardMoney(questID) > 0 or GetQuestLogRewardArtifactXP(questID) > 0 or GetQuestLogRewardHonor(questID) > 0 or
		C_QuestInfoSystem.HasQuestRewardSpells(questID)) then
		if tooltip.ItemTooltip then
			tooltip.ItemTooltip:Hide();
		end

		GameTooltip_AddBlankLinesToTooltip(tooltip, style.prefixBlankLineCount);
		if style.headerText and style.headerColor then
			GameTooltip_AddColoredLine(tooltip, style.headerText, style.headerColor, style.wrapHeaderText);
		end
		GameTooltip_AddBlankLinesToTooltip(tooltip, style.postHeaderBlankLineCount);

		local hasAnySingleLineRewards, showRetrievingData = QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style);

		if hasAnySingleLineRewards and tooltip.ItemTooltip and tooltip.ItemTooltip:IsShown() then
			GameTooltip_AddBlankLinesToTooltip(tooltip, 1);
			if showRetrievingData then
				GameTooltip_AddColoredLine(tooltip, RETRIEVING_DATA, RED_FONT_COLOR);
			end
		end

		GameTooltip_SetTooltipWaitingForData(tooltip, showRetrievingData);
	end
end

function GameTooltip_CheckAddQuestTimeToTooltip(tooltip, questID)
	if C_QuestLog.ShouldDisplayTimeRemaining(questID) then
		GameTooltip_AddQuestTimeToTooltip(tooltip, questID);
	end
end

function GameTooltip_AddQuestTimeToTooltip(tooltip, questID)
	local formattedTime, color, secondsRemaining = WorldMap_GetQuestTimeForTooltip(questID);
	if formattedTime and color then
		formattedTime = color:WrapTextInColorCode(formattedTime);
		GameTooltip_AddNormalLine(tooltip, MAP_TOOLTIP_TIME_LEFT:format(formattedTime));
	end
end

function GameTooltip_CalculatePadding(tooltip)
	local itemWidth, itemHeight, bottomFontStringWidth, bottomFontStringHeight = 0, 0, 0, 0;

	local itemTooltip = tooltip.ItemTooltip;
	local isItemTooltipShown = itemTooltip and itemTooltip:IsShown();
	local isBottomFontStringShown = tooltip.BottomFontString and tooltip.BottomFontString:IsShown();

	if not isItemTooltipShown and not isBottomFontStringShown then
		if tooltip.SetPadding then
			tooltip:SetPadding(0, 0, 0, 0);
		end
		return;
	end

	if isBottomFontStringShown then
		bottomFontStringWidth, bottomFontStringHeight = tooltip.BottomFontString:GetSize();
		bottomFontStringHeight = bottomFontStringHeight + 7;
		bottomFontStringWidth = bottomFontStringWidth + 20; -- extra width padding for this line
	end

	if itemTooltip then
		if isItemTooltipShown then
			itemWidth, itemHeight = itemTooltip:GetSize();
			itemWidth = itemWidth + 9; -- extra padding for this line
		end

		if isBottomFontStringShown then
			itemTooltip:SetPoint("BOTTOMLEFT", tooltip.BottomFontString, "TOPLEFT", 0, 10);
		else
			itemTooltip:SetPoint("BOTTOMLEFT", 10, 13);
		end
	end

	if tooltip:GetObjectType() ~= "GameTooltip" then
		-- This means that an InternalEmbeddedItemTooltipTemplate was placed inside a frame that is not a Tooltip
		-- Everything below here is only relevant for tooltips
		return;
	end

	local extraWidth = math.max(itemWidth, bottomFontStringWidth);
	local extraHeight = itemHeight + bottomFontStringHeight;

	local oldPaddingWidth, oldPaddingHeight = tooltip:GetPadding();
	local actualTooltipWidth = tooltip:GetWidth() - oldPaddingWidth;
	local paddingWidth = (actualTooltipWidth <= extraWidth) and extraWidth - actualTooltipWidth or 0;

	local paddingHeight = 0;
	if extraHeight > 0 then
		paddingHeight = extraHeight + 5;
	end

	if (math.abs(paddingWidth - oldPaddingWidth) > 0.5) or (math.abs(paddingHeight - oldPaddingHeight) > 0.5) then
		--if tooltip:IsRectValid() then
			tooltip:SetPadding(paddingWidth, paddingHeight, 0, 0);
		--end
	end
end

function GameTooltip_SetBottomText(self, text, lineColor)
	if self.BottomFontString then
		self.BottomFontString:Show();
		self.BottomFontString:SetText(text);
		self.BottomFontString:SetVertexColor(lineColor:GetRGBA());
	end
end

function GameTooltip_OnLoad(self)
	SharedTooltip_OnLoad(self);
	self.updateTooltipTimer = TOOLTIP_UPDATE_TIME;

	if self.supportsDataRefresh then
		self:RegisterEvent("TOOLTIP_DATA_UPDATE");
	end
end

function GameTooltip_OnTooltipAddMoney(self, cost, maxcost)
	if( not maxcost or maxcost < 1 ) then --We just have 1 price to display
		SetTooltipMoney(self, cost, nil, string.format("%s:", SELL_PRICE));
	else
		GameTooltip_AddColoredLine(self, ("%s:"):format(SELL_PRICE), HIGHLIGHT_FONT_COLOR);
		local indent = string.rep(" ",4)
		SetTooltipMoney(self, cost, nil, string.format("%s%s:", indent, MINIMUM));
		SetTooltipMoney(self, maxcost, nil, string.format("%s%s:", indent, MAXIMUM));
	end
end

GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT_DARK = {
	layoutType = "TooltipDefaultDarkLayout",
};

GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM = {
	layoutType = "TooltipAzeriteLayout",

	overlayAtlasTop = "AzeriteTooltip-Topper",
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = 1,
	overlayAtlasBottom = "AzeriteTooltip-Bottom",
	overlayAtlasBottomYOffset = 2,

	padding = { left = 6, right = 6, top = 6, bottom = 6 },
};

GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM = {
	layoutType = "TooltipCorruptedLayout",

	overlayAtlasTop = "Nzoth-tooltip-topper",
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = -2,

	padding = { left = 6, right = 6, top = 6, bottom = 6 },
};

GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY = {
	layoutType = "TooltipMawLayout",

	overlayAtlasTop = "Maw-tooltip-topper",
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = -2,

	padding = { left = 6, right = 6, top = 6, bottom = 6 },
};

GAME_TOOLTIP_BACKDROP_STYLE_CLASS_TALENT = {
	layoutType = "TooltipDefaultDarkLayout",
};

GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES = {
	["jailerstower"] = GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY;
};

function GameTooltip_OnShow(self)
	-- Do not show HUD tooltips when in edit mode with the HUD tooltip section enabled, to prevent layering issues.
	if (EditModeManagerFrame and GameTooltipDefaultContainer and EditModeManagerFrame:IsEditModeActive() and GameTooltipDefaultContainer:IsShown()) then
		local relativeTo = select(2, self:GetPoint());
		if (relativeTo == GameTooltipDefaultContainer) then
			self:Hide();
			return;
		end
	end

	GameTooltip_CalculatePadding(self);
end

function GameTooltip_OnHide(self)
	self.waitingForData = false;
	local style = nil;
	SharedTooltip_SetBackdropStyle(self, style, self.IsEmbedded);
	GameTooltip_ClearMoney(self);
	GameTooltip_ClearStatusBars(self);
	GameTooltip_ClearProgressBars(self);
	GameTooltip_ClearWidgetSet(self);
	TooltipComparisonManager:Clear(self);

	GameTooltip_HideBattlePetTooltip();

	if self.ItemTooltip then
		EmbeddedItemTooltip_Hide(self.ItemTooltip);
	end
	self:SetPadding(0, 0, 0, 0);

	self:ClearHandlerInfo();

	GameTooltip_ClearStatusBars(self);
	GameTooltip_ClearStatusBarWatch(self);

	EventRegistry:TriggerEvent("GameTooltip.HideTooltip", self);
end

function GameTooltip_CycleSecondaryComparedItem(self)
	TooltipComparisonManager:CycleItem();
end

function GameTooltip_SetTooltipWaitingForData(self, waitingForData)
	if self.waitingForData and not waitingForData then
		self.updateTooltipTimer = 0;
	end

	self.waitingForData = waitingForData;
end

function GameTooltip_IsUpdateNeeded(self, elapsed)
	self.updateTooltipTimer = self.updateTooltipTimer - elapsed;
	if self.updateTooltipTimer > 0 then
		return false;
	end

	self.updateTooltipTimer = TOOLTIP_UPDATE_TIME;
	return true;
end

function GameTooltip_OnUpdate(self, elapsed)
	if not GameTooltip_IsUpdateNeeded(self, elapsed) then
		return;
	end

	local owner = self:GetOwner();
	if ( owner and owner.UpdateTooltip ) then
		owner:UpdateTooltip();
	elseif self.UpdateTooltip then
		self:UpdateTooltip();
	elseif self.shouldRefreshData then
		self:RefreshData();
	end
end

function GameTooltip_HideBattlePetTooltip()
	if BattlePetTooltip then
		BattlePetTooltip:Hide();
	end
end

function GameTooltip_HideShoppingTooltips(self)
	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);
	shoppingTooltip1:Hide();
	shoppingTooltip2:Hide()
end

function GameTooltip_ClearStyle(self)
	local backdropStyle = nil;
	SharedTooltip_SetBackdropStyle(self, backdropStyle);
end

function GameTooltip_ShowCompareItem(self, anchorFrame)
	local tooltip = self or GameTooltip;
	local tooltipData = tooltip:GetPrimaryTooltipData();
	local comparisonItem = TooltipComparisonManager:CreateComparisonItem(tooltipData);
	TooltipComparisonManager:CompareItem(comparisonItem, tooltip, anchorFrame);
end

function GameTooltip_ShowEventHyperlink(hyperlink)
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetHyperlink(hyperlink);
end

function GameTooltip_HideEventHyperlink()
	if GameTooltip.tooltipData and GameTooltip.tooltipData.getterName == "GetHyperlink" then
		GameTooltip:Hide();
	end
end

function GameTooltip_ClearStatusBars(self)
	if self.statusBarPool then
		self.statusBarPool:ReleaseAll();
	end
end

function GameTooltip_ClearStatusBarWatch(self)
	if self.StatusBar then
		self.StatusBar:ClearWatch();
	end
end

function GameTooltip_ClearAllStatusBars(self)
	GameTooltip_ClearStatusBars(self);
	GameTooltip_ClearStatusBarWatch(self);
end

function GameTooltip_ShowStatusBar(self, min, max, value, text)
	if not self.statusBarPool then
		self.statusBarPool = CreateFramePool("STATUSBAR", self, "TooltipStatusBarTemplate");
	else
		GameTooltip_ClearStatusBars(self);
	end
	GameTooltip_AddStatusBar(self, min, max, value, text);
end

function GameTooltip_AddStatusBar(self, min, max, value, text)
	GameTooltip_AddBlankLinesToTooltip(self, 1);
	local numLines = self:NumLines();
	local statusBar = self.statusBarPool:Acquire();
	if ( not text ) then
		text = "";
	end
	statusBar.Text:SetText(text);
	statusBar:SetMinMaxValues(min, max);
	statusBar:SetValue(value);
	statusBar:Show();
	statusBar:SetPoint("LEFT", self:GetName().."TextLeft"..numLines, "LEFT", 0, -2);
	statusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0);
	statusBar:Show();
	self:SetMinimumWidth(140);
end

function GameTooltip_ClearProgressBars(self)
	if self.progressBarPool then
		self.progressBarPool:ReleaseAll();
	end
end

function GameTooltip_ShowProgressBar(self, min, max, value, text)
	if not self.progressBarPool then
		self.progressBarPool = CreateFramePool("FRAME", self, "TooltipProgressBarTemplate");
	else
		GameTooltip_ClearProgressBars(self);
	end
	GameTooltip_AddProgressBar(self, min, max, value, text);
end

function GameTooltip_AddProgressBar(self, min, max, value, text)
	local progressBar = self.progressBarPool:Acquire();
	progressBar.Bar.Label:SetText(text);
	progressBar.Bar:SetMinMaxValues(min, max);
	progressBar.Bar:SetValue(value);
	progressBar:SetAlpha(1);
	GameTooltip_InsertFrame(self, progressBar);
end

function GameTooltip_ShowHyperlink(self, hyperlinkString, classID, specID, clearTooltip)
	local questRewardID = ExtractQuestRewardID(hyperlinkString);
	if questRewardID then
		-- quest reward hyperlinks are handled in lua
		GameTooltip_AddQuestRewardsToTooltip(self, questRewardID, TOOLTIP_QUEST_REWARDS_STYLE_NO_HEADER);
	else
		local tooltipInfo = CreateBaseTooltipInfo("GetHyperlink", hyperlinkString, classID, specID);
		tooltipInfo.append = not clearTooltip;
		self:ProcessInfo(tooltipInfo);
	end
end

local function WidgetLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);
	widgetContainer.shownWidgetCount = #sortedWidgets;
end

function GameTooltip_AddWidgetSet(self, widgetSetID, verticalPadding)
	if not widgetSetID then
		return;
	end

	if not self.widgetContainer then
		self.widgetContainer = CreateFrame("FRAME", nil, self, "UIWidgetContainerTemplate");
		self.widgetContainer.verticalAnchorPoint = "TOPLEFT";
		self.widgetContainer.verticalRelativePoint = "BOTTOMLEFT";
		self.widgetContainer.showAndHideOnWidgetSetRegistration = false;
		self.widgetContainer.disableWidgetTooltips = true;
		self.widgetContainer:Hide();
	end

	self.widgetContainer:RegisterForWidgetSet(widgetSetID, WidgetLayout);

	if self.widgetContainer.shownWidgetCount > 0 then
		local heightUsed = GameTooltip_InsertFrame(self, self.widgetContainer, verticalPadding);
		-- overflow
		local widgetHeight = self.widgetContainer:GetHeight() + (verticalPadding or 0);
		return heightUsed - widgetHeight;
	end
end

function GameTooltip_ClearWidgetSet(self)
	if self.widgetContainer then
		self.widgetContainer:UnregisterForWidgetSet();
	end
end

function GameTooltip_Hide()
	-- Used for XML OnLeave handlers
	GameTooltip:Hide();
	GameTooltip_HideBattlePetTooltip();
end

function GameTooltip_HideResetCursor()
	GameTooltip:Hide();
	ResetCursor();
end

local function AddFloorLocationLine(tooltip, floorLocation, aboveString, belowString)
	if floorLocation == Enum.QuestLineFloorLocation.Below then
		tooltip:AddLine(belowString, 0.5, 0.5, 0.5, true);
	elseif floorLocation == Enum.QuestLineFloorLocation.Above then
		tooltip:AddLine(aboveString, 0.5, 0.5, 0.5, true);
	end
end

function GameTooltip_AddQuest(self, questIDArg)
	local questID = self.questID or questIDArg;
	if ( not HaveQuestData(questID) ) then
		GameTooltip_SetTitle(GameTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
		GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
		GameTooltip:Show();
		return;
	end

	local widgetSetAdded = false;
	local widgetSetID = C_TaskQuest.GetQuestTooltipUIWidgetSet(questID);
	local isThreat = C_QuestLog.IsThreatQuest(questID);

	local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(questID);
	title = title or self.questName;
	if self.worldQuest or C_QuestLog.IsWorldQuest(questID) then
		self.worldQuest = true;
		local tagInfo = C_QuestLog.GetQuestTagInfo(self.questID);
		local quality = tagInfo and tagInfo.quality or Enum.WorldQuestQuality.Common;
		local color = WORLD_QUEST_QUALITY_COLORS[quality].color;
		GameTooltip_SetTitle(GameTooltip, title, color);

		if C_QuestLog.IsAccountQuest(questID) then
			GameTooltip_AddColoredLine(GameTooltip, ACCOUNT_QUEST_LABEL, ACCOUNT_WIDE_FONT_COLOR);
		end

		QuestUtils_AddQuestTypeToTooltip(GameTooltip, questID, NORMAL_FONT_COLOR);

		local factionData = factionID and C_Reputation.GetFactionDataByID(factionID);
		if factionData then
			local questAwardsReputationWithFaction = C_QuestLog.DoesQuestAwardReputationWithFaction(questID, factionID);
			local reputationYieldsRewards = (not capped) or C_Reputation.IsFactionParagon(factionID);
			if questAwardsReputationWithFaction and reputationYieldsRewards then
				GameTooltip:AddLine(factionData.name);
			else
				GameTooltip:AddLine(factionData.name, GRAY_FONT_COLOR:GetRGB());
			end
		end

		GameTooltip_AddQuestTimeToTooltip(GameTooltip, questID);
	elseif isThreat then
		GameTooltip_SetTitle(GameTooltip, title);
		GameTooltip_AddQuestTimeToTooltip(GameTooltip, questID);
	else
		GameTooltip_SetTitle(GameTooltip, title, NORMAL_FONT_COLOR);
	end

	if self.isCombatAllyQuest or (C_QuestLog.GetQuestType(questID) == Enum.QuestTag.CombatAlly) then
		GameTooltip_AddColoredLine(GameTooltip, AVAILABLE_FOLLOWER_QUEST, HIGHLIGHT_FONT_COLOR, true);
		GameTooltip_AddColoredLine(GameTooltip, GRANTS_FOLLOWER_XP, GREEN_FONT_COLOR, true);
	elseif self.isQuestStart then
		GameTooltip_AddColoredLine(GameTooltip, AVAILABLE_QUEST, HIGHLIGHT_FONT_COLOR, true);
		AddFloorLocationLine(GameTooltip, self.floorLocation, QUESTLINE_LOCATED_ABOVE, QUESTLINE_LOCATED_BELOW);
	else
		local questDescription = "";
		local questCompleted = C_QuestLog.IsComplete(questID);

		if questCompleted and self.shouldShowObjectivesAsStatusBar then
			questDescription = QUEST_WATCH_QUEST_READY;
			GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. questDescription, HIGHLIGHT_FONT_COLOR);
		elseif not questCompleted and self.shouldShowObjectivesAsStatusBar then
			local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
			if questLogIndex then
				questDescription = select(2, GetQuestLogQuestText(questLogIndex));
				GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. questDescription, HIGHLIGHT_FONT_COLOR);
			end
		end
		local numObjectives = self.numbObjectives or C_QuestLog.GetNumQuestObjectives(questID);
		for objectiveIndex = 1, numObjectives do
			local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, objectiveIndex, false);
			local showObjective = not (finished and isThreat);
			if showObjective then
				if self.shouldShowObjectivesAsStatusBar then
					local percent = math.floor((numFulfilled/numRequired) * 100);
					GameTooltip_ShowProgressBar(GameTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));
				elseif objectiveText and (#objectiveText > 0) then
					local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
					GameTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
				end
			end
		end
		local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, 1, false);
		if objectiveType == "progressbar" then
			local percent = C_TaskQuest.GetQuestProgressBarInfo(questID);
			local showObjective = not (finished and isThreat);
			if percent  and showObjective then
				GameTooltip_ShowProgressBar(GameTooltip, 0, 100, percent, PERCENTAGE_STRING:format(percent));
			end
		end

		if widgetSetID then
			widgetSetAdded = true;
			GameTooltip_AddWidgetSet(GameTooltip, widgetSetID);
		end

		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, self.questRewardTooltipStyle or TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT);

		if self.worldQuest and C_TooltipInfo.GM then
			local tooltipData = C_TooltipInfo.GM.GetDebugWorldQuestInfo(questID);
			if tooltipData then
				local tooltipInfo = { tooltipData = tooltipData, append = true };
				GameTooltip:ProcessInfo(tooltipInfo);
				GameTooltip:Show();
			end
		end
	end


	if not widgetSetAdded and widgetSetID then
		GameTooltip_AddWidgetSet(GameTooltip, widgetSetID);
	end

	GameTooltip:Show();
end

function EmbeddedItemTooltip_UpdateSize(self)
	local itemTooltipExtraBorderHeight = 22;
	if ( self.Tooltip:IsShown() ) then
		local width = self.Tooltip:GetWidth() + self.Icon:GetWidth();
		local height = math.max(self.Tooltip:GetHeight() - itemTooltipExtraBorderHeight, self.Icon:GetHeight());
		self:SetSize(width, height);
	elseif ( self.FollowerTooltip:IsShown() ) then
		self:SetSize(self.FollowerTooltip:GetSize());
	end

	GameTooltip_CalculatePadding(self:GetParent());
end

function EmbeddedItemTooltip_Hide(self)
	self:Hide();
	GameTooltip_CalculatePadding(self:GetParent());
end

function EmbeddedItemTooltip_Clear(self)
	self.Icon:Hide();
	self.IconBorder:Hide();
	self.Tooltip:Hide();
	self.FollowerTooltip:Hide();
end

function EmbeddedItemTooltip_PrepareForItem(self)
	EmbeddedItemTooltip_Clear(self);
	self.Icon:Show();
	self.IconBorder:Show();
	self.Tooltip:Show();
end

function EmbeddedItemTooltip_PrepareForSpell(self)
	EmbeddedItemTooltip_Clear(self);
	self.Icon:Show();
	self.Tooltip:Show();
end

function EmbeddedItemTooltip_PrepareForFollower(self)
	EmbeddedItemTooltip_Clear(self);
	self.FollowerTooltip:Show();
end

function EmbeddedItemTooltip_SetItemByID(self, id, count)
	self.itemID = id;
	self.spellID = nil;
	local itemName, _, quality, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(id);
	self:Show();
	EmbeddedItemTooltip_PrepareForItem(self);
	self.Tooltip:SetOwner(self, "ANCHOR_NONE");
	self.Tooltip:SetItemByID(id);
	SetItemButtonQuality(self, quality, id);
	SetItemButtonCount(self, count or 1);
	self.Icon:SetTexture(itemTexture);
	self.itemTextureSet = (itemTexture ~= nil);
	self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
	EmbeddedItemTooltip_UpdateSize(self);
end

function EmbeddedItemTooltip_SetItemByQuestReward(self, questLogIndex, questID, rewardType, showCollectionText)
	if not questLogIndex then
		return false;
	end

	rewardType = rewardType or "reward";
	local getterFunc;
	if rewardType == "choice" then
		getterFunc = GetQuestLogChoiceInfo;
	else
		getterFunc = GetQuestLogRewardInfo;
	end

	local itemName, itemTexture, quantity, quality, isUsable, itemID = getterFunc(questLogIndex, questID);
	if itemName and itemTexture then
		self.itemID = itemID;
		self.spellID = nil;

		self:Show();
		EmbeddedItemTooltip_PrepareForItem(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetQuestLogItem(rewardType, questLogIndex, questID, showCollectionText);
		SetItemButtonQuality(self, quality, itemID);
		SetItemButtonCount(self, quantity);
		self.Icon:SetTexture(itemTexture);
		self.itemTextureSet = (itemTexture ~= nil);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
		EmbeddedItemTooltip_UpdateSize(self);

		return true;
	end
	return false;
end

function EmbeddedItemTooltip_SetSpellByFirstQuestReward(self, questID)
	local spells = C_QuestInfoSystem.GetQuestRewardSpells(questID);
	if spells and spells[1] then
		return EmbeddedItemTooltip_SetSpellByQuestReward(self, spells[1], questID);
	end

	return false;
end

function EmbeddedItemTooltip_SetSpellByQuestReward(self, spellID, questID)
	local spellInfo = C_QuestInfoSystem.GetQuestRewardSpellInfo(questID, spellID);
	if not spellInfo then
		return false;
	end

	if spellInfo.garrFollowerID then
		self:Show();
		EmbeddedItemTooltip_PrepareForFollower(self);
		local data = GarrisonFollowerTooltipTemplate_BuildDefaultDataForID(spellInfo.garrFollowerID);
		GarrisonFollowerTooltipTemplate_SetGarrisonFollower(self.FollowerTooltip, data);
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	elseif spellInfo.name and spellInfo.texture then
		self.itemID = nil;
		self.spellID = spellID;

		self:Show();
		EmbeddedItemTooltip_PrepareForSpell(self);

		local isPet = nil;
		local showSubtext = true;
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetSpellByID(spellID, isPet, showSubtext);

		SetItemButtonQuality(self, Enum.ItemQuality.Common);
		SetItemButtonCount(self, 0);
		self.Icon:SetTexture(spellInfo.texture);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	end
	return false;
end

function EmbeddedItemTooltip_SetSpellWithTextureByID(self, spellID, texture)
	if texture then
		self.itemID = nil;
		self.spellID = spellID;

		self:Show();
		EmbeddedItemTooltip_PrepareForSpell(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		local tooltipInfo = CreateBaseTooltipInfo("GetSpellByID", spellID);
		self.Tooltip:ProcessInfo(tooltipInfo);
		SetItemButtonQuality(self, Enum.ItemQuality.Common);
		SetItemButtonCount(self, 0);
		self.Icon:SetTexture(texture);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	end
	return false;
end

function EmbeddedItemTooltip_SetCurrencyByID(self, currencyID, quantity)
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	local name = currencyInfo.name;
	local texture = currencyInfo.iconFileID;
	local quality = currencyInfo.quality;
	if name and texture then
		self.itemID = nil;
		self.spellID = nil;
		self.itemTextureSet = false;
		EmbeddedItemTooltip_PrepareForItem(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);

		local displayQuantity;
		name, texture, displayQuantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, name, texture, quality);
		self.Tooltip:SetCurrencyByID(currencyID, quantity);
		SetItemButtonQuality(self, quality, currencyID);
		self.Icon:SetTexture(texture);
		SetItemButtonCount(self, displayQuantity);

		self:Show();
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	end
	return false;
end

GameTooltipDataMixin = CreateFromMixins(TooltipDataHandlerMixin);

function GameTooltipDataMixin:OnLoad()
	GameTooltip_OnLoad(self);
	self.shoppingTooltips = { ShoppingTooltip1, ShoppingTooltip2 };
	GameTooltip_HideBattlePetTooltip();
end

function GameTooltipDataMixin:RefreshData()
	self.shouldRefreshData = false;
	self:RebuildFromTooltipInfo();
end

function GameTooltipDataMixin:RefreshDataNextUpdate()
	self.updateTooltipTimer = 0;
	self.shouldRefreshData = true;
end

function GameTooltipDataMixin:OnEvent(event, ...)
	if event == "TOOLTIP_DATA_UPDATE" then
		local dataInstanceID = ...;
		if not dataInstanceID or self:HasDataInstanceID(dataInstanceID) then
			self:RefreshDataNextUpdate();
		end
	end
end

function GameTooltipDataMixin:SetWorldCursor(anchorType)
	if anchorType == Enum.WorldCursorAnchorType.Default then
		GameTooltip_SetDefaultAnchor(self, UIParent);
	elseif anchorType == Enum.WorldCursorAnchorType.Cursor then
		self:SetOwner(UIParent, "ANCHOR_CURSOR");
	elseif anchorType == Enum.WorldCursorAnchorType.Nameplate then
		self:SetOwner(UIParent, "ANCHOR_NONE");
		self:SetObjectTooltipPosition();
	end

	local oldInfo = self:GetPrimaryTooltipInfo();
	local tooltipData = C_TooltipInfo.GetWorldCursor();
	if tooltipData then
		local tooltipInfo = {
			getterName = "GetWorldCursor",
			tooltipData = tooltipData,
			fadeOut = anchorType == Enum.WorldCursorAnchorType.Default,
		};
		self:ProcessInfo(tooltipInfo);
	elseif oldInfo and oldInfo.getterName == "GetWorldCursor" then
		-- user just moused off an in-world object, either fade or hide
		if oldInfo.fadeOut then
			-- clear the info so we don't touch this tooltip again
			self:ClearHandlerInfo();
			self:FadeOut();
		else
			self:Hide();
		end
	end
end

-- Temp replacements for GetX API that's been removed
-- TODO: Evaluate for removal

function GameTooltipDataMixin:GetItem()
	return TooltipUtil.GetDisplayedItem(self);
end

function GameTooltipDataMixin:GetSpell()
	return TooltipUtil.GetDisplayedSpell(self);
end

function GameTooltipDataMixin:GetUnit()
	return TooltipUtil.GetDisplayedUnit(self);
end

GameTooltipUnitHealthBarMixin = { };

function GameTooltipUnitHealthBarMixin:OnLoad()
	self:SetMinMaxValues(0, 1);
end

function GameTooltipUnitHealthBarMixin:SetWatch(guid)
	self.guid = guid;
	self:SetValue(0);
	self:Show();
	self:UpdateUnitHealth();
end

function GameTooltipUnitHealthBarMixin:StopUpdates()
	-- get the current health, last update might have been right before killing blow
	self:UpdateUnitHealth();

	self.guid = nil;
end

function GameTooltipUnitHealthBarMixin:ClearWatch()
	self:StopUpdates();
	self:Hide();
end

function GameTooltipUnitHealthBarMixin:UpdateUnitHealth()
	if not self.guid then
		return;
	end

	local percentHealth = UnitPercentHealthFromGUID(self.guid);
	if percentHealth then
		self:SetValue(percentHealth);
	end
end

function GameTooltipUnitHealthBarMixin:OnUpdate()
	self:UpdateUnitHealth();
end
