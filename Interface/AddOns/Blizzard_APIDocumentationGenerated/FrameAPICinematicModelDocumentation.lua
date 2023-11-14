local FrameAPICinematicModel =
{
	Name = "FrameAPICinematicModel",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "EquipItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InitializeCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "scaleFactor", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "InitializePanCamera",
			Type = "Function",

			Arguments =
			{
				{ Name = "scaleFactor", Type = "number", Nilable = false, Default = 0 },
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
			Name = "SetAnimOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offset", Type = "number", Nilable = false },
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
			Name = "SetCameraTarget",
			Type = "Function",

			Arguments =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
				{ Name = "positionZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCreatureData",
			Type = "Function",

			Arguments =
			{
				{ Name = "creatureID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFacingLeft",
			Type = "Function",

			Arguments =
			{
				{ Name = "isFacingLeft", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetFadeTimes",
			Type = "Function",

			Arguments =
			{
				{ Name = "fadeInSeconds", Type = "number", Nilable = false },
				{ Name = "fadeOutSeconds", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetHeightFactor",
			Type = "Function",

			Arguments =
			{
				{ Name = "factor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetJumpInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "jumpLength", Type = "number", Nilable = false },
				{ Name = "jumpHeight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPanDistance",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSpellVisualKit",
			Type = "Function",

			Arguments =
			{
				{ Name = "visualKitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTargetDistance",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StartPan",
			Type = "Function",

			Arguments =
			{
				{ Name = "panType", Type = "luaIndex", Nilable = false },
				{ Name = "durationSeconds", Type = "number", Nilable = false },
				{ Name = "doFade", Type = "bool", Nilable = false, Default = false },
				{ Name = "visKitID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "startPositionScale", Type = "number", Nilable = false, Default = 0 },
				{ Name = "speedMultiplier", Type = "number", Nilable = false, Default = 1 },
			},
		},
		{
			Name = "StopPan",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "UnequipItems",
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

APIDocumentation:AddDocumentationTable(FrameAPICinematicModel);