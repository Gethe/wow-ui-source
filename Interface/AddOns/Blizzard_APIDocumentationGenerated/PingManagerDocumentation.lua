local PingManager =
{
	Name = "PingManager",
	Type = "System",
	Namespace = "C_Ping",

	Functions =
	{
		{
			Name = "ClearPendingPingInfo",
			Type = "Function",
		},
		{
			Name = "CreateFrame",
			Type = "Function",
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
			Name = "GetTargetPingReceiver",
			Type = "Function",

			Arguments =
			{
				{ Name = "mousePosX", Type = "number", Nilable = false },
				{ Name = "mousePosY", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "frame", Type = "ScriptRegion", Nilable = false },
			},
		},
		{
			Name = "GetTargetWorldPing",
			Type = "Function",

			Arguments =
			{
				{ Name = "mousePosX", Type = "number", Nilable = false },
				{ Name = "mousePosY", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "foundTarget", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetTargetWorldPingAndSend",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "ContextualWorldPingResult", Nilable = false },
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
			Name = "SendPing",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = false },
				{ Name = "target", Type = "WOWGUID", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "PingResult", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "PendingPingOffScreen",
			Type = "Event",
			LiteralName = "PENDING_PING_OFF_SCREEN",
		},
		{
			Name = "PingPinFrameAdded",
			Type = "Event",
			LiteralName = "PING_PIN_FRAME_ADDED",
			Payload =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = false },
				{ Name = "isWorldPoint", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PingPinFrameRemoved",
			Type = "Event",
			LiteralName = "PING_PIN_FRAME_REMOVED",
			Payload =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
			},
		},
		{
			Name = "PingPinFrameScreenClampStateUpdated",
			Type = "Event",
			LiteralName = "PING_PIN_FRAME_SCREEN_CLAMP_STATE_UPDATED",
			Payload =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
				{ Name = "state", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PingRadialWheelFrameCreated",
			Type = "Event",
			LiteralName = "PING_RADIAL_WHEEL_FRAME_CREATED",
			Payload =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
			},
		},
		{
			Name = "PingRadialWheelFrameDestroyed",
			Type = "Event",
			LiteralName = "PING_RADIAL_WHEEL_FRAME_DESTROYED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PingManager);