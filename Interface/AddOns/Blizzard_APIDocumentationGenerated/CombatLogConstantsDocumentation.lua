local CombatLogConstants =
{
	Tables =
	{
		{
			Name = "CombatLogObject",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = 0,
			MaxValue = 2147483648,
			Fields =
			{
				{ Name = "Empty", Type = "CombatLogObject", EnumValue = 0 },
				{ Name = "AffiliationMine", Type = "CombatLogObject", EnumValue = 1 },
				{ Name = "AffiliationParty", Type = "CombatLogObject", EnumValue = 2 },
				{ Name = "AffiliationRaid", Type = "CombatLogObject", EnumValue = 4 },
				{ Name = "AffiliationOutsider", Type = "CombatLogObject", EnumValue = 8 },
				{ Name = "ReactionFriendly", Type = "CombatLogObject", EnumValue = 16 },
				{ Name = "ReactionNeutral", Type = "CombatLogObject", EnumValue = 32 },
				{ Name = "ReactionHostile", Type = "CombatLogObject", EnumValue = 64 },
				{ Name = "ControlPlayer", Type = "CombatLogObject", EnumValue = 256 },
				{ Name = "ControlNpc", Type = "CombatLogObject", EnumValue = 512 },
				{ Name = "TypePlayer", Type = "CombatLogObject", EnumValue = 1024 },
				{ Name = "TypeNpc", Type = "CombatLogObject", EnumValue = 2048 },
				{ Name = "TypePet", Type = "CombatLogObject", EnumValue = 4096 },
				{ Name = "TypeGuardian", Type = "CombatLogObject", EnumValue = 8192 },
				{ Name = "TypeObject", Type = "CombatLogObject", EnumValue = 16384 },
				{ Name = "Target", Type = "CombatLogObject", EnumValue = 65536 },
				{ Name = "Focus", Type = "CombatLogObject", EnumValue = 131072 },
				{ Name = "Maintank", Type = "CombatLogObject", EnumValue = 262144 },
				{ Name = "Mainassist", Type = "CombatLogObject", EnumValue = 524288 },
				{ Name = "None", Type = "CombatLogObject", EnumValue = 2147483648 },
			},
		},
		{
			Name = "CombatLogObjectTarget",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 2147483648,
			Fields =
			{
				{ Name = "Raidtarget1", Type = "CombatLogObjectTarget", EnumValue = 1 },
				{ Name = "Raidtarget2", Type = "CombatLogObjectTarget", EnumValue = 2 },
				{ Name = "Raidtarget3", Type = "CombatLogObjectTarget", EnumValue = 4 },
				{ Name = "Raidtarget4", Type = "CombatLogObjectTarget", EnumValue = 8 },
				{ Name = "Raidtarget5", Type = "CombatLogObjectTarget", EnumValue = 16 },
				{ Name = "Raidtarget6", Type = "CombatLogObjectTarget", EnumValue = 32 },
				{ Name = "Raidtarget7", Type = "CombatLogObjectTarget", EnumValue = 64 },
				{ Name = "Raidtarget8", Type = "CombatLogObjectTarget", EnumValue = 128 },
				{ Name = "RaidNone", Type = "CombatLogObjectTarget", EnumValue = 2147483648 },
			},
		},
		{
			Name = "CombatLogMessageLimits",
			Type = "Constants",
			Values =
			{
				{ Name = "CombatLogDefaultMessageLimit", Type = "number", Value = 300 },
				{ Name = "CombatLogMaximumMessageLimit", Type = "number", Value = 1000 },
			},
		},
		{
			Name = "CombatLogObjectMasks",
			Type = "Constants",
			Values =
			{
				{ Name = "COMBATLOG_OBJECT_AFFILIATION_MASK", Type = "CombatLogObject", Value = 15 },
				{ Name = "COMBATLOG_OBJECT_REACTION_MASK", Type = "CombatLogObject", Value = 240 },
				{ Name = "COMBATLOG_OBJECT_CONTROL_MASK", Type = "CombatLogObject", Value = 768 },
				{ Name = "COMBATLOG_OBJECT_TYPE_MASK", Type = "CombatLogObject", Value = 64512 },
				{ Name = "COMBATLOG_OBJECT_SPECIAL_MASK", Type = "CombatLogObject", Value = 4294901760 },
			},
		},
		{
			Name = "CombatLogObjectTargetMasks",
			Type = "Constants",
			Values =
			{
				{ Name = "COMBATLOG_OBJECT_RAID_TARGET_MASK", Type = "CombatLogObjectTarget", Value = 255 },
				{ Name = "COMBATLOG_OBJECT_RAID_MASK", Type = "CombatLogObjectTarget", Value = 4294967295 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CombatLogConstants);