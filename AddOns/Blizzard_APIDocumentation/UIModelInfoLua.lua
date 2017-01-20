local UIModelInfoLua =
{
	Name = "ModelInfo",
	Namespace = "C_ModelInfo",

	Functions =
	{
		{
			Name = "GetModelSceneActorDisplayInfoByID",

			Arguments =
			{
				{ Name = "modelActorDisplayID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "animation", Type = "number", Nilable = false },
				{ Name = "animationVariation", Type = "number", Nilable = false },
				{ Name = "alpha", Type = "number", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModelSceneActorInfoByID",

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

			Arguments =
			{
				{ Name = "modelSceneID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "modelSceneType", Type = "number", Nilable = false },
				{ Name = "modelCameraIDs", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "modelActorsIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "UIModelSceneActorInfo",
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