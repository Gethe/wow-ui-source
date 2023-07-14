local SpellBook =
{
	Name = "SpellBook",
	Type = "System",
	Namespace = "C_SpellBook",

	Functions =
	{
		{
			Name = "ContainsAnyDisenchantSpell",
			Type = "Function",

			Returns =
			{
				{ Name = "contains", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCurrentLevelSpells",
			Type = "Function",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetDeadlyDebuffInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "deadlyDebuffInfo", Type = "DeadlyDebuffInfo", Nilable = false },
			},
		},
		{
			Name = "GetOverrideSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "spec", Type = "number", Nilable = false, Default = 0 },
				{ Name = "onlyKnown", Type = "bool", Nilable = false, Default = true },
				{ Name = "ignoreOverrideSpellID", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "overrideSpellID", Type = "number", Nilable = false, Documentation = { "Returns the spellID passed in if there is no override" } },
			},
		},
		{
			Name = "GetSkillLineIndexByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetSpellInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellInfo", Type = "SpellInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellLinkFromSpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "glyphID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "spellLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTrackedNameplateCooldownSpells",
			Type = "Function",

			Returns =
			{
				{ Name = "spellIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsSpellDisabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CurrentSpellCastChanged",
			Type = "Event",
			LiteralName = "CURRENT_SPELL_CAST_CHANGED",
			Payload =
			{
				{ Name = "cancelledCast", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LearnedSpellInTab",
			Type = "Event",
			LiteralName = "LEARNED_SPELL_IN_TAB",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "skillInfoIndex", Type = "number", Nilable = false },
				{ Name = "isGuildPerkSpell", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MaxSpellStartRecoveryOffsetChanged",
			Type = "Event",
			LiteralName = "MAX_SPELL_START_RECOVERY_OFFSET_CHANGED",
			Payload =
			{
				{ Name = "clampedNewQueueWindowMs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerTotemUpdate",
			Type = "Event",
			LiteralName = "PLAYER_TOTEM_UPDATE",
			Payload =
			{
				{ Name = "totemSlot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SpellFlyoutUpdate",
			Type = "Event",
			LiteralName = "SPELL_FLYOUT_UPDATE",
			Payload =
			{
				{ Name = "flyoutID", Type = "number", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "isLearned", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "SpellPushedToActionbar",
			Type = "Event",
			LiteralName = "SPELL_PUSHED_TO_ACTIONBAR",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "page", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpellTextUpdate",
			Type = "Event",
			LiteralName = "SPELL_TEXT_UPDATE",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpellUpdateCharges",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_CHARGES",
		},
		{
			Name = "SpellUpdateCooldown",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_COOLDOWN",
		},
		{
			Name = "SpellUpdateIcon",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_ICON",
		},
		{
			Name = "SpellUpdateUsable",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_USABLE",
		},
		{
			Name = "SpellsChanged",
			Type = "Event",
			LiteralName = "SPELLS_CHANGED",
		},
		{
			Name = "StartAutorepeatSpell",
			Type = "Event",
			LiteralName = "START_AUTOREPEAT_SPELL",
		},
		{
			Name = "StopAutorepeatSpell",
			Type = "Event",
			LiteralName = "STOP_AUTOREPEAT_SPELL",
		},
		{
			Name = "UnitSpellcastSent",
			Type = "Event",
			LiteralName = "UNIT_SPELLCAST_SENT",
			Payload =
			{
				{ Name = "unit", Type = "cstring", Nilable = false },
				{ Name = "target", Type = "cstring", Nilable = false },
				{ Name = "castGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UpdateShapeshiftCooldown",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_COOLDOWN",
		},
		{
			Name = "UpdateShapeshiftForm",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_FORM",
		},
		{
			Name = "UpdateShapeshiftForms",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_FORMS",
		},
		{
			Name = "UpdateShapeshiftUsable",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_USABLE",
		},
	},

	Tables =
	{
		{
			Name = "DeadlyDebuffInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "criticalTimeRemainingMs", Type = "number", Nilable = true },
				{ Name = "criticalStacks", Type = "number", Nilable = true },
				{ Name = "priority", Type = "number", Nilable = false },
				{ Name = "warningText", Type = "string", Nilable = false },
				{ Name = "soundKitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "iconID", Type = "fileID", Nilable = false },
				{ Name = "castTime", Type = "number", Nilable = false },
				{ Name = "minRange", Type = "number", Nilable = false },
				{ Name = "maxRange", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellBook);