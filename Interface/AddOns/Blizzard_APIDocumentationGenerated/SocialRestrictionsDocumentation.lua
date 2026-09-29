local SocialRestrictions =
{
	Name = "SocialRestrictions",
	Type = "System",
	Namespace = "C_SocialRestrictions",
	Environment = "All",

	Functions =
	{
		{
			Name = "AcknowledgeAgeVerificationRestriction",
			Type = "Function",
		},
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
			Name = "IsAgeVerificationRestricted",
			Type = "Function",
			Documentation = { "Returns true if the account is restricted by the Age Verification feature." },

			Returns =
			{
				{ Name = "restricted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAgeVerificationRestrictedMinor",
			Type = "Function",
			HasRestrictions = true,
			Documentation = { "Returns true if the Age Verification restriction is because the account belongs to a minor, as opposed to an adult who has not yet verified their age." },

			Returns =
			{
				{ Name = "isMinor", Type = "bool", Nilable = false },
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
			Name = "IsFriendsDisabled",
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AlertAgeVerificationRestricted",
			Type = "Event",
			LiteralName = "ALERT_AGE_VERIFICATION_RESTRICTED",
			SynchronousEvent = true,
		},
		{
			Name = "AlertRegionalChatDisabled",
			Type = "Event",
			LiteralName = "ALERT_REGIONAL_CHAT_DISABLED",
			SynchronousEvent = true,
		},
		{
			Name = "ChatDisabledChangeFailed",
			Type = "Event",
			LiteralName = "CHAT_DISABLED_CHANGE_FAILED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatDisabledChanged",
			Type = "Event",
			LiteralName = "CHAT_DISABLED_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SocialRestrictions);