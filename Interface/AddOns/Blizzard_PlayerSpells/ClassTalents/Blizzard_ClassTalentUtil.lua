local ClassTemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "ClassTalentButtonSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "ClassTalentButtonCircleTemplate",
	[Enum.TraitNodeEntryType.SpendCapstoneCircle] = "ClassTalentButtonCapstoneCircleTemplate",
	[Enum.TraitNodeEntryType.SpendCapstoneSquare] = "ClassTalentButtonCapstoneSquareTemplate",
};

local ClassLargeTemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "ClassTalentButtonLargeSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "ClassTalentButtonLargeCircleTemplate",
};

local ClassTemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "ClassTalentEdgeArrowTemplate",
};

local SheenAlphaByVisualState = {
	[TalentButtonUtil.BaseVisualState.Normal] = 1,
	[TalentButtonUtil.BaseVisualState.Gated] = 0,
	[TalentButtonUtil.BaseVisualState.Disabled] = 1,
	[TalentButtonUtil.BaseVisualState.Locked] = 1,
	[TalentButtonUtil.BaseVisualState.Selectable] = 0,
	[TalentButtonUtil.BaseVisualState.Maxed] = 1,
	[TalentButtonUtil.BaseVisualState.Invisible] = 0,
	[TalentButtonUtil.BaseVisualState.RefundInvalid] = 0,
	[TalentButtonUtil.BaseVisualState.DisplayError] = 1,
};

local DEFAULT_SPEND_SOUND_KIT_BY_ENTRY_TYPE = {
	[Enum.TraitNodeEntryType.SpendSquare] = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR,
	[Enum.TraitNodeEntryType.SpendCircle] = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND,
	[Enum.TraitNodeEntryType.SpendCapstoneCircle] = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND,
	[Enum.TraitNodeEntryType.SpendCapstoneSquare] = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR,
};

ClassTalentUtil = {};

function ClassTalentUtil.GetVisualsForSpecID(specID)
	return SpecializationVisuals[specID];
end

function ClassTalentUtil.GetVisualsForClassID(classID)
	return ClassVisuals[classID];
end

function ClassTalentUtil.GetTemplateForTalentType(nodeInfo, talentType, useLarge)
	if nodeInfo and nodeInfo.type == Enum.TraitNodeType.Selection then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return "ClassTalentButtonChoiceTemplate";
		end
	end

	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Tiered) and FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowTierTrack) then
		if talentType == Enum.TraitNodeEntryType.SpendCapstoneCircle then
			return "ClassTalentButtonCapstoneWithTrackCircleTemplate";
		elseif talentType == Enum.TraitNodeEntryType.SpendCapstoneSquare then
			return "ClassTalentButtonCapstoneWithTrackSquareTemplate";
		end
	end

	local isCapstoneChildDisplayElement = not nodeInfo and (talentType == Enum.TraitNodeEntryType.SpendCapstoneCircle or talentType == Enum.TraitNodeEntryType.SpendCapstoneSquare);
	if isCapstoneChildDisplayElement then
		return "ClassTalentButtonCapstonePipCircleTemplate";
	end

	if useLarge then
		return ClassLargeTemplatesByTalentType[talentType] or "ClassTalentButtonLargeCircleTemplate";
	end

	-- Anything without a specific shared template will be a circle for now.
	return ClassTemplatesByTalentType[talentType] or "ClassTalentButtonCircleTemplate";
end

function ClassTalentUtil.GetEdgeTemplateType(edgeVisualStyle)
	return ClassTemplatesByEdgeVisualStyle[edgeVisualStyle];
end

function ClassTalentUtil.GetSpecializedMixin(nodeInfo, talentType)
	if nodeInfo and nodeInfo.type == Enum.TraitNodeType.Selection then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return ClassTalentButtonSplitSelectMixin;
		else
			return ClassTalentButtonSelectMixin;
		end
	end

	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Tiered) and FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowTierTrack) then
		if talentType == Enum.TraitNodeEntryType.SpendCapstoneCircle or talentType == Enum.TraitNodeEntryType.SpendCapstoneSquare then
			return ClassTalentButtonCapstoneWithTrackMixin;
		end
	end

	return ClassTalentButtonSpendMixin;
end

function ClassTalentUtil.GetSpecializedChoiceMixin(entryInfo, talentType)
	return ClassTalentSelectionChoiceMixin;
end

function ClassTalentUtil.IsTalentMissingFromActionBars(nodeInfo, spellID)
	if not nodeInfo or not nodeInfo.entryIDsWithCommittedRanks or (#nodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return false;
	end

	if not spellID or C_Spell.IsSpellPassive(spellID) then
		return false;
	end

	return not C_ActionBar.IsOnBarOrSpecialBar(spellID);
end

function ClassTalentUtil.IsEntryTalentMissingFromActionBars(entryID, nodeInfo, spellID)
	if not nodeInfo or not nodeInfo.entryIDsWithCommittedRanks or (#nodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return false;
	end

	local foundEntryID = false;
	for i, committedEntryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
		if committedEntryID == entryID then
			foundEntryID = true;
			break;
		end
	end

	if not foundEntryID then
		return false;
	end

	if not spellID or C_Spell.IsSpellPassive(spellID) then
		return false;
	end

	return not C_ActionBar.IsOnBarOrSpecialBar(spellID);
end

function ClassTalentUtil.GetSheenAlphaForVisualState(visualState)
	return SheenAlphaByVisualState[visualState];
end

local spendSoundKitByEntryType = CopyTable(DEFAULT_SPEND_SOUND_KIT_BY_ENTRY_TYPE);

-- Allows other game modes to use different spend sounds for each type.
if ClassTalentUtilSpendSoundKitByEntryTypeOverrides then
	for entryType, soundKitID in pairs(ClassTalentUtilSpendSoundKitByEntryTypeOverrides) do
		spendSoundKitByEntryType[entryType] = soundKitID;
	end
end

function ClassTalentUtil.GetSpendSoundKitID(entryType)
	if not entryType then
		return SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	end

	return spendSoundKitByEntryType[entryType] or SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
end

ClassTalentUtil.ShouldRefundClearEdges = IsShiftKeyDown;
