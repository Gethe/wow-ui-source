local GuildInfoShared =
{
	Tables =
	{
		{
			Name = "GuildTabardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "backgroundColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "borderColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "emblemColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "emblemFileID", Type = "number", Nilable = false },
				{ Name = "emblemStyle", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GuildInfoShared);