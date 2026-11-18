local MawBuffs =
{
	Name = "MawBuffs",
	Type = "System",
	Namespace = "C_MawBuffs",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetMawBuff",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the player's MAW buff at the given index, or nil if there is none." },

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "aura", Type = "AuraData", Nilable = true },
			},
		},
		{
			Name = "HasAnyMawBuffs",
			Type = "Function",
			Documentation = { "Returns whether the player currently has any MAW buffs." },

			Returns =
			{
				{ Name = "hasAny", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(MawBuffs);