local Warfront =
{
	Name = "Warfront",
	Type = "System",
	Namespace = "C_Warfront",

	Functions =
	{
		{
			Name = "GetPlayerConditionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
				{ Name = "failureText", Type = "string", Nilable = false },
			},
		},
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
			Name = "GetWorldStateValue",
			Type = "Function",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
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
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Iron", Type = "WarfrontResourceType", EnumValue = 0 },
				{ Name = "Lumber", Type = "WarfrontResourceType", EnumValue = 1 },
				{ Name = "Essence", Type = "WarfrontResourceType", EnumValue = 2 },
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