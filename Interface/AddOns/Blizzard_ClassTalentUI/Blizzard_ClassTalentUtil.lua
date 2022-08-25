
local ClassTemplatesByEdgeVisualization = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};


ClassTalentUtil = {};

function ClassTalentUtil.GetEdgeTemplateType(edgeVisualStyle)
	return ClassTemplatesByEdgeVisualization[edgeVisualStyle];
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