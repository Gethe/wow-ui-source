local PVPMgrConstants =
{
	Tables =
	{
		{
			Name = "PvPMatchmakingType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Battleground", Type = "PvPMatchmakingType", EnumValue = 0 },
				{ Name = "Arena", Type = "PvPMatchmakingType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PVPMgrConstants);