local UIActionConstants =
{
	Tables =
	{
		{
			Name = "UIActionType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "DefaultAction", Type = "UIActionType", EnumValue = 0 },
				{ Name = "UpdateMapSystem", Type = "UIActionType", EnumValue = 1 },
				{ Name = "Reserved1", Type = "UIActionType", EnumValue = 2 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(UIActionConstants);