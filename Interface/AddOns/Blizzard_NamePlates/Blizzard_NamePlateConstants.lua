NamePlateConstants =
{
	INFO_DISPLAY_CVAR = "nameplateInfoDisplay";
	CAST_BAR_DISPLAY_CVAR = "nameplateCastBarDisplay";
	THREAT_DISPLAY_CVAR = "nameplateThreatDisplay";
	ENEMY_NPC_AURA_DISPLAY_CVAR = "nameplateEnemyNpcAuraDisplay";
	ENEMY_PLAYER_AURA_DISPLAY_CVAR = "nameplateEnemyPlayerAuraDisplay";
	FRIENDLY_PLAYER_AURA_DISPLAY_CVAR = "nameplateFriendlyPlayerAuraDisplay";
	SHOW_DEBUFFS_ON_FRIENDLY_CVAR = "nameplateShowDebuffsOnFriendly";
	DEBUFF_PADDING_CVAR = "nameplateDebuffPadding";
	AURA_SCALE_CVAR = "nameplateAuraScale";
	SIZE_CVAR = "nameplateSize";
	STYLE_CVAR = "nameplateStyle";
	SIMPLIFIED_TYPES_CVAR = "nameplateSimplifiedTypes";
	SOFT_TARGET_NAMEPLATE_SIZE_CVAR = "SoftTargetNameplateSize";
	SOFT_TARGET_ICON_ENEMY_CVAR = "SoftTargetIconEnemy";
	SOFT_TARGET_ICON_FRIEND_CVAR = "SoftTargetIconFriend";
	SOFT_TARGET_ICON_INTERACT_CVAR = "SoftTargetIconInteract";
	SHOW_FRIENDLY_NPCS_CVAR = "nameplateShowFriendlyNpcs";
	SHOW_ONLY_NAME_FOR_FRIENDLY_PLAYER_UNITS_CVAR = "nameplateShowOnlyNameForFriendlyPlayerUnits";
	USE_CLASS_COLOR_FOR_FRIENDLY_PLAYER_UNIT_NAMES_CVAR = "nameplateUseClassColorForFriendlyPlayerUnitNames";
	SHOW_ALL_PERSONAL_AURAS_CVAR = "nameplateShowAllPersonalAuras";
	FORCE_SHOW_UNIT_NAME_CVAR = "nameplateForceShowUnitName";

	PREVIEW_UNIT_TOKEN = "preview";

	AURA_ITEM_HEIGHT = 25;
	CAST_BAR_FONT_HEIGHT = 10;
	CAST_BAR_ICON_HEIGHT = 12;
	CAST_BAR_TO_HEALTH_BAR_SPACING = 2;
	HEALTH_BAR_FONT_HEIGHT = 12;
	HEALTH_BAR_TO_NAME_ABOVE_SPACING = 2;
	HORIZONTAL_INSET = 12; -- This is gap between the side edge of the NamePlate frame and the actual content (e.g., Cast Bar).
	LARGE_CAST_BAR_HEIGHT = 16;
	LARGE_HEALTH_BAR_HEIGHT = 20;
	LEVEL_ICON_HEIGHT = 15;
	LEVEL_ICON_WIDTH = 15;
	LEVEL_FONT_HEIGHT = 10;
	NAMEPLATE_WIDTH = 230;
	SMALL_CAST_BAR_HEIGHT = 10;
	SMALL_HEALTH_BAR_HEIGHT = 10;

	CLASSIC_BORDER_HEIGHT = 16;
	CLASSIC_BORDER_WIDTH = 128;
	CLASSIC_CAST_BAR_HEIGHT = 10;
	CLASSIC_CAST_BAR_ICON_HEIGHT = 14;
	CLASSIC_CAST_BAR_TO_HEALTH_BAR_SPACING = 4;
	CLASSIC_HEALTH_BAR_FONT_HEIGHT = 10;
	CLASSIC_HEALTH_BAR_HEIGHT = 10;
	CLASSIC_HEALTH_BAR_TO_NAME_ABOVE_SPACING = 4;
	CLASSIC_NAMEPLATE_WIDTH = 152;

	NAME_PLATE_SCALES =
	{
		[Enum.NamePlateSize.Small] = { horizontal = 0.75, vertical = 0.8, classification = 0.8, aura = 0.75, aggroHighlight = 1.0},
		[Enum.NamePlateSize.Medium] = { horizontal = 1.0, vertical = 1.0, classification = 1.0, aura = 1.0, aggroHighlight = 1.0},
		[Enum.NamePlateSize.Large] = { horizontal = 1.25, vertical = 1.25, classification = 1.25, aura = 1.25, aggroHighlight = 1.25 },
		[Enum.NamePlateSize.ExtraLarge] = { horizontal = 1.4, vertical = 1.4, classification = 1.4, aura = 1.4, aggroHighlight = 1.4 },
		[Enum.NamePlateSize.Huge] = { horizontal = 1.6, vertical = 1.6, classification = 1.6, aura = 1.6, aggroHighlight = 1.6 },
	};

	NAME_PLATE_SCALES_CLASSIC_STYLE = 	{
		-- The Classic NamePlate Style has a fixed border asset, so vertical and horizontal scales must be the same.
		[Enum.NamePlateSize.Small] = { horizontal = 0.8, vertical = 0.8, classification = 0.8, aura = 0.8, aggroHighlight = 1.0},
		[Enum.NamePlateSize.Medium] = { horizontal = 1.0, vertical = 1.0, classification = 1.0, aura = 1.0, aggroHighlight = 1.0},
		[Enum.NamePlateSize.Large] = { horizontal = 1.25, vertical = 1.25, classification = 1.25, aura = 1.25, aggroHighlight = 1.25 },
		[Enum.NamePlateSize.ExtraLarge] = { horizontal = 1.4, vertical = 1.4, classification = 1.4, aura = 1.4, aggroHighlight = 1.4 },
		[Enum.NamePlateSize.Huge] = { horizontal = 1.6, vertical = 1.6, classification = 1.6, aura = 1.6, aggroHighlight = 1.6 },
	};

	NAME_ANCHOR_STYLES =
	{
		["InsideHealthBar"] = 1,
		["AboveHealthBar"] = 2,
		["CenteredAboveHealthBar"] = 3, -- Used by the Classic Style.
	};
};
