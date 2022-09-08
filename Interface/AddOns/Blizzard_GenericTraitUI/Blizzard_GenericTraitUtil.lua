
local TemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};

GenericTraitUtil = {};

function GenericTraitUtil.GetEdgeTemplateType(edgeVisualStyle)
	return TemplatesByEdgeVisualStyle[edgeVisualStyle];
end