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
				{ Name = "classColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
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

APIDocumentation:AddDocumentationTable(ClassColor);