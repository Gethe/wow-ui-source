local SystemTime =
{
	Name = "SystemTime",
	Type = "System",

	Functions =
	{
		{
			Name = "GetGameTime",
			Type = "Function",

			Returns =
			{
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLocalGameTime",
			Type = "Function",

			Returns =
			{
				{ Name = "hour", Type = "number", Nilable = false },
				{ Name = "minute", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetServerTime",
			Type = "Function",

			Returns =
			{
				{ Name = "time", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSessionTime",
			Type = "Function",

			Returns =
			{
				{ Name = "time", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTickTime",
			Type = "Function",

			Returns =
			{
				{ Name = "time", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTime",
			Type = "Function",

			Returns =
			{
				{ Name = "time", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsUsingFixedTimeStep",
			Type = "Function",

			Returns =
			{
				{ Name = "isUsingFixedTimeStep", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SystemTime);