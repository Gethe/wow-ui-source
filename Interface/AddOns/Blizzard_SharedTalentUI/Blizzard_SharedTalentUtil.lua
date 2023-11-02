
local TemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "TalentButtonSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "TalentButtonCircleTemplate",
};

local LargeTemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "TalentButtonLargeSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "TalentButtonLargeCircleTemplate",
};

local TemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeStraightTemplate",
};


TalentUtil = {}

function TalentUtil.IsFriendlyCondition(condType)
	return condType == Enum.TraitConditionType.Granted or condType == Enum.TraitConditionType.Increased;
end

function TalentUtil.CombineCostArrays(...)
	local combinedCostMap = {};
	for i = 1, select("#", ...) do
		local costArray = select(i, ...);
		for j, cost in ipairs(costArray) do
			combinedCostMap[cost.ID] = (combinedCostMap[cost.ID] or 0) + cost.amount;
		end
	end

	local combinedCostArray = {};
	for ID, amount in pairs(combinedCostMap) do
		-- Note: This must match the definition of TraitCurrencyCost, from C_Traits.GetNodeCost, etc.
		table.insert(combinedCostArray, { ID = ID, amount = amount, });
	end

	return combinedCostArray;
end

function TalentUtil.GetTalentNameFromInfo(definitionInfo)
	return TalentUtil.GetTalentName(definitionInfo.overrideName, definitionInfo.spellID);
end

function TalentUtil.GetTalentName(overrideName, spellID)
	if overrideName then
		return overrideName;
	end

	if spellID then
		local spellName = GetSpellInfo(spellID);
		if spellName then
			return spellName;
		end
	end

	return "";
end

function TalentUtil.GetTalentSubtextFromInfo(definitionInfo)
	return TalentUtil.GetTalentSubtext(definitionInfo.overrideSubtext, definitionInfo.spellID);
end

function TalentUtil.GetTalentSubtext(overrideSubtext, spellID)
	if overrideSubtext then
		return overrideSubtext;
	end

	if spellID then
		local spellSubtext = GetSpellSubtext(spellID);
		if spellSubtext then
			return spellSubtext;
		end
	end

	return nil;
end

function TalentUtil.GetTalentDescriptionFromInfo(definitionInfo)
	return TalentUtil.GetTalentDescription(definitionInfo.overrideDescription, definitionInfo.spellID);
end

function TalentUtil.GetTalentDescription(overrideDescription, spellID)
	if overrideDescription then
		return overrideDescription;
	end

	if spellID then
		local spellDescription = GetSpellDescription(spellID);
		if spellDescription then
			return spellDescription;
		end
	end

	return "";
end

function TalentUtil.GetReplacesSpellNameFromInfo(definitionInfo)
	if definitionInfo and definitionInfo.overriddenSpellID then
		local overriddenSpellID = C_SpellBook.GetOverrideSpell(definitionInfo.overriddenSpellID);
		local overriddenSpellName = GetSpellInfo(overriddenSpellID);
		if overriddenSpellName then
			return overriddenSpellName;
		end
	end

	return "";
end

TalentButtonUtil = {};

TalentButtonUtil.CircleEdgeDiameterOffset = 1.2;
TalentButtonUtil.SquareEdgeMinDiameterOffset = 1.2;
TalentButtonUtil.SquareEdgeMaxDiameterOffset = 1.5;
TalentButtonUtil.ChoiceEdgeMinDiameterOffset = 1.2;
TalentButtonUtil.ChoiceEdgeMaxDiameterOffset = 1.5;

TalentButtonUtil.BaseVisualState = {
	Normal = 1,
	Gated = 2,
	Disabled = 3,
	Locked = 4,
	Selectable = 5,
	Maxed = 6,
	Invisible = 7,
	RefundInvalid = 8,
};

