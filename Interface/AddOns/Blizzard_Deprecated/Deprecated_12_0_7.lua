-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function MenuUtil.ShowTooltip(owner, func, ...)
	MenuUtil.ShowTooltipEx(owner, GetAppropriateTooltip(), func, ...);
end

function MenuUtil.HideTooltip(owner)
	MenuUtil.HideTooltipEx(owner, GetAppropriateTooltip());
end

function C_ClickBindings.MakeModifiers(...)
	return MakeModifiers();
end

function C_ClickBindings.GetStringFromModifiers(modifiers)
	return GetStringFromModifiers(modifiers);
end

function C_Spell.GetMawPowerBorderAtlasBySpellID(spellID)
	local _rarityID, rarityAtlas = C_Spell.GetMawPowerRarityInfoBySpellID(spellID);
	return rarityAtlas;
end
