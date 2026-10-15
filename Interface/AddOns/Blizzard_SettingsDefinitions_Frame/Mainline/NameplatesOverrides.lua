NameplatesOverrides = {}

function NameplatesOverrides.GetNPCNamesOptionDefault()
	-- "3" is the NPC_NAMES_DROPDOWN_INTERACTIVE setting.
	return 3;
end

function NameplatesOverrides.GetNameplateStyleOptions()
	local container = Settings.CreateControlTextContainer();
	container:Add(Enum.NamePlateStyle.Modern, UNIT_NAMEPLATES_STYLE_MODERN);
	container:Add(Enum.NamePlateStyle.Thin, UNIT_NAMEPLATES_STYLE_THIN);
	container:Add(Enum.NamePlateStyle.Block, UNIT_NAMEPLATES_STYLE_BLOCK);
	container:Add(Enum.NamePlateStyle.HealthFocus, UNIT_NAMEPLATES_STYLE_HEALTH_FOCUS);
	container:Add(Enum.NamePlateStyle.CastFocus, UNIT_NAMEPLATES_STYLE_CAST_FOCUS);
	container:Add(Enum.NamePlateStyle.Legacy, UNIT_NAMEPLATES_STYLE_LEGACY);
	return container:GetData();
end

function NameplatesOverrides.ShowHighlightImportantCastsOption()
	return true;
end

function NameplatesOverrides.ShowRarityIconInfoDisplayOption()
	return true;
end

function NameplatesOverrides.ShowClassColorSetting()
	return false;
end

function NameplatesOverrides.ShowRealmOption()
	return true;
end

function NameplatesOverrides.AdjustNameplateSettings(category)
	-- Used by Classic for some Classic-only settings, such as Nameplate Distance.
end
