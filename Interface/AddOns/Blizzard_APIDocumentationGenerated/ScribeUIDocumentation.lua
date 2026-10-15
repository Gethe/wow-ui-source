local ScribeUI =
{
	Name = "ScribeUI",
	Type = "System",
	Namespace = "C_ScribeUI",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetClassInfoFromClassID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "classID", Type = "ScribeClassID", Nilable = false },
			},

			Returns =
			{
				{ Name = "classInfo", Type = "ScribeClassInfo", Nilable = true },
			},
		},
		{
			Name = "GetCurrClassID",
			Type = "Function",

			Returns =
			{
				{ Name = "classID", Type = "ScribeClassID", Nilable = false },
			},
		},
		{
			Name = "SetCurrClassID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "classID", Type = "ScribeClassID", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ScribeClassChanged",
			Type = "Event",
			LiteralName = "SCRIBE_CLASS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "classID", Type = "ScribeClassID", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "ScribeClassID",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1492,
			MaxValue = 1498,
			Fields =
			{
				{ Name = "None", Type = "ScribeClassID", EnumValue = 1492 },
				{ Name = "Witch", Type = "ScribeClassID", EnumValue = 1496 },
				{ Name = "Slayer", Type = "ScribeClassID", EnumValue = 1497 },
				{ Name = "Inquisitor", Type = "ScribeClassID", EnumValue = 1498 },
			},
		},
		{
			Name = "ScribeClassInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "className", Type = "string", Nilable = false },
				{ Name = "classDescription", Type = "string", Nilable = false },
				{ Name = "classTextureAtlasName", Type = "string", Nilable = false },
				{ Name = "traitTreeID", Type = "number", Nilable = false },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ScribeUI);