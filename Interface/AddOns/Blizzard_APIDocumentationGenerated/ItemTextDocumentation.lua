local ItemText =
{
	Name = "ItemText",
	Type = "System",
	Namespace = "C_ItemText",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ItemTextBegin",
			Type = "Event",
			LiteralName = "ITEM_TEXT_BEGIN",
			SynchronousEvent = true,
		},
		{
			Name = "ItemTextClosed",
			Type = "Event",
			LiteralName = "ITEM_TEXT_CLOSED",
			SynchronousEvent = true,
		},
		{
			Name = "ItemTextReady",
			Type = "Event",
			LiteralName = "ITEM_TEXT_READY",
			SynchronousEvent = true,
		},
		{
			Name = "ItemTextTranslation",
			Type = "Event",
			LiteralName = "ITEM_TEXT_TRANSLATION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "delay", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ItemText);