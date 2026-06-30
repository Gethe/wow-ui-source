local _addonName, addonTable = ...;

MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 32;

TargetFrameAuraContainerDefaults =
{
	SmallAuraSize = 17,
	LargeAuraSize = 21,

	AuraElementSpacingX = 3,
	AuraElementSpacingY = 3,

	AuraPaddingLeft = 0,
	AuraPaddingRight = 0,
	AuraPaddingTop = 0,
	AuraPaddingBottom = 0,

	AuraRowWidth = 122,
	ConstrainedAuraRowWidth = 101,
	NumConstrainedAuraRows = 0,

	MirrorVertically = false,
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
