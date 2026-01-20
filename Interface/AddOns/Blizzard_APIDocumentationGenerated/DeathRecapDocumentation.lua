local DeathRecap =
{
	Name = "DeathRecap",
	Type = "System",
	Namespace = "C_DeathRecap",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetRecapEvents",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "recapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "events", Type = "table", InnerType = "DeathRecapEventInfo", Nilable = false },
			},
		},
		{
			Name = "GetRecapLink",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "recapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HasRecapEvents",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "recapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "hasEvents", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "DeathRecapEventInfo",
			Type = "Structure",
			Fields =
			{
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DeathRecap);