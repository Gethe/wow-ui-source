local SimpleModelAPI =
{
	Name = "SimpleModelAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AdvanceTime",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearFog",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearModel",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearTransform",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetCameraDistance",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "distance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraFacing",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "radians", Type = "number", Nilable = false },
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
			Name = "GetCameraRoll",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "radians", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCameraTarget",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "targetX", Type = "number", Nilable = false },
				{ Name = "targetY", Type = "number", Nilable = false },
				{ Name = "targetZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDesaturation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "strength", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFacing",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "facing", Type = "number", Nilable = false },
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
				{ Name = "colorA", Type = "number", Nilable = false },
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
				{ Name = "fogFar", Type = "number", Nilable = false },
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
				{ Name = "fogNear", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLight",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
				{ Name = "light", Type = "ModelLight", Nilable = false },
			},
		},
		{
			Name = "GetModelAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModelDrawLayer",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
				{ Name = "sublayer", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModelFileID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "modelFileID", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetModelScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPaused",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "paused", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetPitch",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "pitch", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPosition",
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
			Name = "GetRoll",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "roll", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetShadowEffect",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "strength", Type = "number", Nilable = false },
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
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
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
				{ Name = "x", Type = "uiUnit", Nilable = false },
				{ Name = "y", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetWorldScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "worldScale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasAttachmentPoints",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasAttachmentPoints", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasCustomCamera",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasCustomCamera", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingModelCenterToTransform",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "useCenter", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MakeCurrentCameraCustom",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ReplaceIconTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},
		},
		{
			Name = "SetCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "cameraIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraDistance",
			Type = "Function",

			Arguments =
			{
				{ Name = "distance", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraFacing",
			Type = "Function",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
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
			Name = "SetCameraRoll",
			Type = "Function",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCameraTarget",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetX", Type = "number", Nilable = false },
				{ Name = "targetY", Type = "number", Nilable = false },
				{ Name = "targetZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCustomCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "cameraIndex", Type = "number", Nilable = false },
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
			Name = "SetFacing",
			Type = "Function",

			Arguments =
			{
				{ Name = "facing", Type = "number", Nilable = false },
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
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetFogFar",
			Type = "Function",

			Arguments =
			{
				{ Name = "fogFar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFogNear",
			Type = "Function",

			Arguments =
			{
				{ Name = "fogNear", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetGlow",
			Type = "Function",

			Arguments =
			{
				{ Name = "glow", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLight",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
				{ Name = "light", Type = "ModelLight", Nilable = false },
			},
		},
		{
			Name = "SetModel",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "ModelAsset", Nilable = false },
				{ Name = "noMip", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetModelAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetModelDrawLayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
			},
		},
		{
			Name = "SetModelScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetParticlesEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPaused",
			Type = "Function",

			Arguments =
			{
				{ Name = "paused", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPitch",
			Type = "Function",

			Arguments =
			{
				{ Name = "pitch", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPosition",
			Type = "Function",

			Arguments =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
				{ Name = "positionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetRoll",
			Type = "Function",

			Arguments =
			{
				{ Name = "roll", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSequence",
			Type = "Function",

			Arguments =
			{
				{ Name = "sequence", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSequenceTime",
			Type = "Function",

			Arguments =
			{
				{ Name = "sequence", Type = "number", Nilable = false },
				{ Name = "timeOffset", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetShadowEffect",
			Type = "Function",

			Arguments =
			{
				{ Name = "strength", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTransform",
			Type = "Function",

			Arguments =
			{
				{ Name = "translation", Type = "vector3", Mixin = "Vector3DMixin", Nilable = true },
				{ Name = "rotation", Type = "vector3", Mixin = "Vector3DMixin", Nilable = true },
				{ Name = "scale", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetViewInsets",
			Type = "Function",

			Arguments =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetViewTranslation",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "uiUnit", Nilable = false },
				{ Name = "y", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "TransformCameraSpaceToModelSpace",
			Type = "Function",

			Arguments =
			{
				{ Name = "cameraPosition", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "modelPosition", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
			},
		},
		{
			Name = "UseModelCenterToTransform",
			Type = "Function",

			Arguments =
			{
				{ Name = "useCenter", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleModelAPI);