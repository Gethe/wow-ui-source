local AutoLoot =
{
	Name = "AutoLoot",
	Type = "System",
	Namespace = "C_AutoLoot",
	Environment = "All",

	Functions =
	{
		{
			Name = "SetUseAutoLootToggle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "useAutoLootToggle", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(AutoLoot);