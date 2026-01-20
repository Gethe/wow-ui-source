local RestrictedActions =
{
	Name = "RestrictedActions",
	Type = "System",
	Namespace = "C_RestrictedActions",
	Environment = "All",

	Functions =
	{
		{
			Name = "CheckAllowProtectedFunctions",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the calling context has permissions to call protected functions on the supplied object." },

			Arguments =
			{
				{ Name = "object", Type = "FrameScriptObject", Nilable = false },
				{ Name = "silent", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, don't signal blocked action errors if protected function calls are disallowed." } },
			},

			Returns =
			{
				{ Name = "protectedFunctionsAllowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAddOnRestrictionState",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the current state of an addon restriction type." },

			Arguments =
			{
				{ Name = "type", Type = "AddOnRestrictionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "state", Type = "AddOnRestrictionState", Nilable = false },
			},
		},
		{
			Name = "InCombatLockdown",
			Type = "Function",
			Namespace = "",

			Returns =
			{
				{ Name = "inCombatLockdown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddOnRestrictionActive",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if an addon restriction type is in an active state. Will always return false during dispatch of ADDON_RESTRICTION_STATE_CHANGED." },

			Arguments =
			{
				{ Name = "type", Type = "AddOnRestrictionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AddonActionBlocked",
			Type = "Event",
			LiteralName = "ADDON_ACTION_BLOCKED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isTainted", Type = "cstring", Nilable = false },
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "AddonActionForbidden",
			Type = "Event",
			LiteralName = "ADDON_ACTION_FORBIDDEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isTainted", Type = "cstring", Nilable = false },
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "AddonRestrictionStateChanged",
			Type = "Event",
			LiteralName = "ADDON_RESTRICTION_STATE_CHANGED",
			SynchronousEvent = true,
			Documentation = { "Fired when the state of an addon restriction type is changing. This event is sequenced such that it will always be fired before a restriction becomes active, or after it is deactivated." },
			Payload =
			{
				{ Name = "type", Type = "AddOnRestrictionType", Nilable = false },
				{ Name = "state", Type = "AddOnRestrictionState", Nilable = false },
			},
		},
		{
			Name = "MacroActionBlocked",
			Type = "Event",
			LiteralName = "MACRO_ACTION_BLOCKED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MacroActionForbidden",
			Type = "Event",
			LiteralName = "MACRO_ACTION_FORBIDDEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(RestrictedActions);