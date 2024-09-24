local GameRules =
{
	Name = "GameRules",
	Type = "System",
	Namespace = "C_GameRules",

	Functions =
	{
		{
			Name = "GetGameRuleAsFloat",
			Type = "Function",
			Documentation = { "Returns the numeric value specified in the Game Rule, multiplied by 0.1 for every decimal place requested" },

			Arguments =
			{
				{ Name = "gameRule", Type = "GameRule", Nilable = false },
				{ Name = "decimalPlaces", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsGameRuleActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "gameRule", Type = "GameRule", Nilable = false },
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHardcoreActive",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSelfFoundAllowed",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(GameRules);