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

	PREVIEW_UNIT_TOKEN = "preview";

	TARGET_BORDER_COLOR = CreateColor(1, 1, 1);
	FOCUS_TARGET_BORDER_COLOR = CreateColor(1.0, 0.49, 0.039);

	AURA_ITEM_HEIGHT = 25;
	LARGE_HEALTH_BAR_HEIGHT = 20;
	SMALL_HEALTH_BAR_HEIGHT = 10;
	HEALTH_BAR_FONT_HEIGHT = 12;
	LARGE_CAST_BAR_HEIGHT = 16;
	SMALL_CAST_BAR_HEIGHT = 10;
	CAST_BAR_FONT_HEIGHT = 10;
	CAST_BAR_ICON_HEIGHT = 12;

	NAME_PLATE_SCALES =
	{
		[Enum.NamePlateSize.Small] = { horizontal = 0.75, vertical = 0.8, classification = 0.8, aura = 0.75, aggroHighlight = 1.0},
		[Enum.NamePlateSize.Medium] = { horizontal = 1.0, vertical = 1.0, classification = 1.0, aura = 1.0, aggroHighlight = 1.0},
		[Enum.NamePlateSize.Large] = { horizontal = 1.25, vertical = 1.25, classification = 1.25, aura = 1.25, aggroHighlight = 1.25 },
		[Enum.NamePlateSize.ExtraLarge] = { horizontal = 1.4, vertical = 1.4, classification = 1.4, aura = 1.4, aggroHighlight = 1.4 },
		[Enum.NamePlateSize.Huge] = { horizontal = 1.6, vertical = 1.6, classification = 1.6, aura = 1.6, aggroHighlight = 1.6 },
	};
};
