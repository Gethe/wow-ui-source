local UIAction =
{
	Name = "UIActionHandlerSystem",
	Type = "System",
	Namespace = "C_UIActionHandler",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "HandleUIAction",
			Type = "Event",
			LiteralName = "HANDLE_UI_ACTION",
			Payload =
			{
				{ Name = "actionType", Type = "UIActionType", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UIAction);