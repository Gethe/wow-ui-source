
local TemplatesByEdgeVisualization = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};

GenericTraitUtil = {};

function GenericTraitUtil.GetEdgeTemplateType(edgeVisualStyle)
	return TemplatesByEdgeVisualization[edgeVisualStyle];
end