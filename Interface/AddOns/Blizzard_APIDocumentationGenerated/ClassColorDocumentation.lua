local ClassColor =
{
	Name = "ClassColor",
	Type = "System",
	Namespace = "C_ClassColor",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetClassColor",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "className", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "classColor", Type = "colorRGB", Nilable = false },
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

APIDocumentation:AddDocumentationTable(ClassColor);