local UIModelInfoLua =
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
				{ Name = "modelSceneFrame", Type = "ScriptObject", Nilable = false },
				{ Name = "modelSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AddActiveModelSceneActor",
			Type = "Function",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrameActor", Type = "ScriptObject", Nilable = false },
				{ Name = "modelSceneActorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearActiveModelScene",
			Type = "Function",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrame", Type = "ScriptObject", Nilable = false },
			},
		},
		{
			Name = "ClearActiveModelSceneActor",
			Type = "Function",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrameActor", Type = "ScriptObject", Nilable = false },
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
				{ Name = "animation", Type = "number", Nilable = false },
				{ Name = "animationVariation", Type = "number", Nilable = false },
				{ Name = "animSpeed", Type = "number", Nilable = false },
				{ Name = "alpha", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
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
			},
		},
	},

	Tables =
	{
		{
			Name = "ModelSceneType",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
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
			},
		},
		{
			Name = "UIModelSceneActorInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "modelActorID", Type = "number", Nilable = false },
				{ Name = "scriptTag", Type = "string", Nilable = false },
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
				{ Name = "scriptTag", Type = "string", Nilable = false },
				{ Name = "cameraType", Type = "string", Nilable = false },
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
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIModelInfoLua);