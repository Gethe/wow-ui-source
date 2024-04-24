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
			Name = "GetNativeDisplayID",
			Type = "Function",

			Returns =
			{
				{ Name = "nativeDisplayID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetStableCreatureDisplayInfoID",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = false },
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
			Name = "IsDisplayRaceNative",
			Type = "Function",

			Returns =
			{
				{ Name = "isDisplayRaceNative", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMirrorImage",
			Type = "Function",

			Returns =
			{
				{ Name = "isMirrorImage", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerNPERestricted",
			Type = "Function",

			Returns =
			{
				{ Name = "isRestricted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSelfFoundActive",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
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