local SimpleFrameScriptObjectAPI =
{
	Name = "SimpleFrameScriptObjectAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetName",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectName },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetObjectType",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectType },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "objectType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "HasAnySecretAspect",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectSecrets },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretAspect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSecretAspect",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectSecrets },
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "aspect", Type = "SecretAspect", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSecretAspect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSecretValues",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectSecrets },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsForbidden",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectSecurity },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isForbidden", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsObjectType",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectType },
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "objectType", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isType", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPreventingSecretValues",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isPreventingSecretValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetForbidden",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetPreventSecretValues",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "preventSecretValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetToDefaults",
			Type = "Function",
			IsProtectedFunction = true,
			Documentation = { "Reset all script accessible values to their default values. If possible, clears secret states." },

			Arguments =
			{
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleFrameScriptObjectAPI);