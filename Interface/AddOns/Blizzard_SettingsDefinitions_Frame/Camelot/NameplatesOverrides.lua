NameplatesOverrides = {}

function NameplatesOverrides.GetNPCNamesOptionDefault()
	return C_GameRules.GetForeverExperiencePreset() == Enum.ForeverExperiencePreset.Classic and 5 or 3;
end

function NameplatesOverrides.GetNameplateStyleOptions()
	local container = Settings.CreateControlTextContainer();
	container:Add(Enum.NamePlateStyle.Thin, UNIT_NAMEPLATES_STYLE_THIN); -- Default
	container:Add(Enum.NamePlateStyle.Modern, UNIT_NAMEPLATES_STYLE_MODERN); -- Large
	container:Add(Enum.NamePlateStyle.Block, UNIT_NAMEPLATES_STYLE_BLOCK); -- Block
	container:Add(Enum.NamePlateStyle.CastFocus, UNIT_NAMEPLATES_STYLE_CAST_FOCUS); --Cast Focus
	return container:GetData();
end

function NameplatesOverrides.ShowHighlightImportantCastsOption()
	return true;
end

function NameplatesOverrides.ShowRarityIconInfoDisplayOption()
	-- Nameplates don't show Rarity icons in Camelot so this option is not needed.
	return false;
end

function NameplatesOverrides.ShowClassColorSetting()
	return true;
end

function NameplatesOverrides.ShowRealmOption()
	return false;
end

function NameplatesOverrides.AdjustNameplateSettings(category)
	-- Used by Classic for some Classic-only settings, such as Nameplate Distance.
end
