local SimpleAnimFlipBookAPI =
{
	Name = "SimpleAnimFlipBookAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFlipBookColumns",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "columns", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFlipBookFrameHeight",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFlipBookFrameWidth",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "width", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFlipBookFrames",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "frames", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFlipBookRows",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rows", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFlipBookColumns",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "columns", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFlipBookFrameHeight",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFlipBookFrameWidth",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "width", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFlipBookFrames",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "frames", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFlipBookRows",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "rows", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimFlipBookAPI);