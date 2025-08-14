local PingManager =
{
	Name = "PingManager",
	Type = "System",
	Namespace = "C_Ping",

	Functions =
	{
		{
			Name = "GetContextualPingTypeForUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetUnit", Type = "WOWGUID", Nilable = true },
			},

			Returns =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = false },
			},
		},
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
			Name = "SendMacroPing",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = true },
				{ Name = "targetToken", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "TogglePingListener",
			Type = "Function",
			HasRestrictions = true,

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
			Payload =
			{
				{ Name = "error", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PingManager);