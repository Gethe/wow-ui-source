local InvasionInfo =
{
	Name = "InvasionInfo",
	Type = "System",
	Namespace = "C_InvasionInfo",

	Functions =
	{
		{
			Name = "AreInvasionsAvailable",
			Type = "Function",
			Documentation = { "Returns true if invasions are active in the same physical area as the player." },

			Returns =
			{
				{ Name = "areInvasionsAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetInvasionForUiMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "invasionID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetInvasionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "invasionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "invasionInfo", Type = "InvasionMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetInvasionTimeLeft",
			Type = "Function",

			Arguments =
			{
				{ Name = "invasionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeLeftMinutes", Type = "number", Nilable = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "InvasionMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "invasionID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(InvasionInfo);