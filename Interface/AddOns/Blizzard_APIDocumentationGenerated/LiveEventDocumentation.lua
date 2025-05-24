local LiveEvent =
{
	Name = "LiveEvent",
	Type = "System",
	Namespace = "C_LiveEvent",

	Functions =
	{
		{
			Name = "OnLiveEventBannerClicked",
			Type = "Function",

			Arguments =
			{
				{ Name = "timerunningSeasonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OnLiveEventPopupClicked",
			Type = "Function",

			Arguments =
			{
				{ Name = "timerunningSeasonID", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(LiveEvent);