
local ClassTemplatesByEdgeVisualization = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};


ClassTalentUtil = {};

function ClassTalentUtil.GetEdgeTemplateType(edgeVisualStyle)
	return ClassTemplatesByEdgeVisualization[edgeVisualStyle];
end
