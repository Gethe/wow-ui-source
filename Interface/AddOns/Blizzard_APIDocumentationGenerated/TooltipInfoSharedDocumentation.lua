local TooltipInfoShared =
{
	Tables =
	{
		{
			Name = "TooltipDataLineType",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 0,
			MaxValue = 14,
			Fields =
			{
				{ Name = "None", Type = "TooltipDataLineType", EnumValue = 0 },
				{ Name = "Blank", Type = "TooltipDataLineType", EnumValue = 1 },
				{ Name = "UnitName", Type = "TooltipDataLineType", EnumValue = 2 },
				{ Name = "GemSocket", Type = "TooltipDataLineType", EnumValue = 3 },
				{ Name = "AzeriteEssenceSlot", Type = "TooltipDataLineType", EnumValue = 4 },
				{ Name = "AzeriteEssencePower", Type = "TooltipDataLineType", EnumValue = 5 },
				{ Name = "LearnableSpell", Type = "TooltipDataLineType", EnumValue = 6 },
				{ Name = "UnitThreat", Type = "TooltipDataLineType", EnumValue = 7 },
				{ Name = "QuestObjective", Type = "TooltipDataLineType", EnumValue = 8 },
				{ Name = "AzeriteItemPowerDescription", Type = "TooltipDataLineType", EnumValue = 9 },
				{ Name = "RuneforgeLegendaryPowerDescription", Type = "TooltipDataLineType", EnumValue = 10 },
				{ Name = "SellPrice", Type = "TooltipDataLineType", EnumValue = 11 },
				{ Name = "ProfessionCraftingQuality", Type = "TooltipDataLineType", EnumValue = 12 },
				{ Name = "SpellName", Type = "TooltipDataLineType", EnumValue = 13 },
				{ Name = "CurrencyTotal", Type = "TooltipDataLineType", EnumValue = 14 },
			},
		},
		{
			Name = "TooltipDataType",
			Type = "Enumeration",
			NumValues = 27,
			MinValue = 0,
			MaxValue = 26,
			Fields =
			{
				{ Name = "Item", Type = "TooltipDataType", EnumValue = 0 },
				{ Name = "Spell", Type = "TooltipDataType", EnumValue = 1 },
				{ Name = "Unit", Type = "TooltipDataType", EnumValue = 2 },
				{ Name = "Corpse", Type = "TooltipDataType", EnumValue = 3 },
				{ Name = "Object", Type = "TooltipDataType", EnumValue = 4 },
				{ Name = "Currency", Type = "TooltipDataType", EnumValue = 5 },
				{ Name = "BattlePet", Type = "TooltipDataType", EnumValue = 6 },
				{ Name = "UnitAura", Type = "TooltipDataType", EnumValue = 7 },
				{ Name = "AzeriteEssence", Type = "TooltipDataType", EnumValue = 8 },
				{ Name = "CompanionPet", Type = "TooltipDataType", EnumValue = 9 },
				{ Name = "Mount", Type = "TooltipDataType", EnumValue = 10 },
				{ Name = "PetAction", Type = "TooltipDataType", EnumValue = 11 },
				{ Name = "Achievement", Type = "TooltipDataType", EnumValue = 12 },
				{ Name = "EnhancedConduit", Type = "TooltipDataType", EnumValue = 13 },
				{ Name = "EquipmentSet", Type = "TooltipDataType", EnumValue = 14 },
				{ Name = "InstanceLock", Type = "TooltipDataType", EnumValue = 15 },
				{ Name = "PvPBrawl", Type = "TooltipDataType", EnumValue = 16 },
				{ Name = "RecipeRankInfo", Type = "TooltipDataType", EnumValue = 17 },
				{ Name = "Totem", Type = "TooltipDataType", EnumValue = 18 },
				{ Name = "Toy", Type = "TooltipDataType", EnumValue = 19 },
				{ Name = "CorruptionCleanser", Type = "TooltipDataType", EnumValue = 20 },
				{ Name = "MinimapMouseover", Type = "TooltipDataType", EnumValue = 21 },
				{ Name = "Flyout", Type = "TooltipDataType", EnumValue = 22 },
				{ Name = "Quest", Type = "TooltipDataType", EnumValue = 23 },
				{ Name = "QuestPartyProgress", Type = "TooltipDataType", EnumValue = 24 },
				{ Name = "Macro", Type = "TooltipDataType", EnumValue = 25 },
				{ Name = "Debug", Type = "TooltipDataType", EnumValue = 26 },
			},
		},
		{
			Name = "TooltipComparisonLine",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "color", Type = "table", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "TooltipData",
			Type = "Structure",
			Fields =
			{
				{ Name = "lines", Type = "table", InnerType = "TooltipDataLine", Nilable = false },
				{ Name = "args", Type = "table", InnerType = "TooltipDataArg", Nilable = false },
			},
		},
		{
			Name = "TooltipDataArg",
			Type = "Structure",
			Fields =
			{
				{ Name = "field", Type = "string", Nilable = false },
				{ Name = "stringVal", Type = "string", Nilable = true },
				{ Name = "intVal", Type = "number", Nilable = true },
				{ Name = "floatVal", Type = "number", Nilable = true },
				{ Name = "boolVal", Type = "bool", Nilable = true },
				{ Name = "colorVal", Type = "table", Mixin = "ColorMixin", Nilable = true },
				{ Name = "guidVal", Type = "string", Nilable = true },
			},
		},
		{
			Name = "TooltipDataLine",
			Type = "Structure",
			Fields =
			{
				{ Name = "args", Type = "table", InnerType = "TooltipDataArg", Nilable = false },
			},
		},
		{
			Name = "TooltipDataLineText",
			Type = "Structure",
			Fields =
			{
				{ Name = "leftText", Type = "string", Nilable = false },
				{ Name = "rightText", Type = "string", Nilable = true },
				{ Name = "leftColor", Type = "table", Mixin = "ColorMixin", Nilable = true },
				{ Name = "rightColor", Type = "table", Mixin = "ColorMixin", Nilable = true },
				{ Name = "wrapped", Type = "bool", Nilable = true },
				{ Name = "leftOffsetPixels", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TooltipInfoShared);