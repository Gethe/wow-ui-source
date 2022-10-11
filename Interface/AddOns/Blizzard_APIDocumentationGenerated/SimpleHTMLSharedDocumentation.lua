local SimpleHTMLShared =
{
	Tables =
	{
		{
			Name = "HTMLContentNode",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "align", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SimpleHTMLShared);