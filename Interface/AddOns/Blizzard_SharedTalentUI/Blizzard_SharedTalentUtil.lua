
local TemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "TalentButtonSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "TalentButtonCircleTemplate",
	[Enum.TraitNodeEntryType.SpendSmallCircle] = "TalentButtonSmallCircleTemplate",
};

local LargeTemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "TalentButtonLargeSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "TalentButtonLargeCircleTemplate",
};

local EntryTypeUsesArtMixin = {
	[Enum.TraitNodeEntryType.SpendSquare] = true,
	[Enum.TraitNodeEntryType.SpendCircle] = true,
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
	if overrideName and (overrideName ~= "") then
		return overrideName;
	end

	if spellID then
		local spellName = C_Spell.GetSpellName(spellID);
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
		local spellSubtext = C_Spell.GetSpellSubtext(spellID);
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
		local spellDescription = C_Spell.GetSpellDescription(spellID);
		if spellDescription then
			return spellDescription;
		end
	end

	return "";
end

function TalentUtil.GetReplacesSpellNameFromInfo(definitionInfo)
	if definitionInfo and definitionInfo.overriddenSpellID then
		local overriddenSpellID = C_Spell.GetOverrideSpell(definitionInfo.overriddenSpellID);
		local overriddenSpellName = C_Spell.GetSpellName(overriddenSpellID);
		if overriddenSpellName then
			return overriddenSpellName;
		end
	end

	return "";
end

-- Utils that take in a Talent Frame instance as the first argument
-- If we ever refactor generalize the Get_Info functions into a data provider model, we can easily adjust and separate out functions that only use the TalentFrame for that
TalentFrameUtil = {}

function TalentFrameUtil.GetActiveSubTreeFromSubTreeSelectionNode(talentFrame, nodeInfo)
	local activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil;
	local activeEntryInfo = activeEntryID and talentFrame:GetAndCacheEntryInfo(activeEntryID);
	return activeEntryInfo and activeEntryInfo.subTreeID;
end

function TalentFrameUtil.GetSubTreesIDsFromSubTreeSelectionNode(talentFrame, nodeInfo)
	local subTreeIDs = {};
	for _, entryID in ipairs(nodeInfo.entryIDs) do
		local entryInfo = talentFrame:GetAndCacheEntryInfo(entryID);
		if entryInfo and entryInfo.subTreeID then
			table.insert(subTreeIDs, entryInfo.subTreeID);
		end
	end
	return subTreeIDs;
end

function TalentFrameUtil.GetSubTreeCurrencyID(talentFrame, subTreeID)
	local subTreeInfo = subTreeID and talentFrame:GetAndCacheSubTreeInfo(subTreeID) or nil;
	return subTreeInfo and subTreeInfo.traitCurrencyID or nil;
end

function TalentFrameUtil.GetCurrencyAvailable(talentFrame, traitCurrencyID)
	local currencyInfo = traitCurrencyID and talentFrame:GetTreeCurrencyInfo(traitCurrencyID) or nil;
	return currencyInfo and currencyInfo.quantity or 0;
end

function TalentFrameUtil.GetCurrencySpent(talentFrame, traitCurrencyID)
	local currencyInfo = traitCurrencyID and talentFrame:GetTreeCurrencyInfo(traitCurrencyID) or nil;
	return currencyInfo and currencyInfo.spent or 0;
end

function TalentFrameUtil.GetSubTreeCurrencyAvailable(talentFrame, subTreeID)
	local currencyID = TalentFrameUtil.GetSubTreeCurrencyID(talentFrame, subTreeID);
	return TalentFrameUtil.GetCurrencyAvailable(talentFrame, currencyID);
end

function TalentFrameUtil.GetSubTreeCurrencySpent(talentFrame, subTreeID)
	local currencyID = TalentFrameUtil.GetSubTreeCurrencyID(talentFrame, subTreeID);
	return TalentFrameUtil.GetCurrencySpent(talentFrame, currencyID);
end

function TalentFrameUtil.GetFirstAvailableSubTreeSelectionNode(talentFrame, availableSubTreeIDs)
	local treeInfo = talentFrame:GetTreeInfo();
	if not availableSubTreeIDs then
		return nil;
	end
	for _, subTreeID in ipairs(availableSubTreeIDs) do
		local subTreeInfo = talentFrame:GetAndCacheSubTreeInfo(subTreeID);
		if subTreeInfo and subTreeInfo.subTreeSelectionNodeIDs then
			for _, selectionNodeID in ipairs(subTreeInfo.subTreeSelectionNodeIDs) do
				local nodeInfo = talentFrame:GetAndCacheNodeInfo(selectionNodeID);
				if nodeInfo and nodeInfo.isVisible and nodeInfo.isAvailable then
					return nodeInfo;
				end
			end
		end
	end
	return nil;
end

function TalentFrameUtil.GetFirstActiveSubTree(talentFrame, availableSubTreeIDs)
	local treeInfo = talentFrame:GetTreeInfo();

	if not availableSubTreeIDs then
		return nil;
	end

	for _, subTreeID in ipairs(availableSubTreeIDs) do
		local subTreeInfo = talentFrame:GetAndCacheSubTreeInfo(subTreeID);
		if subTreeInfo and subTreeInfo.isActive then
			return subTreeInfo;
		end
	end

	return nil;
end

function TalentFrameUtil.GetNormalizedSubTreeNodePosition(talentFrame, nodeInfo)
	-- Normalize the node's position values based on the subTree's normalized top center position
	local tPosX = nodeInfo.posX;
	local tPosY = nodeInfo.posY;

	local subTreeInfo = talentFrame:GetAndCacheSubTreeInfo(nodeInfo.subTreeID);
	if subTreeInfo and subTreeInfo.posX and subTreeInfo.posY then
		tPosX = tPosX - subTreeInfo.posX;
		tPosY = tPosY - subTreeInfo.posY;
	end

	return tPosX, tPosY;
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
	DisplayError = 9,
};

