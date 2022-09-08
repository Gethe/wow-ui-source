
local ClassTemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};


ClassTalentUtil = {};

function ClassTalentUtil.GetEdgeTemplateType(edgeVisualStyle)
	return ClassTemplatesByEdgeVisualStyle[edgeVisualStyle];
end

function ClassTalentUtil.GetSpecializedMixin(nodeInfo, talentType)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection) then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return ClassTalentButtonSplitSelectMixin;
		else
			return ClassTalentButtonSelectMixin;
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

	if not spellID or IsPassiveSpell(spellID) then
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

	if not spellID or IsPassiveSpell(spellID) then
		return false;
	end

	return not C_ActionBar.IsOnBarOrSpecialBar(spellID);
end