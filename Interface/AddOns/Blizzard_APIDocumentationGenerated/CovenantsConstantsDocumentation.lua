local CovenantsConstants =
{
	Tables =
	{
		{
			Name = "CovenantAbilityType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Class", Type = "CovenantAbilityType", EnumValue = 0 },
				{ Name = "Signature", Type = "CovenantAbilityType", EnumValue = 1 },
				{ Name = "Soulbind", Type = "CovenantAbilityType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CovenantsConstants);