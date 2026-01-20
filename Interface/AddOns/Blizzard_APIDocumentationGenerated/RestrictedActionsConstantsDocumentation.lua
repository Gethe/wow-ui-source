local RestrictedActionsConstants =
{
	Tables =
	{
		{
			Name = "AddOnRestrictionState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Inactive", Type = "AddOnRestrictionState", EnumValue = 0, Documentation = { "State used when an addon restriction is not being enforced." } },
				{ Name = "Activating", Type = "AddOnRestrictionState", EnumValue = 1, Documentation = { "State used during the dispatch of ADDON_RESTRICTION_STATE_CHANGED to infer that a restriction is about to become active, but won't be enforced until event dispatch has completed." } },
				{ Name = "Active", Type = "AddOnRestrictionState", EnumValue = 2, Documentation = { "State used when an addon restriction is presently being enforced." } },
			},
		},
		{
			Name = "AddOnRestrictionType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Combat", Type = "AddOnRestrictionType", EnumValue = 0, Documentation = { "The player is actively affecting combat." } },
				{ Name = "Encounter", Type = "AddOnRestrictionType", EnumValue = 1, Documentation = { "The player is actively participating in an instance encounter." } },
				{ Name = "ChallengeMode", Type = "AddOnRestrictionType", EnumValue = 2, Documentation = { "The player is in an active and incomplete challenge mode or mythic keystone dungeon." } },
				{ Name = "PvPMatch", Type = "AddOnRestrictionType", EnumValue = 3, Documentation = { "The player is in an active and incomplete PvP match." } },
				{ Name = "Map", Type = "AddOnRestrictionType", EnumValue = 4, Documentation = { "The player is on a map that applies addon restrictions." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(RestrictedActionsConstants);