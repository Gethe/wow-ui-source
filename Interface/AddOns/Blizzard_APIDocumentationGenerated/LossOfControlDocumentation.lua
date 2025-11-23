local LossOfControl =
{
	Name = "LossOfControl",
	Type = "System",
	Namespace = "C_LossOfControl",

	Functions =
	{
		{
			Name = "GetActiveLossOfControlData",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "event", Type = "LossOfControlData", Nilable = true },
			},
		},
		{
			Name = "GetActiveLossOfControlDataByUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "event", Type = "LossOfControlData", Nilable = true },
			},
		},
		{
			Name = "GetActiveLossOfControlDataCount",
			Type = "Function",

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActiveLossOfControlDataCountByUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "LossOfControlAdded",
			Type = "Event",
			LiteralName = "LOSS_OF_CONTROL_ADDED",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
				{ Name = "effectIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "LossOfControlCommentatorAdded",
			Type = "Event",
			LiteralName = "LOSS_OF_CONTROL_COMMENTATOR_ADDED",
			Payload =
			{
				{ Name = "victim", Type = "WOWGUID", Nilable = false },
				{ Name = "effectIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "LossOfControlCommentatorUpdate",
			Type = "Event",
			LiteralName = "LOSS_OF_CONTROL_COMMENTATOR_UPDATE",
			Payload =
			{
				{ Name = "victim", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "LossOfControlUpdate",
			Type = "Event",
			LiteralName = "LOSS_OF_CONTROL_UPDATE",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "PlayerControlGained",
			Type = "Event",
			LiteralName = "PLAYER_CONTROL_GAINED",
		},
		{
			Name = "PlayerControlLost",
			Type = "Event",
			LiteralName = "PLAYER_CONTROL_LOST",
		},
	},

	Tables =
	{
		{
			Name = "LossOfControlData",
			Type = "Structure",
			Fields =
			{
				{ Name = "locType", Type = "cstring", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "displayText", Type = "cstring", Nilable = false },
				{ Name = "iconTexture", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = true },
				{ Name = "timeRemaining", Type = "number", Nilable = true },
				{ Name = "duration", Type = "number", Nilable = true },
				{ Name = "lockoutSchool", Type = "number", Nilable = false },
				{ Name = "priority", Type = "number", Nilable = false },
				{ Name = "displayType", Type = "number", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LossOfControl);