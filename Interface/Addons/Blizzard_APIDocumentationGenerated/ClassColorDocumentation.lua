local ClassColor =
{
	Name = "ClassColor",
	Type = "System",
	Namespace = "C_ClassColor",

	Functions =
	{
		{
			Name = "GetClassColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "className", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "classColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
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