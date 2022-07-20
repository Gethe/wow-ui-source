
TALENT_BUTTON_TOOLTIP_RANK_FORMAT = "Rank %s/%s";
TALENT_BUTTON_TOOLTIP_COST_ENTRY_FORMAT = "%d %s";
TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR = " ";
TALENT_BUTTON_TOOLTIP_COST_FORMAT = "Cost: %s";
TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS = "Click to learn";
TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS = "Right click to unlearn";
TALENT_BUTTON_TOOLTIP_SELECTION_INSTRUCTIONS = "Click to learn";
TALENT_BUTTON_TOOLTIP_SELECTION_CURRENT_INSTRUCTIONS = "This is already learned";
TALENT_BUTTON_TOOLTIP_SELECTION_COST_ERROR = "You can't afford this choice";
TALENT_BUTTON_TOOLTIP_SELECTION_CHOICE_ERROR = "Select another choice";
TALENT_BUTTON_TOOLTIP_SELECTION_ERROR = "This node isn't active";
TALENT_BUTTON_TOOLTIP_SELECT_TITLE = "Talent Slot";
TALENT_BUTTON_TOOLTIP_NEXT_RANK = "Next Rank:";
TALENT_BUTTON_TOOLTIP_REPLACED_BY_FORMAT = "Replaced by %s";
TALENT_BUTTON_TOOLTIP_SELECT_INSTRUCTIONS = "Choose one option";
TALENT_BUTTON_TOOLTIP_SELECT_CHANGE_INSTRUCTIONS = "Right click to unlearn";
TALENT_BUTTON_TOOLTIP_SELECT_PREVIEW_INSTRUCTIONS = "Preview options";
TALENT_FRAME_CURRENCY_FORMAT = "%s %s";
TALENT_FRAME_CURRENCY_FORMAT_WITH_MAXIMUM = "%s / %s %s";

TALENT_FRAME_LABEL_PVP_TALENT_SLOTS = "PVP";
TALENT_FRAME_LABEL_WARMODE = "WARMODE";
TALENT_FRAME_LABEL_RESET_BUTTON = "Reset All Talents";

TALENT_FRAME_DROP_DOWN_NEW_LOADOUT = "New Loadout";
TALENT_FRAME_DROP_DOWN_NEW_LOADOUT_PROMPT = "Enter a name for the new loadout";

TALENT_FRAME_TAB_LABEL_SPEC = "Specialization";
TALENT_FRAME_TAB_LABEL_TALENTS = "Talents";

TALENT_FRAME_CURRENCY_DISPLAY_FORMAT = "%s POINTS AVAILABLE";

TALENT_FRAME_APPLY_BUTTON_TEXT = "Apply Changes";
TALENT_FRAME_DISCARD_CHANGES_BUTTON_TOOLTIP = "Undo Pending Changes";
TALENT_FRAME_RESET_BUTTON_TOOLTIP = "Reset All Talents";

TALENT_FRAME_CONFIG_OPERATION_TOO_FAST = "Talent operation still in progress, try again later.";

TALENT_FRAME_CONFIRM_CLOSE = "You will lose any pending changes if you continue.";

TALENT_FRAME_GATE_TOOLTIP_FORMAT = "Spend %d more |4point:points; to unlock this row";


local TemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "TalentButtonSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "TalentButtonCircleTemplate",
};

local TemplatesByEdgeVisualization = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeStraightTemplate",
};


TalentUtil = {}

function TalentUtil.IsFriendlyCondition(condType)
	return condType == Enum.TraitConditionType.Granted or condType == Enum.TraitConditionType.Increased;
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
};

function TalentButtonUtil.GetTemplateForTalentType(nodeInfo, talentType)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return "TalentButtonChoiceTemplate";
		end
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

function TalentButtonUtil.GetTemplateForEdgeVisualization(visualization)
	return TemplatesByEdgeVisualization[visualization];
end

function TalentButtonUtil.ApplyPosition(button, talentFrame, posX, posY)
	local point, relativeTo, relativePoint = button:GetPoint();
	local panOffsetX, panOffsetY = talentFrame:GetPanOffset();
	local newX = (posX / 10) - panOffsetX;
	local newY = (-posY / 10) + panOffsetY;
	button:SetPoint(point, relativeTo, relativePoint, newX, newY);
end

function TalentButtonUtil.GetTalentName(overrideName, spellID)
	if overrideName ~= nil then
		return overrideName;
	end

	if spellID ~= nil then
		local spellName = GetSpellInfo(spellID);
		if spellName ~= nil then
			return spellName;
		end
	end

	return "";
end

function TalentButtonUtil.GetColorForBaseVisualState(visualState)
	if (visualState == TalentButtonUtil.BaseVisualState.Gated) or (visualState == TalentButtonUtil.BaseVisualState.Disabled) or (visualState == TalentButtonUtil.BaseVisualState.Locked) then
		return DISABLED_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.Selectable then
		return GREEN_FONT_COLOR;
	end

	-- visualState == TalentButtonUtil.BaseVisualState.Maxed or
	-- visualState == TalentButtonUtil.BaseVisualState.Normal
	return YELLOW_FONT_COLOR;
end

function TalentButtonUtil.CalculateIconTexture(talentInfo, overrideSpellID)
	if talentInfo ~= nil then
		local overrideIcon = talentInfo.overrideIcon;
		if overrideIcon ~= nil then
			return overrideIcon;
		end

		local spellID = overrideSpellID or talentInfo.spellID;
		if spellID ~= nil then
			local spellIcon = select(8, GetSpellInfo(spellID));
			return spellIcon;
		end
	end

	return [[Interface\Icons\spell_magic_polymorphrabbit]];
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
		entryInfo.talentID = entryInfo.definitionID;
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
				local classInfo = PlayerUtil.GetClassInfo();
				local className = (classInfo and classInfo.className) or "";
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
