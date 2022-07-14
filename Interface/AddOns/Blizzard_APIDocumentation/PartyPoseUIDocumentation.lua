local PartyPoseUI =
{
	Name = "PartyPose",
	Type = "System",
	Namespace = "C_PartyPose",

	Functions =
	{
		{
			Name = "GetPartyPoseInfoByMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "PartyPoseInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "PartyPoseInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "partyPoseID", Type = "number", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "widgetSetID", Type = "number", Nilable = true },
				{ Name = "victoryModelSceneID", Type = "number", Nilable = false },
				{ Name = "defeatModelSceneID", Type = "number", Nilable = false },
				{ Name = "victorySoundKitID", Type = "number", Nilable = false },
				{ Name = "defeatSoundKitID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PartyPoseUI);