local SpellBook =
{
	Name = "SpellBook",
	Type = "System",
	Namespace = "C_SpellBook",

	Functions =
	{
		{
			Name = "CastSpellBookItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
				{ Name = "targetSelf", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "ContainsAnyDisenchantSpell",
			Type = "Function",

			Returns =
			{
				{ Name = "contains", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FindSpellBookSlotForSpell",
			Type = "Function",
			Documentation = { "If found, returns the first slot position of a SpellBookItem matching the specified spell and criteria" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
				{ Name = "includeHidden", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, search includes SpellBookItems that are hidden from the SpellBook UI (ex: spells that have been replaced, are also in a Flyout, etc)" } },
				{ Name = "includeFlyouts", Type = "bool", Nilable = false, Default = true, Documentation = { "If true, search includes Flyout SpellBookItems containing the specified spell" } },
				{ Name = "includeFutureSpells", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, search includes SpellBookItems for spells that have not yet been learned" } },
				{ Name = "includeOffSpec", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, search includes SpellBookItems belonging to non-active specializations; If spell is in active and inactive spec, the active spec slot will always be returned" } },
			},

			Returns =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
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
			Name = "GetNumSpellBookSkillLines",
			Type = "Function",

			Returns =
			{
				{ Name = "numSpellBookSkillLines", Type = "number", Nilable = false },
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
			Name = "GetSpellBookItemAutoCast",
			Type = "Function",
			Documentation = { "Returns nothing if item doesn't exist or isn't a spell" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "autoCastAllowed", Type = "bool", Nilable = false, Documentation = { "True if this spell is allowed to be auto-cast" } },
				{ Name = "autoCastEnabled", Type = "bool", Nilable = false, Documentation = { "True if auto-casting this spell is currently enabled (usually by the player)" } },
			},
		},
		{
			Name = "GetSpellBookItemCooldown",
			Type = "Function",
			Documentation = { "Returns nil if item doesn't exist or if this kind of item doesn't display cooldowns (ex: future or offspec spells)" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellCooldownInfo", Type = "SpellCooldownInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellBookItemInfo", Type = "SpellBookItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemLevelLearned",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "levelLearned", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
				{ Name = "glyphID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "spellLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemLossOfControlCooldown",
			Type = "Function",
			Documentation = { "Returns nil if item doesn't exist or if this kind of item doesn't display cooldowns (ex: future or offspec spells)" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemName",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "subName", Type = "string", Nilable = false, Documentation = { "May be empty if spell's data isn't loaded yet; Listen for SPELL_TEXT_UPDATE event, or use SpellMixin to load asynchronously" } },
			},
		},
		{
			Name = "GetSpellBookItemTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "iconID", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemTradeSkillLink",
			Type = "Function",
			Documentation = { "Returns nil if SpellBookItem is not associated with a trade skill" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemType",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemType", Type = "SpellBookItemType", Nilable = false },
				{ Name = "actionID", Type = "number", Nilable = false, Documentation = { "Represents a spellID for spells, flyoutID for flyouts, or petActionID for pet actions" } },
				{ Name = "spellID", Type = "number", Nilable = true, Documentation = { "May be nil if item is not a spell; may be different from actionID if item is an overriden spell" } },
			},
		},
		{
			Name = "GetSpellBookSkillLineInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineInfo", Type = "SpellBookSkillLineInfo", Nilable = false },
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
			Name = "HasPetSpells",
			Type = "Function",
			Documentation = { "Returns nothing if player has no pet spells" },

			Returns =
			{
				{ Name = "numPetSpells", Type = "number", Nilable = false },
				{ Name = "petNameToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsSpellBookItemPassive",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPassive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PickupSpellBookItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},
		},
		{
			Name = "SetSpellBookItemAutoCastEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleSpellBookItemAutoCast",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
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
			Name = "LearnedSpellInSkillLine",
			Type = "Event",
			LiteralName = "LEARNED_SPELL_IN_SKILL_LINE",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "skillLineIndex", Type = "luaIndex", Nilable = false },
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
			Name = "SpellBookItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "actionID", Type = "number", Nilable = false, Documentation = { "Represents a spellID for spells, flyoutID for flyouts, or petActionID for pet actions" } },
				{ Name = "spellID", Type = "number", Nilable = true, Documentation = { "May be nil if item is not a spell; may be different from actionID if spell is overriden" } },
				{ Name = "itemType", Type = "SpellBookItemType", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "subName", Type = "string", Nilable = false, Documentation = { "May be empty if flyout, or if spell's data isn't loaded yet; Listen for SPELL_TEXT_UPDATE event, or use SpellMixin to load asynchronously" } },
				{ Name = "iconID", Type = "fileID", Nilable = false },
				{ Name = "isPassive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SpellBookSkillLineInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "iconID", Type = "fileID", Nilable = false },
				{ Name = "itemIndexOffset", Type = "number", Nilable = false, Documentation = { "This value + 1 is the first Spell Book Item slotIndex within this skill line" } },
				{ Name = "numSpellBookItems", Type = "number", Nilable = false },
				{ Name = "isGuild", Type = "bool", Nilable = false },
				{ Name = "shouldHide", Type = "bool", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = true, Documentation = { "Will be nil if this skill line is not associated with a specialization" } },
				{ Name = "offSpecID", Type = "number", Nilable = true, Documentation = { "Will be nil if this skill line is not associated with a non-active specialization" } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellBook);