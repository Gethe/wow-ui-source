local UIModelInfo =
{
	Name = "ModelInfo",
	Type = "System",
	Namespace = "C_ModelInfo",

	Functions =
	{
		{
			Name = "AddActiveModelScene",
			Type = "Function",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrame", Type = "ModelSceneFrame", Nilable = false },
				{ Name = "modelSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AddActiveModelSceneActor",
			Type = "Function",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrameActor", Type = "ModelSceneFrameActor", Nilable = false },
				{ Name = "modelSceneActorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearActiveModelScene",
			Type = "Function",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrame", Type = "ModelSceneFrame", Nilable = false },
			},
		},
		{
			Name = "ClearActiveModelSceneActor",
			Type = "Function",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrameActor", Type = "ModelSceneFrameActor", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneActorDisplayInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "modelActorDisplayID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "actorDisplayInfo", Type = "UIModelSceneActorDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneActorInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "modelActorID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "actorInfo", Type = "UIModelSceneActorInfo", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneCameraInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "modelSceneCameraID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "modelSceneCameraInfo", Type = "UIModelSceneCameraInfo", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "modelSceneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "modelSceneType", Type = "ModelSceneType", Nilable = false },
				{ Name = "modelCameraIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "modelActorsIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "flags", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "UiModelSceneInfoUpdated",
			Type = "Event",
			LiteralName = "UI_MODEL_SCENE_INFO_UPDATED",
		},
	},

	Tables =
	{
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
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
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
		{
			Name = "UIModelSceneActorDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "animation", Type = "number", Nilable = false },
				{ Name = "animationVariation", Type = "number", Nilable = false },
				{ Name = "animSpeed", Type = "number", Nilable = false },
				{ Name = "animationKitID", Type = "number", Nilable = true },
				{ Name = "spellVisualKitID", Type = "number", Nilable = true },
				{ Name = "alpha", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UIModelSceneActorInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "modelActorID", Type = "number", Nilable = false },
				{ Name = "scriptTag", Type = "cstring", Nilable = false },
				{ Name = "position", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
				{ Name = "yaw", Type = "number", Nilable = false },
				{ Name = "pitch", Type = "number", Nilable = false },
				{ Name = "roll", Type = "number", Nilable = false },
				{ Name = "normalizeScaleAggressiveness", Type = "number", Nilable = true },
				{ Name = "useCenterForOriginX", Type = "bool", Nilable = false },
				{ Name = "useCenterForOriginY", Type = "bool", Nilable = false },
				{ Name = "useCenterForOriginZ", Type = "bool", Nilable = false },
				{ Name = "modelActorDisplayID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "UIModelSceneCameraInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "modelSceneCameraID", Type = "number", Nilable = false },
				{ Name = "scriptTag", Type = "cstring", Nilable = false },
				{ Name = "cameraType", Type = "cstring", Nilable = false },
				{ Name = "target", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
				{ Name = "yaw", Type = "number", Nilable = false },
				{ Name = "pitch", Type = "number", Nilable = false },
				{ Name = "roll", Type = "number", Nilable = false },
				{ Name = "zoomDistance", Type = "number", Nilable = false },
				{ Name = "minZoomDistance", Type = "number", Nilable = false },
				{ Name = "maxZoomDistance", Type = "number", Nilable = false },
				{ Name = "zoomedTargetOffset", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
				{ Name = "zoomedYawOffset", Type = "number", Nilable = false },
				{ Name = "zoomedPitchOffset", Type = "number", Nilable = false },
				{ Name = "zoomedRollOffset", Type = "number", Nilable = false },
				{ Name = "flags", Type = "ModelSceneSetting", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIModelInfo);