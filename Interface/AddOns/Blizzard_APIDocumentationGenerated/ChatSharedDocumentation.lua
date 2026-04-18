local ChatShared =
{
	Tables =
	{
		{
			Name = "AddonMessageParams",
			Type = "Structure",
			Fields =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "chatType", Type = "cstring", Nilable = true, Documentation = { "ChatType, defaults to SLASH_CMD_PARTY." } },
				{ Name = "target", Type = "cstring", Nilable = true, Documentation = { "Only applies for targeted channels" } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ChatShared);