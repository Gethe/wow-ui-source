local Trainer =
{
	Name = "Trainer",
	Type = "System",
	Namespace = "C_Trainer",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "TrainerClosed",
			Type = "Event",
			LiteralName = "TRAINER_CLOSED",
		},
		{
			Name = "TrainerDescriptionUpdate",
			Type = "Event",
			LiteralName = "TRAINER_DESCRIPTION_UPDATE",
		},
		{
			Name = "TrainerServiceInfoNameUpdate",
			Type = "Event",
			LiteralName = "TRAINER_SERVICE_INFO_NAME_UPDATE",
		},
		{
			Name = "TrainerShow",
			Type = "Event",
			LiteralName = "TRAINER_SHOW",
		},
		{
			Name = "TrainerUpdate",
			Type = "Event",
			LiteralName = "TRAINER_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Trainer);