local HoverAlphaByVisualState = {
	[TalentButtonUtil.BaseVisualState.Normal] = 1,
	[TalentButtonUtil.BaseVisualState.Gated] = 0.4,
	[TalentButtonUtil.BaseVisualState.Disabled] = 0.4,
	[TalentButtonUtil.BaseVisualState.Locked] = 0.4,
	[TalentButtonUtil.BaseVisualState.Selectable] = 1,
	[TalentButtonUtil.BaseVisualState.Maxed] = 1,
	[TalentButtonUtil.BaseVisualState.Invisible] = 0,
	[TalentButtonUtil.BaseVisualState.RefundInvalid] = 0.4,
};

function TalentButtonUtil.GetTemplateForTalentType(nodeInfo, talentType, useLarge)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return "TalentButtonChoiceTemplate";
		end
	end

	if useLarge then
		return LargeTemplatesByTalentType[talentType] or "TalentButtonLargeCircleTemplate";
	end

	-- Anything without a specific shared template will be a circle for now.
	return TemplatesByTalentType[talentType] or "TalentButtonCircleTemplate";
end

function TalentButtonUtil.GetSpecializedMixin(nodeInfo, talentType)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return TalentButtonSplitSelectMixin;
		else
			return TalentButtonSelectMixin;
		end
	end

	return TalentButtonSpendMixin;
end

function TalentButtonUtil.GetTemplateForEdgeVisualStyle(visualStyle)
	return TemplatesByEdgeVisualStyle[visualStyle];
end

function TalentButtonUtil.ApplyPosition(button, talentFrame, posX, posY)
	local point, relativeTo, relativePoint = button:GetPoint();
	local panOffsetX, panOffsetY = talentFrame:GetPanOffset();
	local newX = (posX / 10) - panOffsetX;
	local newY = (-posY / 10) + panOffsetY;
	button:SetPoint(point, relativeTo, relativePoint, newX, newY);
end

function TalentButtonUtil.GetColorForBaseVisualState(visualState)
	if (visualState == TalentButtonUtil.BaseVisualState.Gated) or (visualState == TalentButtonUtil.BaseVisualState.Disabled) or (visualState == TalentButtonUtil.BaseVisualState.Locked) then
		return DISABLED_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.Selectable then
		return GREEN_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.RefundInvalid then
		return RED_FONT_COLOR;
	end

	-- visualState == TalentButtonUtil.BaseVisualState.Maxed or
	-- visualState == TalentButtonUtil.BaseVisualState.Normal
	return YELLOW_FONT_COLOR;
end

function TalentButtonUtil.CalculateIconTexture(definitionInfo, overrideSpellID)
	if definitionInfo then
		local overrideIcon = definitionInfo.overrideIcon;
		if overrideIcon then
			return overrideIcon;
		end

		local spellID = overrideSpellID or definitionInfo.spellID;
		if spellID then
			local spellIcon = select(8, GetSpellInfo(spellID));
			return spellIcon;
		end
	end

	return [[Interface\Icons\spell_magic_polymorphrabbit]];
end

function TalentButtonUtil.SetSpendText(button, spendText)
	button.SpendText:SetText(spendText);

	if button.spendTextShadows then
		for i, shadow in ipairs(button.spendTextShadows) do
			shadow:SetText(spendText);
		end
	end
end

function TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled()
	-- This functionality has been disabled for now in lieu of the new repurchase flow.
	return false;
end

function TalentButtonUtil.GetRefundInvalidInfo(nodeInfo)
	if not nodeInfo then
		-- This isn't a good state either, but we don't want to display this as RefundInvalid.
		return false, nil;
	end

	if nodeInfo.ranksPurchased <= 0 then
		return false, nil;
	end

	-- If we don't meet edge requirements, a dependency must have been refunded.
	if not nodeInfo.meetsEdgeRequirements then
		return true, TALENT_BUTTON_TOOLTIP_REFUND_INVALID_LINKS_ERROR;

	-- If we can't purchase a rank but we are cascadeRepurchasable, a condition we're
	-- dependent on must no longer be met due to refunds.
	elseif not nodeInfo.canPurchaseRank and nodeInfo.isCascadeRepurchasable then
		return true, TALENT_BUTTON_TOOLTIP_REFUND_INVALID_CONDITIONS_ERROR;
	end
end

