local SoftTargetConstants =
{
	Tables =
	{
		{
			Name = "SoftTargetEnableFlags",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "SoftTargetEnableFlags", EnumValue = 0 },
				{ Name = "Gamepad", Type = "SoftTargetEnableFlags", EnumValue = 1 },
				{ Name = "Kbm", Type = "SoftTargetEnableFlags", EnumValue = 2 },
				{ Name = "Any", Type = "SoftTargetEnableFlags", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SoftTargetConstants);