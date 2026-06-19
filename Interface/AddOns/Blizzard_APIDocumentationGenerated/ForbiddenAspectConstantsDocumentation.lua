local ForbiddenAspectConstants =
{
	Tables =
	{
		{
			Name = "ForbiddenAspect",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "SetToDefaults", Type = "ForbiddenAspect", EnumValue = 1 },
				{ Name = "ScriptBindings", Type = "ForbiddenAspect", EnumValue = 2 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ForbiddenAspectConstants);