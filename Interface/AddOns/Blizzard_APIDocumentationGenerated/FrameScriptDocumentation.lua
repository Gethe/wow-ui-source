local FrameScript =
{
	Name = "FrameScript",
	Type = "System",

	Functions =
	{
		{
			Name = "canaccesssecrets",
			Type = "Function",
			Documentation = { "Returns true if the immediate calling function has appropriate permissions to access or operate on secret values." },

			Returns =
			{
				{ Name = "canAccessSecrets", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "canaccesstable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the immediate calling function has appropriate permissions to index secret tables. This will return false if the caller cannot access the table value itself, or if access to the table contents is disallowed by taint." },

			Arguments =
			{
				{ Name = "table", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "canAccessTable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "canaccessvalue",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the immediate calling function has appropriate permissions to access and operate on a specific secret value." },

			Arguments =
			{
				{ Name = "value", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "canAccessValue", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CreateFromMixins",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mixins", Type = "LuaValueVariant", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "object", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "CreateSecureDelegate",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "luaFunction", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "secureDelegateFunction", Type = "LuaValueReference", Nilable = false },
			},
		},
		{
			Name = "CreateWindow",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "popupStyle", Type = "bool", Nilable = false, Default = true },
				{ Name = "topMost", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "window", Type = "SimpleWindow", Nilable = true },
			},
		},
		{
			Name = "dropsecretaccess",
			Type = "Function",
			Documentation = { "Removes the ability for the immediate calling function to access secret values." },
		},
		{
			Name = "GetCallstackHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentEventID",
			Type = "Function",

			Returns =
			{
				{ Name = "eventID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetErrorCallstackHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetEventTime",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventProfileIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalElapsedTime", Type = "number", Nilable = false },
				{ Name = "numExecutedHandlers", Type = "number", Nilable = false },
				{ Name = "slowestHandlerName", Type = "cstring", Nilable = false },
				{ Name = "slowestHandlerTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceLocation",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "location", Type = "string", Nilable = false },
			},
		},
		{
			Name = "issecrettable",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a supplied value is a secret table. This function will return true if the table value itself is secret, or if flags on the table are set such that accesses of the table would produce secrets." },

			Arguments =
			{
				{ Name = "table", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSecretOrContentsSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "issecretvalue",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a supplied value is a secret value." },

			Arguments =
			{
				{ Name = "values", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Mixin",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "object", Type = "LuaValueVariant", Nilable = false },
				{ Name = "mixins", Type = "LuaValueVariant", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "outObject", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "RegisterEventCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "callback", Type = "EventCallbackType", Nilable = false },
			},
		},
		{
			Name = "RegisterUnitEventCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "callback", Type = "EventCallbackType", Nilable = false },
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "RunScript",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "secretunwrap",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Unwraps all supplied secrets, converting them back to regular values." },

			Arguments =
			{
				{ Name = "values", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "unwrapped", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "secretwrap",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Converts all supplied values to secret values, preventing most operations on them from occurring on tainted code paths." },

			Arguments =
			{
				{ Name = "values", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "wrapped", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "SetErrorCallstackHeight",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "height", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetTableSecurityOption",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "table", Type = "LuaValueVariant", Nilable = false },
				{ Name = "option", Type = "TableSecurityOption", Nilable = false },
			},
		},
		{
			Name = "UnregisterEventCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "callback", Type = "EventCallbackType", Nilable = false },
			},
		},
		{
			Name = "UnregisterUnitEventCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "callback", Type = "EventCallbackType", Nilable = false },
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "debugprofilestart",
			Type = "Function",
			Documentation = { "Starts a timer for profiling. The final time can be obtained by calling debugprofilestop." },
		},
		{
			Name = "debugprofilestop",
			Type = "Function",
			Documentation = { "Returns the time in milliseconds since the last debugprofilestart call." },

			Returns =
			{
				{ Name = "elapsedMilliseconds", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "TableSecurityOption",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "DisallowTaintedAccess", Type = "TableSecurityOption", EnumValue = 0 },
				{ Name = "DisallowSecretKeys", Type = "TableSecurityOption", EnumValue = 1 },
				{ Name = "SecretWrapContents", Type = "TableSecurityOption", EnumValue = 2 },
			},
		},
		{
			Name = "EventCallbackType",
			Type = "CallbackType",
		},
	},
};

APIDocumentation:AddDocumentationTable(FrameScript);