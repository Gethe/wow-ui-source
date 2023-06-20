local QueueSpecific =
{
	Tables =
	{
		{
			Name = "QueueSpecificInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "queueType", Type = "cstring", Nilable = false },
				{ Name = "lfgIDs", Type = "table", InnerType = "number", Nilable = true },
				{ Name = "lfgListID", Type = "number", Nilable = true },
				{ Name = "activityID", Type = "number", Nilable = true },
				{ Name = "battlefieldType", Type = "cstring", Nilable = true },
				{ Name = "listID", Type = "number", Nilable = true },
				{ Name = "mapName", Type = "cstring", Nilable = true },
				{ Name = "rated", Type = "bool", Nilable = true },
				{ Name = "isBrawl", Type = "bool", Nilable = true },
				{ Name = "teamSize", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QueueSpecific);