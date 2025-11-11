local FrameAPITooltip =
{
	Name = "FrameAPITooltip",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetMinimumWidth",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "forced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMinimumWidth",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "force", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetText",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Text },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "alpha", Type = "number", Nilable = true },
				{ Name = "wrap", Type = "bool", Nilable = true },
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

APIDocumentation:AddDocumentationTable(FrameAPITooltip);