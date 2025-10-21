local Spell =
{
	Name = "Spell",
	Type = "System",
	Namespace = "C_Spell",

	Functions =
	{
		{
			Name = "CancelSpellByID",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DoesSpellExist",
			Type = "Function",
			Documentation = { "Returns true if the spell exists, regardless of whether the player has learned it" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false, Documentation = { "Spell ID, name, name(subtext), or link; Using name will always check for an override on that spell" } },
			},

			Returns =
			{
				{ Name = "spellExists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EnableSpellRangeCheck",
			Type = "Function",
			Documentation = { "Used in conjunction with SpellRangeCheckUpdate to inform the UI when a spell goes in or out of range with the current target." },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
				{ Name = "enable", Type = "bool", Nilable = false, Documentation = { "True if changes in range for the spell should dispatch SpellRangeCheckUpdate. False if the spell no longer needs the event." } },
			},
		},
		{
			Name = "GetSchoolString",
			Type = "Function",

			Arguments =
			{
				{ Name = "schoolMask", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetSpellCastCount",
			Type = "Function",
			Documentation = { "Returns number of times a spell can be cast, typically based on availability of things like required reagent items; Returns 0 if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "castCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellCharges",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns a table of info about the charges of a charge-accumulating spell; May return nil if spell is not found or is not charge-based" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "chargeInfo", Type = "SpellChargeInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellCooldown",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nil if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellCooldownInfo", Type = "SpellCooldownInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellDescription",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nil if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = false, Documentation = { "May be empty if spell's data isn't loaded yet; Listen for SPELL_TEXT_UPDATE event, or use SpellMixin to load asynchronously" } },
			},
		},
		{
			Name = "GetSpellIDForSpellIdentifier",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Meant primarily for getting a spell id from a spell name or link; Returns nothing if spell does not exist" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false, Documentation = { "Spell ID, name, name(subtext), or link; Using name will always check for an override on that spell; If passed a spell ID, will return same id as was passed" } },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellInfo",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nil if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false, Documentation = { "Spell ID, name, name(subtext), or link; Using name will always check for an override on that spell" } },
			},

			Returns =
			{
				{ Name = "spellInfo", Type = "SpellInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellLevelLearned",
			Type = "Function",
			Documentation = { "Returns the level the spell is learned at; May return a different value if the player is currently Level Linked with another player" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "levelLearned", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellLink",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nil if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
				{ Name = "glyphID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "spellLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSpellName",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nil if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSpellPowerCost",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns a table containing one or more SpellPowerCostInfos, one for each power type this spell costs; May return nil if spell is not found or has no resource costs" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerCosts", Type = "table", InnerType = "SpellPowerCostInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellQueueWindow",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellSkillLineAbilityRank",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns the rank of a spell that corresponds to an ability within a ranked SkillLine (ex: a crafting Recipe); Returns nil if spell is not found, or isn't part of a ranked SkillLine" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "rank", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellSubtext",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nil if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "subtext", Type = "string", Nilable = false, Documentation = { "May be empty if spell's data isn't loaded yet; Listen for SPELL_TEXT_UPDATE event, or use SpellMixin to load asynchronously" } },
			},
		},
		{
			Name = "GetSpellTexture",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns nothing if spell is not found" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "iconID", Type = "fileID", Nilable = false },
				{ Name = "originalIconID", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "IsAutoAttackSpell",
			Type = "Function",
			Documentation = { "Returns true if the spell is the player's melee Auto Attack spell" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAutoAttack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAutoRepeatSpell",
			Type = "Function",
			Documentation = { "Returns true if the spell is an auto repeat player spell" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAutoRepeat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCurrentSpell",
			Type = "Function",
			Documentation = { "Returns true if the spell is currently being cast or is queued to be cast" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCurrentSpell", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRangedAutoAttackSpell",
			Type = "Function",
			Documentation = { "Returns true if the spell is the player's ranged Auto Attack spell (ex: Shoot, Auto Shot, etc)" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRangedAutoAttack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellDataCached",
			Type = "Function",
			Documentation = { "Returns true if data for the spell has already been loaded and cached this session" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCached", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellHarmful",
			Type = "Function",
			Documentation = { "Returns true if the spell can be cast on hostile targets" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHarmful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellHelpful",
			Type = "Function",
			Documentation = { "Returns true if the spell can be cast on the player or other friendly targets" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHelpful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellInRange",
			Type = "Function",
			Documentation = { "Returns true if the current target is within range of the spell; False if out of range; Nil if range check was invalid" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
				{ Name = "targetUnit", Type = "UnitToken", Nilable = true, Documentation = { "Optional specific target; If not supplied, player's current target (if any) will be used" } },
			},

			Returns =
			{
				{ Name = "inRange", Type = "bool", Nilable = true, Documentation = { "May be nil if the range check was invalid, ie due to unknown/invalid spell, missing/invalid target, etc" } },
			},
		},
		{
			Name = "IsSpellPassive",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPassive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellUsable",
			Type = "Function",
			Documentation = { "Returns whether the spell is currently castable; Typically based on things like learned status, required resources, etc" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "insufficientPower", Type = "bool", Nilable = false, Documentation = { "True if spell is specifically unusable due to insufficient power (ie MANA, RAGE, etc)" } },
			},
		},
		{
			Name = "PickupSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},
		},
		{
			Name = "RequestLoadSpellData",
			Type = "Function",
			Documentation = { "Requests data for the spell be loaded; Listen for SPELL_DATA_LOAD_RESULT to be notified when load is finished" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},
		},
		{
			Name = "SpellHasRange",
			Type = "Function",
			Documentation = { "Returns true if the spell has a min and/or max range greater than 0" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasRange", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TargetSpellIsEnchanting",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnchanting", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TargetSpellJumpsUpgradeTrack",
			Type = "Function",

			Returns =
			{
				{ Name = "jumpsUpgradeTrack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TargetSpellReplacesBonusTree",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EnchantSpellCompleted",
			Type = "Event",
			LiteralName = "ENCHANT_SPELL_COMPLETED",
			Payload =
			{
				{ Name = "successful", Type = "bool", Nilable = false },
				{ Name = "enchantedItem", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = true },
			},
		},
		{
			Name = "EnchantSpellSelected",
			Type = "Event",
			LiteralName = "ENCHANT_SPELL_SELECTED",
		},
		{
			Name = "SpellDataLoadResult",
			Type = "Event",
			LiteralName = "SPELL_DATA_LOAD_RESULT",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SpellRangeCheckUpdate",
			Type = "Event",
			LiteralName = "SPELL_RANGE_CHECK_UPDATE",
			Documentation = { "Used in conjunction with EnableSpellRangeCheck to inform the UI when a spell goes in or out of range with the current target." },
			Payload =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
				{ Name = "isInRange", Type = "bool", Nilable = false, Documentation = { "Whether or not the current target is in range of the spell. Should not be used if the 'checksRange' parameter is false." } },
				{ Name = "checksRange", Type = "bool", Nilable = false, Documentation = { "Can be false if a range check was not made for any reason, for example there is not a current target." } },
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
			Name = "UpdateSpellTargetItemContext",
			Type = "Event",
			LiteralName = "UPDATE_SPELL_TARGET_ITEM_CONTEXT",
		},
	},

	Tables =
	{
		{
			Name = "SpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "iconID", Type = "fileID", Nilable = false, Documentation = { "Icon for this spell; If spell has been overriden, this may be the icon for the overriding spell; See originalIconID for spell's non-overriden icon" } },
				{ Name = "originalIconID", Type = "fileID", Nilable = false },
				{ Name = "castTime", Type = "number", Nilable = false },
				{ Name = "minRange", Type = "number", Nilable = false },
				{ Name = "maxRange", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Spell);