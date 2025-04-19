local UIActionConstants =
{
	Tables =
	{
		{
			Name = "UIActionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DefaultAction", Type = "UIActionType", EnumValue = 0 },
				{ Name = "UpdateMapSystem", Type = "UIActionType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIActionConstants);