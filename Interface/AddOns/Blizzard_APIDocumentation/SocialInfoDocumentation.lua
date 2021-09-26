local SocialInfo =
{
	Name = "SocialInfo",
	Type = "System",
	Namespace = "C_SocialInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "SocialItemReceived",
			Type = "Event",
			LiteralName = "SOCIAL_ITEM_RECEIVED",
		},
		{
			Name = "TwitterLinkResult",
			Type = "Event",
			LiteralName = "TWITTER_LINK_RESULT",
			Payload =
			{
				{ Name = "isLinked", Type = "bool", Nilable = false },
				{ Name = "screenName", Type = "string", Nilable = false },
				{ Name = "error", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TwitterPostResult",
			Type = "Event",
			LiteralName = "TWITTER_POST_RESULT",
			Payload =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TwitterStatusUpdate",
			Type = "Event",
			LiteralName = "TWITTER_STATUS_UPDATE",
			Payload =
			{
				{ Name = "isTwitterEnabled", Type = "bool", Nilable = false },
				{ Name = "isLinked", Type = "bool", Nilable = false },
				{ Name = "screenName", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SocialInfo);