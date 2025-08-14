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
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "timerunningSeasonID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OnLiveEventPopupClicked",
			Type = "Function",
			HasRestrictions = true,

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