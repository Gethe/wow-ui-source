local SimpleFrameScriptObjectAPI =
{
	Name = "SimpleFrameScriptObjectAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddForbiddenAspects",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "NotAllowed",
			Documentation = { "Adds forbidden aspects to a script object, restricting access to various functionalities such as script bindings." },

			Arguments =
			{
				{ Name = "aspect", Type = "ForbiddenAspect", Nilable = false },
			},
		},
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
			Name = "GetObjectTable",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "objectTable", Type = "FrameScriptObject", Nilable = false },
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
			Name = "HasAnyForbiddenAspect",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectSecurity },
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if this object has any of the supplied forbidden aspects added." },

			Arguments =
			{
				{ Name = "aspect", Type = "ForbiddenAspect", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasAnyForbiddenAspect", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasAnyForbiddenAspects",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectSecurity },
			Documentation = { "Returns true if this object has any forbidden aspects." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasAnyForbiddenAspects", Type = "bool", Nilable = false },
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
			SecretReturnsForAspect = { Enum.SecretAspect.ObjectSecrets },

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
			Name = "SetToDefaults",
			Type = "Function",
			IsProtectedFunction = true,
			ChecksForbiddenAspects = { { Argument = "self", Aspect = Enum.ForbiddenAspect.SetToDefaults } },
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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleFrameScriptObjectAPI);