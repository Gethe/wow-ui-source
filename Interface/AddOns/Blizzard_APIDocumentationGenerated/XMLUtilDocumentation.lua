local XMLUtil =
{
	Name = "XMLUtil",
	Type = "System",
	Namespace = "C_XMLUtil",

	Functions =
	{
		{
			Name = "GetTemplateInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "XMLTemplateInfo", Nilable = false },
			},
		},
		{
			Name = "GetTemplates",
			Type = "Function",

			Returns =
			{
				{ Name = "templates", Type = "table", InnerType = "XMLTemplateListInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "XMLTemplateInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "cstring", Nilable = false },
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "keyValues", Type = "table", InnerType = "XMLTemplateKeyValue", Nilable = false },
				{ Name = "inherits", Type = "cstring", Nilable = true },
				{ Name = "sourceLocation", Type = "string", Nilable = false },
			},
		},
		{
			Name = "XMLTemplateKeyValue",
			Type = "Structure",
			Fields =
			{
				{ Name = "key", Type = "cstring", Nilable = false },
				{ Name = "keyType", Type = "cstring", Nilable = false },
				{ Name = "type", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "XMLTemplateListInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "type", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(XMLUtil);