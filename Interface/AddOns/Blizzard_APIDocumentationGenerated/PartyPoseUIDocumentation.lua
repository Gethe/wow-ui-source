local PartyPoseUI =
{
	Name = "PartyPose",
	Type = "System",
	Namespace = "C_PartyPose",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ShowPartyPoseUI",
			Type = "Event",
			LiteralName = "SHOW_PARTY_POSE_UI",
			Payload =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "won", Type = "bool", Nilable = false },
			},
		},
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
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = true },
				{ Name = "titleText", Type = "string", Nilable = true },
				{ Name = "extraButtonText", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PartyPoseUI);