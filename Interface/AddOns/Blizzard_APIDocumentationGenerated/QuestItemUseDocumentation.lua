local QuestItemUse =
{
	Name = "QuestItemUse",
	Type = "System",
	Namespace = "C_QuestItemUse",

	Functions =
	{
		{
			Name = "CanUseQuestItemOnObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "checkRange", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "canUse", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(QuestItemUse);