function TalentButtonUtil.CheckAddRefundInvalidInfo(tooltip, isRefundInvalid, refundInvalidInstructions)
	if not isRefundInvalid then
		return false;
	end

	GameTooltip_AddBlankLineToTooltip(tooltip);
	GameTooltip_AddErrorLine(tooltip, refundInvalidInstructions);
	return true;
end

TalentButtonUtil.ActionBarStatus = {
	NotMissing = 1, 			-- Either Passive, unlearned, or is on an active bar
	MissingFromAllBars = 2,		-- Not on any action bar
	OnInactiveBonusBar = 3,		-- On a bar belonging to a different stance
	OnDisabledActionBar = 4,	-- On a bar that's been disabled via settings
};

local ActionBarStatusTooltips = {
	[TalentButtonUtil.ActionBarStatus.NotMissing] = nil,
	[TalentButtonUtil.ActionBarStatus.MissingFromAllBars] = TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR,
	[TalentButtonUtil.ActionBarStatus.OnInactiveBonusBar] = TALENT_BUTTON_TOOLTIP_ON_INACTIVE_BONUSBAR,
	[TalentButtonUtil.ActionBarStatus.OnDisabledActionBar] = TALENT_BUTTON_TOOLTIP_ON_DISABLED_ACTIONBAR,
}

TalentButtonUtil.SearchMatchType = {
	RelatedMatch = 1,
	Match = 2,
	ExactMatch = 3,
	NotOnActionBar = 4,
	OnInactiveBonusBar = 5,
	OnDisabledActionBar = 6,
};

local SearchMatchStyles = {
	[TalentButtonUtil.SearchMatchType.RelatedMatch] = {
		icon = "talents-search-relatedmatch",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_RELATED_MATCH
	},
	[TalentButtonUtil.SearchMatchType.Match] = {
		icon = "talents-search-match",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_MATCH
	},
	[TalentButtonUtil.SearchMatchType.ExactMatch] = {
		icon = "talents-search-exactmatch",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_EXACT_MATCH
	},
	[TalentButtonUtil.SearchMatchType.NotOnActionBar] = {
		icon = "talents-search-notonactionbar",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_NOT_ON_ACTIONBAR
	},
	[TalentButtonUtil.SearchMatchType.OnInactiveBonusBar] = {
		icon = "talents-search-notonactionbarhidden",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_ON_INACTIVE_BONUSBAR
	},
	[TalentButtonUtil.SearchMatchType.OnDisabledActionBar] = {
		icon = "talents-search-notonactionbarhidden",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_ON_DISABLED_ACTIONBAR
	},
};

function TalentButtonUtil.GetStyleForSearchMatchType(matchType)
	return SearchMatchStyles[matchType];
end

function TalentButtonUtil.GetHoverAlphaForVisualStyle(visualStyle)
	return HoverAlphaByVisualState[visualStyle];
end

function TalentButtonUtil.GetTooltipForActionBarStatus(status)
	return ActionBarStatusTooltips[status];
end

function TalentButtonUtil.GetActionbarStatusForSpell(spellID)
	if not spellID or IsPassiveSpell(spellID) then
		return TalentButtonUtil.ActionBarStatus.NotMissing;
	end

	-- First retrieve all action bars the spell is slotted on
	local excludeNonPlayerBars = true;
	local barsWithSpell = ActionButtonUtil.GetActionBarsForSpell(spellID, excludeNonPlayerBars);
	if not barsWithSpell then
		return TalentButtonUtil.ActionBarStatus.MissingFromAllBars;
	end

	-- Then evaluate whether those are active, and if not, what type of inactive bar
	local isOnInactiveBonusBar, isOnDisabledBar = false, false;
	for _, barEntry in pairs(barsWithSpell) do
		if barEntry.isActive then
			return TalentButtonUtil.ActionBarStatus.NotMissing;
		end

		-- Inactive MultiActionBar means bar is disabled in settings
		if barEntry.barType == ActionButtonUtil.ActionBarType.MultiActionBar then
			isOnDisabledBar = true;
		-- Inactive Bonus Bar means bar belongs to a different stance
		elseif barEntry.barType == ActionButtonUtil.ActionBarType.BonusBar then
			isOnInactiveBonusBar = true;
		end
	end

	-- Spell being on a disabled bar for all stances takes priority over being on another stance's bar
	if isOnDisabledBar then
		return TalentButtonUtil.ActionBarStatus.OnDisabledActionBar;
	elseif isOnInactiveBonusBar then
		return TalentButtonUtil.ActionBarStatus.OnInactiveBonusBar;
	else
		return TalentButtonUtil.ActionBarStatus.MissingFromAllBars;
	end
