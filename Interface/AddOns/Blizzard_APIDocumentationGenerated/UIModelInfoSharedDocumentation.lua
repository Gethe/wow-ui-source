local UIModelInfoShared =
{
	Tables =
	{
		{
			Name = "ItemTryOnReason",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Success", Type = "ItemTryOnReason", EnumValue = 0 },
				{ Name = "WrongRace", Type = "ItemTryOnReason", EnumValue = 1 },
				{ Name = "NotEquippable", Type = "ItemTryOnReason", EnumValue = 2 },
				{ Name = "DataPending", Type = "ItemTryOnReason", EnumValue = 3 },
			},
		},
		{
			Name = "ModelSceneSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "AlignLightToOrbitDelta", Type = "ModelSceneSetting", EnumValue = 1 },
			},
		},
		{
			Name = "ModelSceneType",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = 0,
			MaxValue = 19,
			Fields =
			{
				{ Name = "MountJournal", Type = "ModelSceneType", EnumValue = 0 },
				{ Name = "PetJournalCard", Type = "ModelSceneType", EnumValue = 1 },
				{ Name = "ShopCard", Type = "ModelSceneType", EnumValue = 2 },
				{ Name = "EncounterJournal", Type = "ModelSceneType", EnumValue = 3 },
				{ Name = "PetJournalLoadout", Type = "ModelSceneType", EnumValue = 4 },
				{ Name = "ArtifactTier2", Type = "ModelSceneType", EnumValue = 5 },
				{ Name = "ArtifactTier2ForgingScene", Type = "ModelSceneType", EnumValue = 6 },
				{ Name = "ArtifactTier2SlamEffect", Type = "ModelSceneType", EnumValue = 7 },
				{ Name = "CommentatorVictoryFanfare", Type = "ModelSceneType", EnumValue = 8 },
				{ Name = "ArtifactRelicTalentEffect", Type = "ModelSceneType", EnumValue = 9 },
				{ Name = "PvPWarModeOrb", Type = "ModelSceneType", EnumValue = 10 },
				{ Name = "PvPWarModeFire", Type = "ModelSceneType", EnumValue = 11 },
				{ Name = "PartyPose", Type = "ModelSceneType", EnumValue = 12 },
				{ Name = "AzeriteItemLevelUpToast", Type = "ModelSceneType", EnumValue = 13 },
				{ Name = "AzeritePowers", Type = "ModelSceneType", EnumValue = 14 },
				{ Name = "AzeriteRewardGlow", Type = "ModelSceneType", EnumValue = 15 },
				{ Name = "HeartOfAzeroth", Type = "ModelSceneType", EnumValue = 16 },
				{ Name = "WorldMapThreat", Type = "ModelSceneType", EnumValue = 17 },
				{ Name = "Soulbinds", Type = "ModelSceneType", EnumValue = 18 },
				{ Name = "JailersTowerAnimaGlow", Type = "ModelSceneType", EnumValue = 19 },
			},
		},
		{
			Name = "UIModelSceneActorFlag",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Deprecated1", Type = "UIModelSceneActorFlag", EnumValue = 1 },
				{ Name = "UseCenterForOriginX", Type = "UIModelSceneActorFlag", EnumValue = 2 },
				{ Name = "UseCenterForOriginY", Type = "UIModelSceneActorFlag", EnumValue = 4 },
				{ Name = "UseCenterForOriginZ", Type = "UIModelSceneActorFlag", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIModelInfoShared);