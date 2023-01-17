local VignetteInfo =
{
	Name = "Vignette",
	Type = "System",
	Namespace = "C_VignetteInfo",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "VignetteInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "vignetteGUID", Type = "string", Nilable = false },
				{ Name = "objectGUID", Type = "string", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isDead", Type = "bool", Nilable = false },
				{ Name = "onWorldMap", Type = "bool", Nilable = false },
				{ Name = "onMinimap", Type = "bool", Nilable = false },
				{ Name = "isUnique", Type = "bool", Nilable = false },
				{ Name = "inFogOfWar", Type = "bool", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
				{ Name = "hasTooltip", Type = "bool", Nilable = false },
				{ Name = "vignetteID", Type = "number", Nilable = false },
				{ Name = "type", Type = "VignetteType", Nilable = false },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(VignetteInfo);