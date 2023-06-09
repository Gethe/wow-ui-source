local FrameAPIModelSceneFrame =
{
	Name = "FrameAPIModelSceneFrame",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ClearFog",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "CreateActor",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "template", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetActorAtIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetCameraFarClip",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "farClip", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraFieldOfView",
			Type = "Function",
			Documentation = { "Field of view in radians" },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fov", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraForward",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "forwardX", Type = "number", Nilable = false },
				{ Name = "forwardY", Type = "number", Nilable = false },
				{ Name = "forwardZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraNearClip",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "nearClip", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraPosition",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
				{ Name = "positionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraRight",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rightX", Type = "number", Nilable = false },
				{ Name = "rightY", Type = "number", Nilable = false },
				{ Name = "rightZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraUp",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "upX", Type = "number", Nilable = false },
				{ Name = "upY", Type = "number", Nilable = false },
				{ Name = "upZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDrawLayer",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
				{ Name = "sublevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFogColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFogFar",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "far", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFogNear",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "near", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLightAmbientColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLightDiffuseColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLightDirection",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "directionX", Type = "number", Nilable = false },
				{ Name = "directionY", Type = "number", Nilable = false },
				{ Name = "directionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLightPosition",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
				{ Name = "positionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLightType",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "lightType", Type = "ModelLightType", Nilable = true },
			},
		},
		{
			Name = "GetNumActors",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numActors", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetViewInsets",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "insets", Type = "uiRect", Nilable = false },
			},
		},
		{
			Name = "GetViewTranslation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "translationX", Type = "number", Nilable = false },
				{ Name = "translationY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsLightVisible",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Project3DPointTo2D",
			Type = "Function",

			Arguments =
			{
				{ Name = "pointX", Type = "number", Nilable = false },
				{ Name = "pointY", Type = "number", Nilable = false },
				{ Name = "pointZ", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "point2DX", Type = "number", Nilable = false },
				{ Name = "point2DY", Type = "number", Nilable = false },
				{ Name = "depth", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraFarClip",
			Type = "Function",

			Arguments =
			{
				{ Name = "farClip", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraFieldOfView",
			Type = "Function",
			Documentation = { "Field of view in radians" },

			Arguments =
			{
				{ Name = "fov", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraNearClip",
			Type = "Function",

			Arguments =
			{
				{ Name = "nearClip", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraOrientationByAxisVectors",
			Type = "Function",

			Arguments =
			{
				{ Name = "forwardX", Type = "number", Nilable = false },
				{ Name = "forwardY", Type = "number", Nilable = false },
				{ Name = "forwardZ", Type = "number", Nilable = false },
				{ Name = "rightX", Type = "number", Nilable = false },
				{ Name = "rightY", Type = "number", Nilable = false },
				{ Name = "rightZ", Type = "number", Nilable = false },
				{ Name = "upX", Type = "number", Nilable = false },
				{ Name = "upY", Type = "number", Nilable = false },
				{ Name = "upZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraOrientationByYawPitchRoll",
			Type = "Function",

			Arguments =
			{
				{ Name = "yaw", Type = "number", Nilable = false },
				{ Name = "pitch", Type = "number", Nilable = false },
				{ Name = "roll", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
				{ Name = "positionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetDesaturation",
			Type = "Function",

			Arguments =
			{
				{ Name = "strength", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetDrawLayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
			},
		},
		{
			Name = "SetFogColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFogFar",
			Type = "Function",

			Arguments =
			{
				{ Name = "far", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFogNear",
			Type = "Function",

			Arguments =
			{
				{ Name = "near", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLightAmbientColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLightDiffuseColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLightDirection",
			Type = "Function",

			Arguments =
			{
				{ Name = "directionX", Type = "number", Nilable = false },
				{ Name = "directionY", Type = "number", Nilable = false },
				{ Name = "directionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLightPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
				{ Name = "positionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLightType",
			Type = "Function",

			Arguments =
			{
				{ Name = "lightType", Type = "ModelLightType", Nilable = false },
			},
		},
		{
			Name = "SetLightVisible",
			Type = "Function",

			Arguments =
			{
				{ Name = "visible", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetPaused",
			Type = "Function",

			Arguments =
			{
				{ Name = "paused", Type = "bool", Nilable = false },
				{ Name = "affectsGlobalPause", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetViewInsets",
			Type = "Function",

			Arguments =
			{
				{ Name = "insets", Type = "uiRect", Nilable = false },
			},
		},
		{
			Name = "SetViewTranslation",
			Type = "Function",

			Arguments =
			{
				{ Name = "translationX", Type = "number", Nilable = false },
				{ Name = "translationY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TakeActor",
			Type = "Function",

			Arguments =
			{
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(FrameAPIModelSceneFrame);