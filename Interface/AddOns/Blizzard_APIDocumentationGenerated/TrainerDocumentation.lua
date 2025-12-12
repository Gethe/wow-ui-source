local Trainer =
{
	Name = "Trainer",
	Type = "System",
	Namespace = "C_Trainer",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "TrainerClosed",
			Type = "Event",
			LiteralName = "TRAINER_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "TrainerDescriptionUpdate",
			Type = "Event",
			LiteralName = "TRAINER_DESCRIPTION_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "TrainerServiceInfoNameUpdate",
			Type = "Event",
			LiteralName = "TRAINER_SERVICE_INFO_NAME_UPDATE",
			UniqueEvent = true,
		},
		{
			Name = "TrainerShow",
			Type = "Event",
			LiteralName = "TRAINER_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "TrainerUpdate",
			Type = "Event",
			LiteralName = "TRAINER_UPDATE",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Trainer);