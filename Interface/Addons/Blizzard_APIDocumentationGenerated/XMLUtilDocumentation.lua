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
				{ Name = "name", Type = "string", Nilable = false },
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
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "keyValues", Type = "table", InnerType = "XMLTemplateKeyValue", Nilable = false },
				{ Name = "inherits", Type = "string", Nilable = true },
			},
		},
		{
			Name = "XMLTemplateKeyValue",
			Type = "Structure",
			Fields =
			{
				{ Name = "key", Type = "string", Nilable = false },
				{ Name = "keyType", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "value", Type = "string", Nilable = false },
			},
		},
		{
			Name = "XMLTemplateListInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(XMLUtil);