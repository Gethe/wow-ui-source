local FrameAPIModelSceneFrameActorBase =
{
	Name = "FrameAPIModelSceneFrameActorBase",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ClearModel",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetActiveBoundingBox",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "boxBottom", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
				{ Name = "boxTop", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
			},
		},
		{
			Name = "GetAlpha",
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
			Name = "GetAnimation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "animation", Type = "AnimationDataEnum", Nilable = false },
			},
		},
		{
			Name = "GetAnimationBlendOperation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "blendOp", Type = "ModelBlendOperation", Nilable = false },
			},
		},
		{
			Name = "GetAnimationVariation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "variation", Type = "number", Nilable = false },
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
			Name = "GetMaxBoundingBox",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "boxBottom", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
				{ Name = "boxTop", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false },
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
				{ Name = "file", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetModelPath",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "path", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetModelUnitGUID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetParticleOverrideScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = true },
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
			Name = "GetScale",
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
			Name = "GetSpellVisualKit",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetYaw",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "yaw", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Hide",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "IsLoaded",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isLoaded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsShown",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isShown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingCenterForOrigin",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "x", Type = "bool", Nilable = false },
				{ Name = "y", Type = "bool", Nilable = false },
				{ Name = "z", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsVisible",
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
			Name = "PlayAnimationKit",
			Type = "Function",

			Arguments =
			{
				{ Name = "animationKit", Type = "number", Nilable = false },
				{ Name = "isLooping", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetAnimation",
			Type = "Function",

			Arguments =
			{
				{ Name = "animation", Type = "AnimationDataEnum", Nilable = false },
				{ Name = "variation", Type = "number", Nilable = true },
				{ Name = "animSpeed", Type = "number", Nilable = false, Default = 1 },
				{ Name = "animOffsetSeconds", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetAnimationBlendOperation",
			Type = "Function",

			Arguments =
			{
				{ Name = "blendOp", Type = "ModelBlendOperation", Nilable = false },
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
			Name = "SetModelByCreatureDisplayID",
			Type = "Function",

			Arguments =
			{
				{ Name = "creatureDisplayID", Type = "number", Nilable = false },
				{ Name = "useActivePlayerCustomizations", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetModelByFileID",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
				{ Name = "useMips", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetModelByPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
				{ Name = "useMips", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetModelByUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "sheatheWeapons", Type = "bool", Nilable = false, Default = false },
				{ Name = "autoDress", Type = "bool", Nilable = false, Default = true },
				{ Name = "hideWeapons", Type = "bool", Nilable = false, Default = false },
				{ Name = "usePlayerNativeForm", Type = "bool", Nilable = false, Default = true },
				{ Name = "holdBowString", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetParticleOverrideScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = true },
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
			Name = "SetScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetShown",
			Type = "Function",

			Arguments =
			{
				{ Name = "show", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSpellVisualKit",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellVisualKitID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "oneShot", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseCenterForOrigin",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "bool", Nilable = false, Default = false },
				{ Name = "y", Type = "bool", Nilable = false, Default = false },
				{ Name = "z", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetYaw",
			Type = "Function",

			Arguments =
			{
				{ Name = "yaw", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Show",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "StopAnimationKit",
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

APIDocumentation:AddDocumentationTable(FrameAPIModelSceneFrameActorBase);