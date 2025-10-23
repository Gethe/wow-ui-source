local TalkingHead =
{
	Name = "TalkingHead",
	Type = "System",
	Namespace = "C_TalkingHead",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "TalkingheadClose",
			Type = "Event",
			LiteralName = "TALKINGHEAD_CLOSE",
			SynchronousEvent = true,
		},
		{
			Name = "TalkingheadRequested",
			Type = "Event",
			LiteralName = "TALKINGHEAD_REQUESTED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TalkingHead);