TalentButtonUtil.SizingAdjustment = {
	Circle = {
		{ region = "Icon", adjust = 0, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "BorderShadow", adjust = -2, },
		{ region = "StateBorder", adjust = -4, },
		{ region = "Border2", adjust = -4, },
		{ region = "Border", adjust = -7, },
		{ region = "IconMask", adjust = -8, },
		{ region = "BorderMask", adjust = -7, },
		{ region = "Border2Mask", adjust = -4, },
		{ region = "BorderShadowMask", adjust = -2, },
		{ region = "DisabledOverlayMask", adjust = -3, },
	},

	ProfessionPerk = {
		{ region = "Icon", adjust = 0, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "BorderShadow", adjust = 2, },
		{ region = "StateBorder", adjust = 0, },
		{ region = "Border2", adjust = 0, },
		{ region = "Border", adjust = -3, },
	},

	Large = {
		{ region = "Icon", adjust = 0, },
		{ region = "IconMask", adjust = 0, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "DisabledOverlayMask", adjust = 0, },
		{ region = "StateBorder", adjust = 0, },
		{ region = "Ghost", adjust = 0, },
		{ region = "Glow", adjust = 0, },
		{ region = "SelectableGlow", adjust = 0, },
		{ region = "SpendText", anchorX = 20 },
	},

	Small = {
		{ region = "Icon", adjust = 0, },
		{ region = "IconMask", adjust = -2, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "DisabledOverlayMask", adjust = 0, },
		{ region = "StateBorder", adjust = 0, },
		{ region = "Ghost", adjust = 0, },
		{ region = "Glow", adjust = 0, },
		{ region = "SelectableGlow", adjust = 0, },
		{ region = "SpendText", anchorX = 6, anchorY = -6, },
		{ region = "Shadow", adjust = 0, },
	},

	LegionInfinite = {
		{ region = "Icon", adjust = -8, },
		{ region = "IconMask", adjust = -8, },
		{ region = "DisabledOverlay", adjust = 0, },
		{ region = "BorderShadow", adjust = 0, },
		{ region = "StateBorder", adjust = 0, anchorX = 4, anchorY = -4 },
		{ region = "StateBorderHover", adjust = 0, anchorX = 4, anchorY = -4},
		{ region = "Border2", adjust = 0, },
		{ region = "Border", adjust = 0, },
		{ region = "BorderMask", adjust = 0, },
		{ region = "Border2Mask", adjust = 0, },
		{ region = "BorderShadowMask", adjust = 0, },
		{ region = "DisabledOverlayMask", adjust = 0, },
		{ region = "SpendText", anchorX = 14, anchorY = 6, },
	},
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
	[TalentButtonUtil.BaseVisualState.DisplayError] = 1,
};

function TalentButtonUtil.GetTemplateForTalentType(nodeInfo, talentType, useLarge)
	-- By default, any use of SubTreeSelection nodes without a bespoke override will treat them like regular Selection nodes
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowExpandedSelection) then
			return "TalentButtonSelectExpandedTemplate";
		elseif FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
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
	-- By default, any use of SubTreeSelection nodes without a bespoke override will treat them like regular Selection nodes
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowExpandedSelection) then
			return TalentButtonSelectExpandedButtonMixin;
		elseif FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return TalentButtonSplitSelectMixin;
		else
			return TalentButtonSelectMixin;
		end
	end

	return TalentButtonSpendMixin;
end

function TalentButtonUtil.GetSpecializedChoiceMixin(_entryInfo, talentType)
	if EntryTypeUsesArtMixin[talentType] then
		return TalentSelectionChoiceArtMixin;
	end

	return TalentSelecTalentSelectionChoiceMixintionChoiceArtMixin;
end

function TalentButtonUtil.GetTemplateForEdgeVisualStyle(visualStyle)
	return TemplatesByEdgeVisualStyle[visualStyle];
end

