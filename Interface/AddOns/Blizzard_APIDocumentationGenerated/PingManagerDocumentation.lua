local PingManager =
{
	Name = "PingManager",
	Type = "System",
	Namespace = "C_Ping",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCooldownInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "cooldownInfo", Type = "PingCooldownInfo", Nilable = false },
			},
		},
		{
			Name = "GetDefaultPingOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "pingTypes", Type = "table", InnerType = "PingTypeInfo", Nilable = false },
			},
		},
		{
			Name = "GetTextureKitForType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = false },
			},

			Returns =
			{
				{ Name = "uiTextureKitID", Type = "textureKit", Nilable = false },
			},
		},
		{
			Name = "IsPingSystemEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SendMacroPing",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "macroInfo", Type = "PingMacroInfo", Nilable = false },
			},
		},
		{
			Name = "TogglePingListener",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "PingSystemError",
			Type = "Event",
			LiteralName = "PING_SYSTEM_ERROR",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "error", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PingTypeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "type", Type = "PingSubjectType", Nilable = false },
				{ Name = "uiTextureKitID", Type = "textureKit", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PingManager);