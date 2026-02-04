local TimerunningUI =
{
	Name = "TimerunningUI",
	Type = "System",
	Namespace = "C_TimerunningUI",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetActiveTimerunningSeasonID",
			Type = "Function",

			Returns =
			{
				{ Name = "activeTimerunningSeasonID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "RemixEndOfEvent",
			Type = "Event",
			LiteralName = "REMIX_END_OF_EVENT",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(TimerunningUI);