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
				{ Name = "targetSelf", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, spell will target the current player; Otherwise, targets the player's current target" } },
			},
		},
		{
			Name = "ContainsAnyDisenchantSpell",
			Type = "Function",
			Documentation = { "Returns true if player knows any Disenchant spells" },

			Returns =
			{
				{ Name = "contains", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FindSpellBookSlotForSpell",
			Type = "Function",
			MayReturnNothing = true,
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
			MayReturnNothing = true,
			Documentation = { "Returns general, class, and active spec spells that are learned at the specified level" },

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
				{ Name = "skillIndex", Type = "luaIndex", Nilable = true, Documentation = { "Will be nil if the specified SkillLine could not be found, or if it is not one of the player's tracked skill lines" } },
			},
		},
		{
			Name = "GetSpellBookItemAutoCast",
			Type = "Function",
			MayReturnNothing = true,
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
			Name = "GetSpellBookItemCastCount",
			Type = "Function",
			Documentation = { "Returns number of times a SpellBookItem can be cast, typically based on availability of things like required reagent items; Always returns 0 if item is not found or is not a spell" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "castCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemCharges",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns a table of info about the charges of a charge-accumulating SpellBookItem; May return nil if item is not found or is not charge-based" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "chargeInfo", Type = "SpellChargeInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemCooldown",
			Type = "Function",
			MayReturnNothing = true,
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
			Name = "GetSpellBookItemDescription",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = false, Documentation = { "May be empty if spell's data isn't loaded yet; Listen for SPELL_TEXT_UPDATE event, or use SpellMixin to load asynchronously" } },
			},
		},
		{
			Name = "GetSpellBookItemInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			Documentation = { "Returns the level the spell is learned at; May return a different value if the player is currently Level Linked with another player; Returns 0 if item is not a Spell" },

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
			MayReturnNothing = true,

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
			MayReturnNothing = true,
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
			MayReturnNothing = true,

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
			Name = "GetSpellBookItemPowerCost",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Returns a table containing one or more SpellPowerCostInfos, one for each power type a SpellBookItem costs; May return nil if item is not found or has no resource costs" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerCosts", Type = "table", InnerType = "SpellPowerCostInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellBookItemSkillLineIndex",
			Type = "Function",
			Documentation = { "Get the index of the SkillLine this SpellBookItem is part of" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineIndex", Type = "luaIndex", Nilable = true, Documentation = { "Will be nil if the specified SpellBookItem doesn't exist or isn't part of a SkillLine" } },
			},
		},
		{
			Name = "GetSpellBookItemTexture",
			Type = "Function",
			MayReturnNothing = true,

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
			MayReturnNothing = true,
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
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemType", Type = "SpellBookItemType", Nilable = false },
				{ Name = "actionID", Type = "number", Nilable = false, Documentation = { "Represents a base spellID for spells, flyoutID for flyouts, or petActionID for pet actions" } },
				{ Name = "spellID", Type = "number", Nilable = true, Documentation = { "May be nil if item is not a spell; Will be the overriding spellID if spell is overriden, otherwise will match actionID" } },
			},
		},
		{
			Name = "GetSpellBookSkillLineInfo",
			Type = "Function",
			MayReturnNothing = true,

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
			Name = "IsAutoAttackSpellBookItem",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookItem is the player's melee Auto Attack spell" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAutoAttack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsClassTalentSpellBookItem",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookItem comes from a Class Talent" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isClassTalent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPvPTalentSpellBookItem",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookItem comes from a PvP Talent" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPvPTalent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRangedAutoAttackSpellBookItem",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookItem is the player's ranged Auto Attack spell (ex: Shoot, Auto Shot, etc)" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRangedAutoAttack", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellBookItemHarmful",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookIem can be cast on hostile targets" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHarmful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellBookItemHelpful",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookIem can be cast on the player or other friendly targets" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isHelpful", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellBookItemInRange",
			Type = "Function",
			Documentation = { "Returns true if the current target is within range of the SpellBookIem; False if out of range; Nil if range check was invalid" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
				{ Name = "targetUnit", Type = "UnitToken", Nilable = true, Documentation = { "Optional specific target; If not supplied, player's current target (if any) will be used" } },
			},

			Returns =
			{
				{ Name = "inRange", Type = "bool", Nilable = true, Documentation = { "May be nil if the range check was invalid, ie due to unknown/invalid spell, missing/invalid target, etc" } },
			},
		},
		{
			Name = "IsSpellBookItemOffSpec",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookItem belongs to a non-active class specialization" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isOffSpec", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellBookItemPassive",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookItem is a passive spell; Will always return false if it is not a spell" },

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
			Name = "IsSpellBookItemUsable",
			Type = "Function",
			Documentation = { "Returns whether the SpellBookIem is currently castable; Typically based on things like learned status, required resources, etc" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "insufficientPower", Type = "bool", Nilable = false, Documentation = { "True if SpellBookIem is specifically unusable due to insufficient power (ie MANA, RAGE, etc)" } },
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
			Name = "SpellBookItemHasRange",
			Type = "Function",
			Documentation = { "Returns true if the SpellBookIem has a min and/or max range greater than 0; Will always return false if it is not a spell" },

			Arguments =
			{
				{ Name = "spellBookItemSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "spellBookItemSpellBank", Type = "SpellBookSpellBank", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasRange", Type = "bool", Nilable = false },
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
			Name = "SpellPushedToFlyoutOnActionbar",
			Type = "Event",
			LiteralName = "SPELL_PUSHED_TO_FLYOUT_ON_ACTIONBAR",
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
		},
		{
			Name = "SpellUpdateCooldown",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_COOLDOWN",
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
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = true, Documentation = { "Always refers to the base spell. A nil value indicates that all icons should be updated, rather than just a specific one." } },
			},
		},
		{
			Name = "SpellUpdateUsable",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_USABLE",
		},
		{
			Name = "SpellUpdateUses",
			Type = "Event",
			LiteralName = "SPELL_UPDATE_USES",
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
				{ Name = "actionID", Type = "number", Nilable = false, Documentation = { "Represents a base spellID for spells, flyoutID for flyouts, or petActionID for pet actions" } },
				{ Name = "spellID", Type = "number", Nilable = true, Documentation = { "May be nil if item is not a spell; Will be the overriding spellID if spell is overriden, otherwise will match actionID" } },
				{ Name = "itemType", Type = "SpellBookItemType", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "subName", Type = "string", Nilable = false, Documentation = { "May be empty if flyout, or if spell's data isn't loaded yet; Listen for SPELL_TEXT_UPDATE event, or use SpellMixin to load asynchronously" } },
				{ Name = "iconID", Type = "fileID", Nilable = false },
				{ Name = "isPassive", Type = "bool", Nilable = false, Documentation = { "True if the item is a passive spell; Will always be false if it is not a spell" } },
				{ Name = "isOffSpec", Type = "bool", Nilable = false, Documentation = { "True if the item belongs to a non-active specialization" } },
				{ Name = "skillLineIndex", Type = "luaIndex", Nilable = true, Documentation = { "Index of the SkillLine this SpellBookItem is part of; Nil this SpellBookItem isn't part of a SkillLine" } },
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