local Totem =
{
	Name = "Totem",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "DestroyTotem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetNumTotemSlots",
			Type = "Function",

			Returns =
			{
				{ Name = "numSlots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotemCannotDismiss",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "cannotDismiss", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetTotemInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretWhenTotemSlotSecret = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "haveTotem", Type = "bool", Nilable = false },
				{ Name = "totemName", Type = "cstring", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotemTimeLeft",
			Type = "Function",
			SecretWhenTotemSlotSecret = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeLeft", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TargetTotem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "TotemInfoScript",
			Type = "Structure",
			Fields =
			{
				{ Name = "haveTotem", Type = "bool", Nilable = false },
				{ Name = "totemName", Type = "cstring", Nilable = false },
				{ Name = "startTime", Type = "number", Nilable = false },
				{ Name = "duration", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Totem);