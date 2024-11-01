local SocialRestrictions =
{
	Name = "SocialRestrictions",
	Type = "System",
	Namespace = "C_SocialRestrictions",

	Functions =
	{
		{
			Name = "AcknowledgeRegionalChatDisabled",
			Type = "Function",
		},
		{
			Name = "CanReceiveChat",
			Type = "Function",
			Documentation = { "Returns true if the player meets all conditions that allow them to receive chat messages." },

			Returns =
			{
				{ Name = "canReceiveChat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanSendChat",
			Type = "Function",
			Documentation = { "Returns true if the player meets all conditions that allow them to send chat messages." },

			Returns =
			{
				{ Name = "canSendChat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsChatDisabled",
			Type = "Function",

			Returns =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMuted",
			Type = "Function",

			Returns =
			{
				{ Name = "isMuted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSilenced",
			Type = "Function",

			Returns =
			{
				{ Name = "isSilenced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSquelched",
			Type = "Function",

			Returns =
			{
				{ Name = "isSquelched", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetChatDisabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AlertRegionalChatDisabled",
			Type = "Event",
			LiteralName = "ALERT_REGIONAL_CHAT_DISABLED",
		},
		{
			Name = "ChatDisabledChangeFailed",
			Type = "Event",
			LiteralName = "CHAT_DISABLED_CHANGE_FAILED",
			Payload =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatDisabledChanged",
			Type = "Event",
			LiteralName = "CHAT_DISABLED_CHANGED",
			Payload =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SocialRestrictions);