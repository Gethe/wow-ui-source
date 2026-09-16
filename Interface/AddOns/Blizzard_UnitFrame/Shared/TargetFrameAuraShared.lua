local _addonName, addonTable = ...;

MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 32;

TargetFrameAuraContainerDefaults =
{
	SmallAuraSize = 17,
	LargeAuraSize = 21,

	FlowLayoutElementSpacing = 3,
	FlowLayoutLineSize = 122,
	FlowLayoutLineSpacing = 3,
	FlowLayoutPaddingBottom = 0,
	FlowLayoutPaddingLeft = 0,
	FlowLayoutPaddingRight = 0,
	FlowLayoutPaddingTop = 0,

	ConstrainedFlowLayoutLineSize = 101,
	NumConstrainedFlowLayoutLines = 0,

	ShowAuraCount = true,

	MaxBuffs = MAX_TARGET_BUFFS,
	MaxDebuffs = MAX_TARGET_DEBUFFS,

	BuffFilterString = AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful),
	DebuffFilterString = AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.IncludeNameplateOnly),
};

function addonTable.GetTargetFrameBuffButtonTemplate()
	if GetBuildOption("RestrictedAuraAPI") then
		return "ForbiddenTargetFrameBuffButtonTemplate";
	end

	return "TargetFrameBuffButtonTemplate";
end

function addonTable.GetTargetFrameDebuffButtonTemplate()
	if GetBuildOption("RestrictedAuraAPI") then
		return "ForbiddenTargetFrameDebuffButtonTemplate";
	end

	return "TargetFrameDebuffButtonTemplate";
end
