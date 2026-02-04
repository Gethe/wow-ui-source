local LimitedInput =
{
	Name = "LimitedInput",
	Type = "System",
	Namespace = "C_LimitedInput",
	Environment = "All",

	Functions =
	{
		{
			Name = "LimitedInputAllowed",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "type", Type = "LimitedInputType", Nilable = false },
			},

			Returns =
			{
				{ Name = "allowed", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "LimitedInputType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "MouseMove", Type = "LimitedInputType", EnumValue = 0 },
				{ Name = "MouseDown", Type = "LimitedInputType", EnumValue = 1 },
				{ Name = "MouseUp", Type = "LimitedInputType", EnumValue = 2 },
				{ Name = "MouseWheel", Type = "LimitedInputType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LimitedInput);