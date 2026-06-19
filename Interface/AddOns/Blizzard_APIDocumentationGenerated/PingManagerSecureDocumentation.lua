local PingManagerSecure =
{
	Name = "PingManagerSecure",
	Type = "System",
	Namespace = "C_PingSecure",
	Environment = "SecureOnly",

	Functions =
	{
		{
			Name = "ClearHitTestPingInfo",
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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "error", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetTargetPingReceiver",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "SendHitTestPing",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "SendPingResult", Nilable = false },
			},
		},
		{
			Name = "SendPlayerItemPing",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "SendPingResult", Nilable = false },
			},
		},
		{
			Name = "SendPlayerSpellPing",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "SendPingResult", Nilable = false },
			},
		},
		{
			Name = "SendUnitPing",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "target", Type = "WOWGUID", Nilable = false },
				{ Name = "type", Type = "PingSubjectType", Nilable = true },
				{ Name = "isPlayerResource", Type = "bool", Nilable = true, Documentation = { "Player unit frame contextual pings have the optional ability to call out the player's health and in some cases mana. This field does nothing for non player pings." } },
			},

			Returns =
			{
				{ Name = "result", Type = "SendPingResult", Nilable = false },
			},
		},
		{
			Name = "SetHitTestPingTarget",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mousePosX", Type = "number", Nilable = false },
				{ Name = "mousePosY", Type = "number", Nilable = false },
				{ Name = "forcePointPing", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "state", Type = "PingSetTargetState", Nilable = false },
			},
		},
		{
			Name = "SetHitTestTargetAndSendPing",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "result", Type = "SendPingResult", Nilable = false },
			},
		},
		{
			Name = "SetPendingPingOffScreenCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "PendingPingOffScreenCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingCooldownStartedCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "PingCooldownStartedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingPinFrameAddedCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "PingPinFrameAddedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingPinFrameRemovedCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "PingPinFrameRemovedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingPinFrameScreenClampStateUpdatedCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "PingPinFrameScreenClampStateUpdatedCallback", Nilable = false },
			},
		},
		{
			Name = "SetPingRadialWheelCreatedCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "PingRadialWheelCreatedCallback", Nilable = false },
			},
		},
		{
			Name = "SetSendMacroPingCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "SendMacroPingCallback", Nilable = false },
			},
		},
		{
			Name = "SetTogglePingListenerCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "TogglePingListenerCallback", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "UnitPingPinAdded",
			Type = "Event",
			LiteralName = "UNIT_PING_PIN_ADDED",
			HasRestrictions = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "uiTextureKit", Type = "textureKit", Nilable = false },
			},
		},
		{
			Name = "UnitPingPinRemoved",
			Type = "Event",
			LiteralName = "UNIT_PING_PIN_REMOVED",
			HasRestrictions = true,
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "PingActionCooldownUIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "durationMs", Type = "number", Nilable = false, Default = 0 },
				{ Name = "remainingMs", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "PingActionUIInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "itemID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "textureFileDataID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "cooldownInfo", Type = "PingActionCooldownUIInfo", Nilable = true },
			},
		},
		{
			Name = "SendPingResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "PingSubjectType", Nilable = true },
				{ Name = "result", Type = "PingResult", Nilable = false },
			},
		},
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
				{ Name = "actionInfo", Type = "PingActionUIInfo", Nilable = true },
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
				{ Name = "macroInfo", Type = "PingMacroInfo", Nilable = false },
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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PingManagerSecure);