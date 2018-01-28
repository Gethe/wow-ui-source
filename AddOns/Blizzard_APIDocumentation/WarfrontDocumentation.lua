local Warfront =
{
	Name = "Warfront",
	Type = "System",
	Namespace = "C_Warfront",

	Functions =
	{
		{
			Name = "GetResourceInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "resourceType", Type = "WarfrontResourceType", Nilable = false },
			},

			Returns =
			{
				{ Name = "resourceInfo", Type = "ResourceInfo", Nilable = false },
			},
		},
		{
			Name = "InWarfront",
			Type = "Function",

			Returns =
			{
				{ Name = "inWarfront", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "WarfrontUpdate",
			Type = "Event",
			LiteralName = "WARFRONT_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "WarfrontResourceType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Food", Type = "WarfrontResourceType", EnumValue = 0 },
				{ Name = "Iron", Type = "WarfrontResourceType", EnumValue = 1 },
				{ Name = "Lumber", Type = "WarfrontResourceType", EnumValue = 2 },
				{ Name = "Essence", Type = "WarfrontResourceType", EnumValue = 3 },
			},
		},
		{
			Name = "ResourceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "resourceType", Type = "WarfrontResourceType", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "maxQuantity", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Warfront);