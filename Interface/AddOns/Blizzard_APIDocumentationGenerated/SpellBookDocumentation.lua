local SpellBook =
{
	Name = "SpellBook",
	Type = "System",
	Namespace = "C_SpellBook",
	Environment = "All",

	Functions =
	{
		{
			Name = "FindBaseSpellByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "baseSpellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "FindFlyoutSlotBySpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "flyoutSlot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "FindSpellOverrideByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "overrideSpellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "HasPetSpells",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nothing if player has no pet spells" },

			Returns =
			{
				{ Name = "numPetSpells", Type = "number", Nilable = false },
				{ Name = "petNameToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsSpellInSpellBook",
			Type = "Function",
			Documentation = { "Returns true if a spell should be found in the spellbook. This function can also return true for spells that aren't known, such as override spells granted by an aura linked to class talents" },

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "spellBank", Type = "SpellBookSpellBank", Nilable = false, Default = "Player" },
				{ Name = "includeOverrides", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "isInSpellBook", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellKnown",
			Type = "Function",
			Documentation = { "Returns true if a player knows a spell. This function can also return true for spells that aren't in the spellbook, such as temporarily-granted abilities" },

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "spellBank", Type = "SpellBookSpellBank", Nilable = false, Default = "Player" },
			},

			Returns =
			{
				{ Name = "isKnown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellKnownOrInSpellBook",
			Type = "Function",
			Documentation = { "Returns true if a spell is considered to be known or present in the spellbook" },

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "spellBank", Type = "SpellBookSpellBank", Nilable = false, Default = "Player" },
				{ Name = "includeOverrides", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "isKnownOrInSpellBook", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CurrentSpellCastChanged",
			Type = "Event",
			LiteralName = "CURRENT_SPELL_CAST_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "cancelledCast", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LearnedSpellInSkillLine",
			Type = "Event",
			LiteralName = "LEARNED_SPELL_IN_SKILL_LINE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "clampedNewQueueWindowMs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerTotemUpdate",
			Type = "Event",
			LiteralName = "PLAYER_TOTEM_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "totemSlot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SpellFlyoutUpdate",
			Type = "Event",
			LiteralName = "SPELL_FLYOUT_UPDATE",
			SynchronousEvent = true,
			UniqueEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "page", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpellPushedToFlyoutOnActionbar",
			Type = "Event",
			LiteralName = "SPELL_PUSHED_TO_FLYOUT_ON_ACTIONBAR",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "flyoutSlot", Type = "luaIndex", Nilable = false },
				{ Name = "flyoutPage", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SpellUpdateCharges",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_CHARGES",
			SynchronousEvent = true,
			UniqueEvent = true,
		},
		{
			Name = "SpellUpdateCooldown",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_COOLDOWN",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = true, Documentation = { "Can be a base spell or an override spell. A nil value indicates that all cooldowns should be updated, rather than just a specific one." } },
				{ Name = "baseSpellID", Type = "number", Nilable = true, Documentation = { "Will be set to the base spell if the spellID parameter is an override spell." } },
				{ Name = "category", Type = "number", Nilable = true, Documentation = { "If the spellID parameter is set, the cooldown category of the spell. A nil value indicates the spell does not have a cooldown category." } },
				{ Name = "startRecoveryCategory", Type = "number", Nilable = true, Documentation = { "If the spellID parameter is set, the cooldown start recovery category of the spell. A nil value indicates the spell does not have a cooldown start recovery category." } },
			},
		},
		{
			Name = "SpellUpdateIcon",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_ICON",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = true, Documentation = { "Always refers to the base spell. A nil value indicates that all icons should be updated, rather than just a specific one." } },
			},
		},
		{
			Name = "SpellUpdateUsable",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_USABLE",
			UniqueEvent = true,
		},
		{
			Name = "SpellUpdateUses",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_USES",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false, Documentation = { "Can be a base spell or override spell." } },
				{ Name = "baseSpellID", Type = "number", Nilable = true, Documentation = { "Will be set to the base spell if the spellID parameter is an override spell." } },
			},
		},
		{
			Name = "SpellsChanged",
			Type = "Event",
			LiteralName = "SPELLS_CHANGED",
			UniqueEvent = true,
		},
		{
			Name = "StartAutorepeatSpell",
			Type = "Event",
			LiteralName = "START_AUTOREPEAT_SPELL",
			SynchronousEvent = true,
		},
		{
			Name = "StopAutorepeatSpell",
			Type = "Event",
			LiteralName = "STOP_AUTOREPEAT_SPELL",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateShapeshiftCooldown",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_COOLDOWN",
			UniqueEvent = true,
		},
		{
			Name = "UpdateShapeshiftForm",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_FORM",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateShapeshiftForms",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_FORMS",
			UniqueEvent = true,
		},
		{
			Name = "UpdateShapeshiftUsable",
			Type = "Event",
			LiteralName = "UPDATE_SHAPESHIFT_USABLE",
			UniqueEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SpellBook);