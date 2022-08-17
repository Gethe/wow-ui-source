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
				{ Name = "index", Type = "number", Nilable = false },
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
				{ Name = "unitToken", Type = "string", Nilable = false },
				{ Name = "index", Type = "number", Nilable = false },
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
				{ Name = "unitToken", Type = "string", Nilable = false },
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
				{ Name = "effectIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LossOfControlCommentatorAdded",
			Type = "Event",
			LiteralName = "LOSS_OF_CONTROL_COMMENTATOR_ADDED",
			Payload =
			{
				{ Name = "victim", Type = "string", Nilable = false },
				{ Name = "effectIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LossOfControlCommentatorUpdate",
			Type = "Event",
			LiteralName = "LOSS_OF_CONTROL_COMMENTATOR_UPDATE",
			Payload =
			{
				{ Name = "victim", Type = "string", Nilable = false },
			},
		},
		{
			Name = "LossOfControlUpdate",
			Type = "Event",
			LiteralName = "LOSS_OF_CONTROL_UPDATE",
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
				{ Name = "locType", Type = "string", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "displayText", Type = "string", Nilable = false },
				{ Name = "iconTexture", Type = "number", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = true },
				{ Name = "timeRemaining", Type = "number", Nilable = true },
				{ Name = "duration", Type = "number", Nilable = true },
				{ Name = "lockoutSchool", Type = "number", Nilable = false },
				{ Name = "priority", Type = "number", Nilable = false },
				{ Name = "displayType", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LossOfControl);