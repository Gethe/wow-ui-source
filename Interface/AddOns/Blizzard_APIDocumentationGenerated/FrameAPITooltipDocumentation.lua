local FrameAPITooltip =
{
	Name = "FrameAPITooltip",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetLeftLine",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "line", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "leftFontString", Type = "SimpleFontString", Nilable = false },
			},
		},
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
			Name = "GetRightLine",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "line", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "rightFontString", Type = "SimpleFontString", Nilable = false },
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
			Name = "SetText",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Text },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "alpha", Type = "number", Nilable = false, ConditionalSecret = true, Default = 1 },
				{ Name = "wrap", Type = "bool", Nilable = false, ConditionalSecret = true, Default = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(FrameAPITooltip);