function TalentButtonUtil.ApplyPosition(button, talentFrame, posX, posY)
	local panOffsetX, panOffsetY = talentFrame:GetPanOffset();
	TalentButtonUtil.ApplyPositionAtOffset(button, posX, posY, panOffsetX, panOffsetY);
end

function TalentButtonUtil.ApplyPositionAtOffset(button, posX, posY, offsetX, offsetY)
	local point, relativeTo, relativePoint = button:GetPoint();
	local newX, newY = TalentButtonUtil.TranslateNodePositionsToAnchorPositions(posX, posY, offsetX, offsetY);
	button:SetPoint(point, relativeTo, relativePoint, newX, newY);
end

function TalentButtonUtil.TranslateNodePositionsToAnchorPositions(posX, posY, offsetX, offsetY)
	local newX = (posX / 10) - offsetX;
	local newY = (-posY / 10) + offsetY;
	return newX, newY;
end

function TalentButtonUtil.GetColorForBaseVisualState(visualState)
	if (visualState == TalentButtonUtil.BaseVisualState.Gated) or (visualState == TalentButtonUtil.BaseVisualState.Disabled) or (visualState == TalentButtonUtil.BaseVisualState.Locked) then
		return DISABLED_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.Selectable then
		return GREEN_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.RefundInvalid then
		return RED_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.DisplayError then
		return RED_FONT_COLOR;
	end

	-- visualState == TalentButtonUtil.BaseVisualState.Maxed or
	-- visualState == TalentButtonUtil.BaseVisualState.Normal
	return YELLOW_FONT_COLOR;
end

function TalentButtonUtil.CalculateIconTextureFromInfo(definitionInfo, subTreeInfo)
	-- By default, any use of SubTreeSelection nodes without a bespoke override will treat them like regular Selection nodes
	-- So we need to handle getting an icon from either an entry's subTree OR its definition
	if subTreeInfo and subTreeInfo.iconElementID and subTreeInfo.iconElementID ~= "" then
		return subTreeInfo.iconElementID, true;
	end

	local spellID = definitionInfo and definitionInfo.spellID or nil;
	return TalentButtonUtil.CalculateIconTexture(definitionInfo, spellID), false;
end

function TalentButtonUtil.CalculateIconTexture(definitionInfo, overrideSpellID)
	if definitionInfo then
		local overrideIcon = definitionInfo.overrideIcon;
		if overrideIcon then
			return overrideIcon;
		end

		local spellID = overrideSpellID or definitionInfo.spellID;
		if spellID then
			local spellIcon = select(2, C_Spell.GetSpellTexture(spellID));
			return spellIcon;
		end
	end

	return [[Interface\Icons\spell_magic_polymorphrabbit]];
end

function TalentButtonUtil.SetSpendText(button, spendText)
	MixinUtil.CallMethodSafe(button.SpendText, "SetText", spendText);

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

local SearchMatchStyles = {
	[SpellSearchUtil.MatchType.RelatedMatch] = {
		icon = "talents-search-relatedmatch",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_RELATED_MATCH
	},
	[SpellSearchUtil.MatchType.NameMatch] = {
		icon = "talents-search-match",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_MATCH
	},
	[SpellSearchUtil.MatchType.DescriptionMatch] = {
		icon = "talents-search-match",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_MATCH
	},
	[SpellSearchUtil.MatchType.ExactMatch] = {
		icon = "talents-search-exactmatch",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_EXACT_MATCH
	},
	[SpellSearchUtil.MatchType.NotOnActionBar] = {
		icon = "talents-search-notonactionbar",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_NOT_ON_ACTIONBAR
	},
	[SpellSearchUtil.MatchType.OnInactiveBonusBar] = {
		icon = "talents-search-notonactionbarhidden",
		tooltipText = TALENT_FRAME_SEARCH_TOOLTIP_ON_INACTIVE_BONUSBAR
	},
	[SpellSearchUtil.MatchType.OnDisabledActionBar] = {
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
	local configID, condID, ignoreFontColor = ...;
	local condInfo = OriginalGetConditionInfo(configID, condID);
	if not condInfo then
		return nil;
	end

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

	local function FormatConditionTooltipText()
		if not tooltipText then
			return nil;
		end

		-- Tooltips of met conditions shouldn't do any formatting.
		if condInfo.isMet then
			-- Unless they're DisplayError type, in which case they should always be formatted
			-- whether they're met or not.
			if condInfo.type ~= Enum.TraitConditionType.DisplayError then
				return tooltipText;
			end
		end

		if ignoreFontColor then
			return tooltipText;
		end;

		-- Designers can use tokens (e.g. $@spellname1234) for condition tooltips and the parsing code
		-- automatically applies colorization that isn't desired so remove it prior to coloring the entire string red.
		local strippedTooltipText = StripHyperlinks(tooltipText);

		local coloredTooltipText = RED_FONT_COLOR:WrapTextInColorCode(strippedTooltipText);
		return coloredTooltipText;
	end

	condInfo.tooltipText = FormatConditionTooltipText();

	return condInfo;
end;
