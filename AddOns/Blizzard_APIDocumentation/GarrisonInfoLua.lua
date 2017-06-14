local GarrisonInfoLua =
{
	Name = "GarrisonInfo",
	Type = "System",
	Namespace = "C_Garrison",

	Functions =
	{
		{
			Name = "GetCurrentGarrTalentTreeFriendshipFactionID",
			Type = "Function",

			Returns =
			{
				{ Name = "currentGarrTalentTreeFriendshipFactionID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrentGarrTalentTreeID",
			Type = "Function",

			Returns =
			{
				{ Name = "currentGarrTalentTreeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetTalentTreeIDsByClassID",
			Type = "Function",

			Arguments =
			{
				{ Name = "garrType", Type = "number", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "treeIDs", Type = "table", InnerType = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(GarrisonInfoLua);