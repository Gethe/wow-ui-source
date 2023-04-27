local SimpleHTMLShared =
{
	Tables =
	{
		{
			Name = "HTMLContentNode",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "type", Type = "HTMLTextType", Nilable = false },
				{ Name = "align", Type = "TBFStyleFlags", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SimpleHTMLShared);