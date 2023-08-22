local PlayerInfo =
{
	Name = "PlayerInfo",
	Type = "System",
	Namespace = "C_PlayerInfo",

	Functions =
	{
		{
			Name = "CanUseItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUseable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAlternateFormInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "hasAlternateForm", Type = "bool", Nilable = false },
				{ Name = "inAlternateForm", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDisplayID",
			Type = "Function",

			Returns =
			{
				{ Name = "displayID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPlayerCharacterData",
			Type = "Function",

			Returns =
			{
				{ Name = "characterData", Type = "PlayerInfoCharacterData", Nilable = false },
			},
		},
		{
			Name = "HasVisibleInvSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isVisible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsXPUserDisabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isDisabled", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(PlayerInfo);