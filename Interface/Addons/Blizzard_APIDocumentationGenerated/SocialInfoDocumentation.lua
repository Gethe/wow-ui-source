local SocialInfo =
{
	Name = "SocialInfo",
	Type = "System",
	Namespace = "C_Social",

	Functions =
	{
		{
			Name = "GetLastAchievement",
			Type = "Function",

			Returns =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
				{ Name = "achievementName", Type = "string", Nilable = false },
				{ Name = "achievementDesc", Type = "string", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLastItem",
			Type = "Function",

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemName", Type = "string", Nilable = false },
				{ Name = "iconFileID", Type = "number", Nilable = false },
				{ Name = "itemQuality", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "itemLinkString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetLastScreenshotIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "screenShotIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxTweetLength",
			Type = "Function",

			Returns =
			{
				{ Name = "maxTweetLength", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScreenshotInfoByIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "screenWidth", Type = "number", Nilable = false },
				{ Name = "screenHeight", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTweetLength",
			Type = "Function",

			Arguments =
			{
				{ Name = "tweetText", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "tweetLength", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsSocialEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TwitterCheckStatus",
			Type = "Function",
			Documentation = { "Not allowed to be called by addons" },
		},
		{
			Name = "TwitterConnect",
			Type = "Function",
			Documentation = { "Not allowed to be called by addons" },
		},
		{
			Name = "TwitterDisconnect",
			Type = "Function",
			Documentation = { "Not allowed to be called by addons" },
		},
		{
			Name = "TwitterGetMSTillCanPost",
			Type = "Function",

			Returns =
			{
				{ Name = "msTimeLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TwitterPostMessage",
			Type = "Function",
			Documentation = { "Not allowed to be called by addons" },

			Arguments =
			{
				{ Name = "message", Type = "string", Nilable = false },
			},
		},
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