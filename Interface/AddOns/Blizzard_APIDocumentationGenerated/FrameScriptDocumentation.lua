local FrameScript =
{
	Name = "FrameScript",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddSourceLocationExclude",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fileName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "canaccessallvalues",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the immediate calling function has appropriate permissions to access and operate on all supplied values." },

			Arguments =
			{
				{ Name = "values", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "canAccessAllValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "canaccesssecrets",
			Type = "Function",
			SecureHooksAllowed = false,
			Documentation = { "Returns true if the immediate calling function has appropriate permissions to access or operate on secret values." },

			Returns =
			{
				{ Name = "canAccessSecrets", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "canaccesstable",
			Type = "Function",
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the immediate calling function has appropriate permissions to access and operate on a specific value." },

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
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Creates a secure delegate closure for a Lua function. The delegate invokes the original function in a protected call context with secure execution taint, and supports passing and returning values directly." },

			Arguments =
			{
				{ Name = "luaFunction", Type = "LuaValueReference", Nilable = false, Documentation = { "The Lua function to invoke through the secure delegate." } },
				{ Name = "options", Type = "SecureDelegateOptions", Nilable = true, Documentation = { "Optional settings controlling secure delegate behavior. If omitted, default options are used." } },
			},

			Returns =
			{
				{ Name = "secureDelegateFunction", Type = "LuaValueReference", Nilable = false, Documentation = { "A secure delegate function that calls through to the original Lua function." } },
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
			SecureHooksAllowed = false,
			Documentation = { "Removes the ability for the immediate calling function to access secret values." },
		},
		{
			Name = "dumpobject",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Invokes the '__dump' metamethod on any value (if present), returning its result." },

			Arguments =
			{
				{ Name = "value", Type = "LuaValueReference", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaValueReference", Nilable = true },
			},
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
			Name = "GetForbiddenObjectTable",
			Type = "Function",
			Environment = "SecureOnly",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "object", Type = "FrameScriptObject", Nilable = false },
			},

			Returns =
			{
				{ Name = "forbiddenTable", Type = "FrameScriptObject", Nilable = false },
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
			Name = "hasanysecretvalues",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a supplied value is a secret value." },

			Arguments =
			{
				{ Name = "values", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "isAnyValueSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "issecrettable",
			Type = "Function",
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a supplied value is a secret value." },

			Arguments =
			{
				{ Name = "value", Type = "LuaValueReference", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSecret", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "mapvalues",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Applies a given function over all supplied values individually, replacing the value with the result of the call." },

			Arguments =
			{
				{ Name = "func", Type = "LuaValueReference", Nilable = false },
				{ Name = "values", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "mapped", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "Mixin",
			Type = "Function",
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
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
			Name = "scrubsecretvalues",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a transformed list of values with inputs that are secret values replaced by nil values." },

			Arguments =
			{
				{ Name = "values", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "scrubbed", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "scrub",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a transformed list of values with inputs that are either secret or are not string, number, or boolean type replaced by nil values." },

			Arguments =
			{
				{ Name = "values", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "scrubbed", Type = "LuaValueReference", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "secretunwrap",
			Type = "Function",
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
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
			Name = "securecallmethod",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Invokes a named method on an object with a secure call barrier that prevents errors or taint from function lookup and execution from propagating to the caller." },

			Arguments =
			{
				{ Name = "object", Type = "LuaValueReference", Nilable = false, Documentation = { "The table on which to look up the named method from. Lookup of the method uses raw access and ignores any associated metatable." } },
				{ Name = "method", Type = "cstring", Nilable = false, Documentation = { "The name of a method to retrieve." } },
				{ Name = "arguments", Type = "LuaValueReference", Nilable = false, StrideIndex = 1, Documentation = { "Arguments to supply to the method. The initial 'object' parameter is always supplied as the first argument, followed by these values." } },
			},

			Returns =
			{
				{ Name = "results", Type = "LuaValueReference", Nilable = false, StrideIndex = 1, Documentation = { "Results from the executed function. If an error occurred, this result list will be empty." } },
			},
		},
		{
			Name = "securecopy",
			Type = "Function",
			SecureHooksAllowed = false,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Securely copies a Lua value. Tables are deep-copied with recursive and shared references preserved. Copied values receive the current execution taint." },

			Arguments =
			{
				{ Name = "value", Type = "LuaValueReference", Nilable = true, Documentation = { "The Lua value to copy." } },
				{ Name = "options", Type = "SecureCopyOptions", Nilable = true, Documentation = { "Optional settings controlling value copying behavior. If omitted, default secure copy options are used." } },
			},

			Returns =
			{
				{ Name = "copy", Type = "LuaValueReference", Nilable = false, Documentation = { "The copied value. For tables, recursive and shared references within the copied graph are preserved." } },
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
			Name = "settablesecurity",
			Type = "Function",
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
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
			SecureHooksAllowed = false,
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
			Name = "SecureCopyOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "maxTraversalDepth", Type = "number", Nilable = false, Default = 100, Documentation = { "Maximum table nesting depth allowed during recursive copying." } },
				{ Name = "wrapUntrustedFunctions", Type = "bool", Nilable = false, Default = true, Documentation = { "Wrap function values in secure closures that call through using the original function taint." } },
				{ Name = "permitScriptObjects", Type = "bool", Nilable = false, Default = false, Documentation = { "If true, preserve references to script objects in the copied output. By default, script objects will raise an error." } },
			},
		},
		{
			Name = "SecureDelegateOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "wrapUntrustedFunctions", Type = "bool", Nilable = false, Default = true, Documentation = { "Wrap function arguments in secure closures that call through using the original function taint." } },
			},
		},
		{
			Name = "EventCallbackType",
			Type = "CallbackType",
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(FrameScript);