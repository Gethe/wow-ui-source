-- These values aren't actually part of the enum
-- They exist so that disabled states can be managed using the same category enums
-- There are checks to ensure that they don't match any of the pre-existing enum values
Enum.CooldownViewerCategory.HiddenSpell = -1;
Enum.CooldownViewerCategory.HiddenAura = -2;

function CooldownViewerUtil_IsDisabledCategory(category)
	return category == Enum.CooldownViewerCategory.HiddenSpell or category == Enum.CooldownViewerCategory.HiddenAura;
end
