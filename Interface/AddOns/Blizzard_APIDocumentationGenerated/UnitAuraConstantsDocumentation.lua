local UnitAuraConstants =
{
	Tables =
	{
		{
			Name = "UnitAuraSoundTrigger",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Added", Type = "UnitAuraSoundTrigger", EnumValue = 0 },
				{ Name = "ApplicationsIncreased", Type = "UnitAuraSoundTrigger", EnumValue = 1 },
				{ Name = "Removed", Type = "UnitAuraSoundTrigger", EnumValue = 2 },
			},
		},
		{
			Name = "UnitAuraUIConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "HIDDEN_GROUP_BUFF_LIST_SIZE", Type = "number", Value = 32 },
				{ Name = "GROUP_BUFF_VISUAL_ALERT_LIST_SIZE", Type = "number", Value = 32 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitAuraConstants);