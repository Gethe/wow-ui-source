local NamePlateManager =
{
	Name = "NamePlateManager",
	Type = "System",
	Namespace = "C_NamePlateManager",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetNamePlateHitTestInsets",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the values used to adjust the hit testing area for nameplates." },

			Arguments =
			{
				{ Name = "type", Type = "NamePlateType", Nilable = false },
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
			Name = "IsNamePlateUnitBehindCamera",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether the unit to which the nameplate is attached is behind the player's camera." },

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBehindCamera", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetNamePlateHitTestFrame",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Set the frame used to determine where the mouse should interact with the nameplate. Used to control which part of the nameplate is clickable." },

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "hitTestFrame", Type = "SimpleFrame", Nilable = false },
			},
		},
		{
			Name = "SetNamePlateHitTestInsets",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Provide values to adjust the hit testing area for nameplates. Positive values will decrease the hit test area, negative values will increase it. Note that all hit testing is clamped to the bounds of the nameplate and can not be moved outside it." },

			Arguments =
			{
				{ Name = "type", Type = "NamePlateType", Nilable = false },
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetNamePlateSimplified",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Set whether the nameplate attached to a unit is considered simplified, which can change the way it's displayed." },

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "isSimplified", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ForbiddenNamePlateCreated",
			Type = "Event",
			LiteralName = "FORBIDDEN_NAME_PLATE_CREATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "namePlateFrame", Type = "NamePlateFrame", Nilable = false },
			},
		},
		{
			Name = "ForbiddenNamePlateUnitAdded",
			Type = "Event",
			LiteralName = "FORBIDDEN_NAME_PLATE_UNIT_ADDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ForbiddenNamePlateUnitRemoved",
			Type = "Event",
			LiteralName = "FORBIDDEN_NAME_PLATE_UNIT_REMOVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "NamePlateCreated",
			Type = "Event",
			LiteralName = "NAME_PLATE_CREATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "namePlateFrame", Type = "NamePlateFrame", Nilable = false },
			},
		},
		{
			Name = "NamePlateUnitAdded",
			Type = "Event",
			LiteralName = "NAME_PLATE_UNIT_ADDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "NamePlateUnitBehindCameraChanged",
			Type = "Event",
			LiteralName = "NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "isBehindCamera", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NamePlateUnitRemoved",
			Type = "Event",
			LiteralName = "NAME_PLATE_UNIT_REMOVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(NamePlateManager);