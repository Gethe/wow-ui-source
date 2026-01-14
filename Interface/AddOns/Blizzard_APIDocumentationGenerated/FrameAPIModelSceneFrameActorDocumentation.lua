local FrameAPIModelSceneFrameActor =
{
	Name = "FrameAPIModelSceneFrameActor",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AttachToMount",
			Type = "Function",

			Arguments =
			{
				{ Name = "rider", Type = "ModelSceneFrameActor", Nilable = false },
				{ Name = "animation", Type = "AnimationDataEnum", Nilable = false },
				{ Name = "spellKitVisualID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalculateMountScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "rider", Type = "ModelSceneFrameActor", Nilable = false },
			},

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DetachFromMount",
			Type = "Function",

			Arguments =
			{
				{ Name = "rider", Type = "ModelSceneFrameActor", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Dress",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetAutoDress",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "autoDress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetObeyHideInTransmogFlag",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "obey", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSheathed",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetUseTransmogChoices",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetUseTransmogSkin",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGeoReady",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResetNextHandSlot",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetAutoDress",
			Type = "Function",

			Arguments =
			{
				{ Name = "autoDress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetObeyHideInTransmogFlag",
			Type = "Function",

			Arguments =
			{
				{ Name = "obey", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSheathed",
			Type = "Function",

			Arguments =
			{
				{ Name = "sheathed", Type = "bool", Nilable = false },
				{ Name = "hidden", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetUseTransmogChoices",
			Type = "Function",

			Arguments =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUseTransmogSkin",
			Type = "Function",

			Arguments =
			{
				{ Name = "use", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Undress",
			Type = "Function",

			Arguments =
			{
				{ Name = "includeWeapons", Type = "bool", Nilable = false, Default = true },
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

APIDocumentation:AddDocumentationTable(FrameAPIModelSceneFrameActor);