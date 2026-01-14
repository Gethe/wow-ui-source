local CameraConstants =
{
	Tables =
	{
		{
			Name = "CameraModeAspectRatio",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Default", Type = "CameraModeAspectRatio", EnumValue = 0 },
				{ Name = "LegacyLetterbox", Type = "CameraModeAspectRatio", EnumValue = 1 },
				{ Name = "HighDefinition_16_X_9", Type = "CameraModeAspectRatio", EnumValue = 2 },
				{ Name = "Cinemascope_2_Dot_4_X_1", Type = "CameraModeAspectRatio", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CameraConstants);