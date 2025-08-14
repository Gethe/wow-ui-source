local PingManagerSecure =
{
	Name = "PingManagerSecure",
	Type = "System",
	Namespace = "C_PingSecure",

	Functions =
	{
		{
			Name = "ClearPendingPingInfo",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "CreateFrame",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "DisplayError",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "error", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetTargetPingReceiver",
			Type = "Function",
			HasRestrictions = true,

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
			HasRestrictions = true,

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
			HasRestrictions = true,

			Returns =
			{
				{ Name = "result", Type = "ContextualWorldPingResult", Nilable = false },
			},
		},
		{
			Name = "SendPing",
			Type = "Function",
			HasRestrictions = true,

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
		{
			Name = "SetPendingPingOffScreenCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "PendingPingOffScreenCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingCooldownStartedCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "PingCooldownStartedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingPinFrameAddedCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "PingPinFrameAddedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingPinFrameRemovedCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "PingPinFrameRemovedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingPinFrameScreenClampStateUpdatedCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "PingPinFrameScreenClampStateUpdatedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingRadialWheelCreatedCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "PingRadialWheelCreatedCallback", Nilable = false },
			},
		},
		{
			Name = "SetSendMacroPingCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "SendMacroPingCallback", Nilable = false },
			},
		},
		{
			Name = "SetTogglePingListenerCallback",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "cb", Type = "TogglePingListenerCallback", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "PendingPingOffScreenCallback",
			Type = "CallbackType",
		},
		{
			Name = "PingCooldownStartedCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "info", Type = "PingCooldownInfo", Nilable = false },
			},
		},
		{
			Name = "PingPinFrameAddedCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = false },
				{ Name = "isWorldPoint", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PingPinFrameRemovedCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
			},
		},
		{
			Name = "PingPinFrameScreenClampStateUpdatedCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
				{ Name = "state", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PingRadialWheelCreatedCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "region", Type = "ScriptRegion", Nilable = false },
			},
		},
		{
			Name = "SendMacroPingCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = true },
				{ Name = "targetToken", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "TogglePingListenerCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "down", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PingManagerSecure);