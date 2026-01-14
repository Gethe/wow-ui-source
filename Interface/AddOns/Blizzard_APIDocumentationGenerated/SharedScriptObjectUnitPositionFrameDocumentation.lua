local SharedScriptObjectUnitPositionFrame =
{
	Tables =
	{
		{
			Name = "PingTextureType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Center", Type = "PingTextureType", EnumValue = 0 },
				{ Name = "Expand", Type = "PingTextureType", EnumValue = 1 },
				{ Name = "Rotation", Type = "PingTextureType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SharedScriptObjectUnitPositionFrame);