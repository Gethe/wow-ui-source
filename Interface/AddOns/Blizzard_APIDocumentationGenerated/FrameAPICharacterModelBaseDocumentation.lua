local FrameAPICharacterModelBase =
{
	Name = "FrameAPICharacterModelBase",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ApplySpellVisualKit",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
				{ Name = "oneShot", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "CanSetUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "FreezeAnimation",
			Type = "Function",

			Arguments =
			{
				{ Name = "anim", Type = "AnimationDataEnum", Nilable = false },
				{ Name = "variation", Type = "number", Nilable = false },
				{ Name = "frame", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDisplayInfo",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "displayID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDoBlend",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "doBlend", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetKeepModelOnHide",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "keepModelOnHide", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasAnimation",
			Type = "Function",

			Arguments =
			{
				{ Name = "anim", Type = "AnimationDataEnum", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasAnimation", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayAnimKit",
			Type = "Function",

			Arguments =
			{
				{ Name = "animKit", Type = "number", Nilable = false },
				{ Name = "loop", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "RefreshCamera",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "RefreshUnit",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetAnimation",
			Type = "Function",

			Arguments =
			{
				{ Name = "anim", Type = "AnimationDataEnum", Nilable = false },
				{ Name = "variation", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetBarberShopAlternateForm",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetCamDistanceScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCreature",
			Type = "Function",

			Arguments =
			{
				{ Name = "creatureID", Type = "number", Nilable = false },
				{ Name = "displayID", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetDisplayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "displayID", Type = "number", Nilable = false },
				{ Name = "mountDisplayID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetDoBlend",
			Type = "Function",

			Arguments =
			{
				{ Name = "doBlend", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = true },
				{ Name = "itemVisualID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetItemAppearance",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "itemVisualID", Type = "number", Nilable = true },
				{ Name = "itemSubclass", Type = "ItemWeaponSubclass", Nilable = true },
			},
		},
		{
			Name = "SetKeepModelOnHide",
			Type = "Function",

			Arguments =
			{
				{ Name = "keepModelOnHide", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPortraitZoom",
			Type = "Function",

			Arguments =
			{
				{ Name = "zoom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetRotation",
			Type = "Function",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
				{ Name = "animate", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "blend", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StopAnimKit",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ZeroCachedCenterXY",
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

APIDocumentation:AddDocumentationTable(FrameAPICharacterModelBase);