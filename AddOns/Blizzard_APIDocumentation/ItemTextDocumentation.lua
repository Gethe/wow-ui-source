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
		},
		{
			Name = "ItemTextClosed",
			Type = "Event",
			LiteralName = "ITEM_TEXT_CLOSED",
		},
		{
			Name = "ItemTextReady",
			Type = "Event",
			LiteralName = "ITEM_TEXT_READY",
		},
		{
			Name = "ItemTextTranslation",
			Type = "Event",
			LiteralName = "ITEM_TEXT_TRANSLATION",
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