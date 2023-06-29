local GuildInfoShared =
{
	Tables =
	{
		{
			Name = "GuildTabardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "backgroundColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "borderColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "emblemColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "emblemFilename", Type = "cstring", Nilable = false },
				{ Name = "emblemStyle", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GuildInfoShared);