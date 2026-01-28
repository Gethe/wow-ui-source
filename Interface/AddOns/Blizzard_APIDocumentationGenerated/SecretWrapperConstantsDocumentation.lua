local SecretWrapperConstants =
{
	Tables =
	{
		{
			Name = "SecrecyLevel",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "NeverSecret", Type = "SecrecyLevel", EnumValue = 0, Documentation = { "Will never yield secret values when queried." } },
				{ Name = "AlwaysSecret", Type = "SecrecyLevel", EnumValue = 1, Documentation = { "Will always yield secret values when queried." } },
				{ Name = "ContextuallySecret", Type = "SecrecyLevel", EnumValue = 2, Documentation = { "May yield secret values when queried depending upon factors such as addon restriction states, unit disposition, etc." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SecretWrapperConstants);