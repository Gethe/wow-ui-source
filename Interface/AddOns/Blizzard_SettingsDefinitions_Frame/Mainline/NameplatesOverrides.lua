NameplatesOverrides = {}

NameplatesOverrides.NPCNamesDefaultValue = 3; -- This is the NPC_NAMES_DROPDOWN_INTERACTIVE setting.

function NameplatesOverrides.ShowClassicStyleOption()
	return false;
end

function NameplatesOverrides.ShowHighlightImportantCastsOption()
	return true;
end

function NameplatesOverrides.ShowClassColorSetting()
	return false;
end

function NameplatesOverrides.AdjustNameplateSettings(category)
	-- Used by Classic for some Classic-only settings, such as Nameplate Distance.
end
