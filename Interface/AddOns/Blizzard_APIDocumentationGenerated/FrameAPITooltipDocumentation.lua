local FrameAPITooltip =
{
	Name = "FrameAPITooltip",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetMinimumWidth",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.MinimumWidth },

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
			Name = "GetPadding",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.Padding },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMinimumWidth",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.MinimumWidth },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "force", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetPadding",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Padding },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "left", Type = "number", Nilable = true },
				{ Name = "top", Type = "number", Nilable = true },
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