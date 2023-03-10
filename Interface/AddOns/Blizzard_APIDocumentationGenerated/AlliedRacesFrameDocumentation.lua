local AlliedRacesFrame =
{
	Name = "AlliedRaces",
	Type = "System",
	Namespace = "C_AlliedRaces",

	Functions =
	{
		{
			Name = "GetAllRacialAbilitiesFromID",
			Type = "Function",

			Arguments =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "allDisplayInfo", Type = "table", InnerType = "AlliedRaceRacialAbility", Nilable = false },
			},
		},
		{
			Name = "GetRaceInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AlliedRaceInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AlliedRaceClose",
			Type = "Event",
			LiteralName = "ALLIED_RACE_CLOSE",
		},
		{
			Name = "AlliedRaceOpen",
			Type = "Event",
			LiteralName = "ALLIED_RACE_OPEN",
			Payload =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "AlliedRaceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
				{ Name = "maleModelID", Type = "number", Nilable = false },
				{ Name = "femaleModelID", Type = "number", Nilable = false },
				{ Name = "achievementIds", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "maleName", Type = "cstring", Nilable = false },
				{ Name = "femaleName", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "raceFileString", Type = "cstring", Nilable = false },
				{ Name = "crestAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "modelBackgroundAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "bannerColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "AlliedRaceRacialAbility",
			Type = "Structure",
			Fields =
			{
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AlliedRacesFrame);