end

function TalentButtonUtil.GetActionBarStatusForNode(nodeInfo, spellID)
	if not nodeInfo or not nodeInfo.entryIDsWithCommittedRanks or (#nodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return TalentButtonUtil.ActionBarStatus.NotMissing;
	end

	return TalentButtonUtil.GetActionbarStatusForSpell(spellID);
end

function TalentButtonUtil.GetActionBarStatusForNodeEntry(entryID, nodeInfo, spellID)
	if not nodeInfo or not nodeInfo.entryIDsWithCommittedRanks or (#nodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return TalentButtonUtil.ActionBarStatus.NotMissing;
	end

	local isEntryCommitted = false;
	for _, committedEntryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
		if committedEntryID == entryID then
			isEntryCommitted = true;
			break;
		end
	end

	if not isEntryCommitted then
		return TalentButtonUtil.ActionBarStatus.NotMissing;
	end

	return TalentButtonUtil.GetActionbarStatusForSpell(spellID);
end

-- TODO:: Replace this temp code that is supplying missing pieces to avoid Lua errors.
local OriginalGetTreeInfo = C_Traits.GetTreeInfo;
C_Traits.GetTreeInfo = function (configID, treeID)
	local treeInfo = OriginalGetTreeInfo(configID, treeID);
	if treeInfo then
		treeInfo.minZoom = treeInfo.minZoom or 1;
		treeInfo.maxZoom = treeInfo.maxZoom or 1;
		treeInfo.buttonSize = treeInfo.buttonSize or 40;
	end

	return treeInfo;
end;

local OriginalGetEntryInfo = C_Traits.GetEntryInfo;
C_Traits.GetEntryInfo = function (...)
	local entryInfo = OriginalGetEntryInfo(...);
	if entryInfo then
		entryInfo.entryCost = {};
	end

	return entryInfo;
end;

-- TODO:: replace this with a more formal wrapper around the API.
local OriginalGetConditionInfo = C_Traits.GetConditionInfo;
C_Traits.GetConditionInfo = function (...)
	local condInfo = OriginalGetConditionInfo(...);
	if condInfo then
		local function EvaluateConditionTooltipText()
			local tooltipFormat = condInfo.tooltipFormat;
			if not tooltipFormat then
				return nil;
			end

			if condInfo.isAlwaysMet then
				return tooltipFormat;
			elseif condInfo.questID then
				return tooltipFormat:format(C_QuestLog.GetTitleForQuestID(condInfo.questID) or "");
			elseif condInfo.achievementID then
				local id, achievementName = GetAchievementInfo(condInfo.achievementID);
				return tooltipFormat:format(achievementName);
			elseif condInfo.specSetID then
				local specName = PlayerUtil.GetSpecName() or "";
				local className = PlayerUtil.GetClassName() or "";
				return tooltipFormat:format(specName, className);
			elseif condInfo.playerLevel then
				return tooltipFormat:format(condInfo.playerLevel);
			elseif condInfo.spentAmountRequired then
				local TEMP_GATE_FORMAT_STRING_ARG = ""; -- TODO:: Remove this once the appropriate strings have been updated.
				return tooltipFormat:format(condInfo.spentAmountRequired, TEMP_GATE_FORMAT_STRING_ARG);
			end

			return nil;
		end

		local tooltipText = EvaluateConditionTooltipText();
		condInfo.tooltipText = (tooltipText and not condInfo.isMet) and RED_FONT_COLOR:WrapTextInColorCode(tooltipText) or tooltipText;
	end

	return condInfo;
end;
