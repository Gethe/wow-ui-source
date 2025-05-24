local SoulbindsConstants =
{
	Tables =
	{
		{
			Name = "AddSoulbindConduitReason",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "AddSoulbindConduitReason", EnumValue = 0 },
				{ Name = "Cheat", Type = "AddSoulbindConduitReason", EnumValue = 1 },
				{ Name = "SpellEffect", Type = "AddSoulbindConduitReason", EnumValue = 2 },
				{ Name = "Upgrade", Type = "AddSoulbindConduitReason", EnumValue = 3 },
			},
		},
		{
			Name = "SoulbindConduitFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "VisibleToGetallsoulbindconduitScript", Type = "SoulbindConduitFlags", EnumValue = 1 },
			},
		},
		{
			Name = "SoulbindConduitInstallResult",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Success", Type = "SoulbindConduitInstallResult", EnumValue = 0 },
				{ Name = "InvalidItem", Type = "SoulbindConduitInstallResult", EnumValue = 1 },
				{ Name = "InvalidConduit", Type = "SoulbindConduitInstallResult", EnumValue = 2 },
				{ Name = "InvalidTalent", Type = "SoulbindConduitInstallResult", EnumValue = 3 },
				{ Name = "DuplicateConduit", Type = "SoulbindConduitInstallResult", EnumValue = 4 },
				{ Name = "ForgeNotInProximity", Type = "SoulbindConduitInstallResult", EnumValue = 5 },
				{ Name = "SocketNotEmpty", Type = "SoulbindConduitInstallResult", EnumValue = 6 },
			},
		},
		{
			Name = "SoulbindConduitTransactionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Install", Type = "SoulbindConduitTransactionType", EnumValue = 0 },
				{ Name = "Uninstall", Type = "SoulbindConduitTransactionType", EnumValue = 1 },
			},
		},
		{
			Name = "SoulbindConduitType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Finesse", Type = "SoulbindConduitType", EnumValue = 0 },
				{ Name = "Potency", Type = "SoulbindConduitType", EnumValue = 1 },
				{ Name = "Endurance", Type = "SoulbindConduitType", EnumValue = 2 },
				{ Name = "Flex", Type = "SoulbindConduitType", EnumValue = 3 },
			},
		},
		{
			Name = "SoulbindNodeState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Unavailable", Type = "SoulbindNodeState", EnumValue = 0 },
				{ Name = "Unselected", Type = "SoulbindNodeState", EnumValue = 1 },
				{ Name = "Selectable", Type = "SoulbindNodeState", EnumValue = 2 },
				{ Name = "Selected", Type = "SoulbindNodeState", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SoulbindsConstants);