local LossOfControl =
{
	Name = "LossOfControl",
	Type = "System",
	Namespace = "C_LossOfControl",

	Functions =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(LossOfControl);