local UIModelInfoShared =
{
	Tables =
	{
		{
			Name = "ItemTryOnReason",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Success", Type = "ItemTryOnReason", EnumValue = 0 },
				{ Name = "WrongRace", Type = "ItemTryOnReason", EnumValue = 1 },
				{ Name = "NotEquippable", Type = "ItemTryOnReason", EnumValue = 2 },
				{ Name = "DataPending", Type = "ItemTryOnReason", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIModelInfoShared);