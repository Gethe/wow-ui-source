local GuildInfoShared =
{
	Tables =
	{
		{
			Name = "GuildTabardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "backgroundColor", Type = "colorRGB", Nilable = false },
				{ Name = "borderColor", Type = "colorRGB", Nilable = false },
				{ Name = "emblemColor", Type = "colorRGB", Nilable = false },
				{ Name = "emblemFilename", Type = "cstring", Nilable = false },
				{ Name = "emblemFileID", Type = "number", Nilable = false },
				{ Name = "emblemStyle", Type = "number", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(GuildInfoShared);