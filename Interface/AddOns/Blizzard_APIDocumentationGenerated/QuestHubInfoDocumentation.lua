local QuestHubInfo =
{
	Name = "QuestHubUI",
	Type = "System",
	Namespace = "C_QuestHub",

	Functions =
	{
		{
			Name = "IsQuestCurrentlyRelatedToHub",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "areaPoiID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRelated", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(QuestHubInfo);