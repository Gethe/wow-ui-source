local UIModelInfo =
{
	Name = "ModelInfo",
	Type = "System",
	Namespace = "C_ModelInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddActiveModelScene",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrame", Type = "ModelSceneFrame", Nilable = false },
			},
		},
		{
			Name = "ClearActiveModelSceneActor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "This function does nothing in public clients" },

			Arguments =
			{
				{ Name = "modelSceneFrameActor", Type = "ModelSceneFrameActor", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneActorDisplayInfoByID",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			UniqueEvent = true,
		},
	},

	Tables =
	{
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