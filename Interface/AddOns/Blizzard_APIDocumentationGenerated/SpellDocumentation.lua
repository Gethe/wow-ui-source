local Spell =
{
	Name = "Spell",
	Type = "System",
	Namespace = "C_Spell",

	Functions =
	{
		{
			Name = "DoesSpellExist",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false, Documentation = { "Spell ID, name, name(subtext), or link" } },
			},

			Returns =
			{
				{ Name = "spellExists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDeadlyDebuffInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "deadlyDebuffInfo", Type = "DeadlyDebuffInfo", Nilable = false },
			},
		},
		{
			Name = "GetMawPowerBorderAtlasBySpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rarityBorderAtlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "GetMawPowerLinkBySpellID",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetOverrideSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
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
			Name = "GetSpellAutoCast",
			Type = "Function",
			Documentation = { "Returns nil if spell doesn't exist" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "autoCastAllowed", Type = "bool", Nilable = false },
				{ Name = "autoCastEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSpellCooldown",
			Type = "Function",
			Documentation = { "Returns nil if spell doesn't exist" },

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
			Name = "GetSpellIDForSpellIdentifier",
			Type = "Function",
			Documentation = { "Meant primarily for getting a spell id from a spell name or link; Returns nothing if spell does not exist" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false, Documentation = { "Spell ID, name, name(subtext), or link; If passed a spell ID, will return same id as was passed" } },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellInfo", Type = "SpellInfo", Nilable = false },
			},
		},
		{
			Name = "GetSpellLevelLearned",
			Type = "Function",

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
			Name = "GetSpellLossOfControlCooldown",
			Type = "Function",
			Documentation = { "Returns nil if spell doesn't exist" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellName",
			Type = "Function",

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
			Name = "GetSpellQueueWindow",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpellTexture",
			Type = "Function",

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
			Name = "GetSpellTradeSkillLink",
			Type = "Function",
			Documentation = { "Returns nil if spell is not associated with a trade skill" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsSpellDataCached",
			Type = "Function",

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
			Name = "IsSpellDisabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},

			Returns =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
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

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},
		},
		{
			Name = "SetSpellAutoCastEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
				{ Name = "enabled", Type = "bool", Nilable = false },
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
		{
			Name = "ToggleSpellAutoCast",
			Type = "Function",
			Documentation = { "Toggles whether spell's autoCast is enabled" },

			Arguments =
			{
				{ Name = "spellIdentifier", Type = "SpellIdentifier", Nilable = false },
			},
		},
	},

	Events =
	{
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