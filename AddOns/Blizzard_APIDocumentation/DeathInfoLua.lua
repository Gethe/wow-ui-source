local DeathInfoLua =
{
	Name = "DeathInfo",
	Type = "System",
	Namespace = "C_DeathInfo",

	Functions =
	{
		{
			Name = "GetSelfResurrectOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "options", Type = "table", InnerType = "SelfResurrectOption", Nilable = false },
			},
		},
		{
			Name = "UseSelfResurrectOption",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionType", Type = "SelfResurrectOptionType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "SelfResurrectOptionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Spell", Type = "SelfResurrectOptionType", EnumValue = 0 },
				{ Name = "Item", Type = "SelfResurrectOptionType", EnumValue = 1 },
			},
		},
		{
			Name = "SelfResurrectOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "optionType", Type = "SelfResurrectOptionType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "isLimited", Type = "bool", Nilable = false },
				{ Name = "priority", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DeathInfoLua);