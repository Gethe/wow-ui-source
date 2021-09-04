local PlayerChoice =
{
	Name = "PlayerChoice",
	Type = "System",
	Namespace = "C_PlayerChoice",

	Functions =
	{
		{
			Name = "GetCurrentPlayerChoiceInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "choiceInfo", Type = "PlayerChoiceInfo", Nilable = false },
			},
		},
		{
			Name = "GetNumRerolls",
			Type = "Function",

			Returns =
			{
				{ Name = "numRerolls", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsWaitingForPlayerChoiceResponse",
			Type = "Function",

			Returns =
			{
				{ Name = "isWaitingForResponse", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OnUIClosed",
			Type = "Function",
		},
		{
			Name = "RequestRerollPlayerChoice",
			Type = "Function",
		},
		{
			Name = "SendPlayerChoiceResponse",
			Type = "Function",

			Arguments =
			{
				{ Name = "responseID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "PlayerChoiceClose",
			Type = "Event",
			LiteralName = "PLAYER_CHOICE_CLOSE",
		},
		{
			Name = "PlayerChoiceUpdate",
			Type = "Event",
			LiteralName = "PLAYER_CHOICE_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "PlayerChoiceRarity",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Common", Type = "PlayerChoiceRarity", EnumValue = 0 },
				{ Name = "Uncommon", Type = "PlayerChoiceRarity", EnumValue = 1 },
				{ Name = "Rare", Type = "PlayerChoiceRarity", EnumValue = 2 },
				{ Name = "Epic", Type = "PlayerChoiceRarity", EnumValue = 3 },
			},
		},
		{
			Name = "PlayerChoiceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "choiceID", Type = "number", Nilable = false },
				{ Name = "questionText", Type = "string", Nilable = false },
				{ Name = "uiTextureKit", Type = "string", Nilable = false },
				{ Name = "hideWarboardHeader", Type = "bool", Nilable = false },
				{ Name = "keepOpenAfterChoice", Type = "bool", Nilable = false },
				{ Name = "options", Type = "table", InnerType = "PlayerChoiceOptionInfo", Nilable = false },
				{ Name = "soundKitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PlayerChoiceOptionButtonInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "disabled", Type = "bool", Nilable = false },
				{ Name = "confirmation", Type = "string", Nilable = true },
				{ Name = "tooltip", Type = "string", Nilable = true },
				{ Name = "rewardQuestID", Type = "number", Nilable = true },
				{ Name = "soundKitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PlayerChoiceOptionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "header", Type = "string", Nilable = false },
				{ Name = "choiceArtID", Type = "number", Nilable = false },
				{ Name = "desaturatedArt", Type = "bool", Nilable = false },
				{ Name = "disabledOption", Type = "bool", Nilable = false },
				{ Name = "hasRewards", Type = "bool", Nilable = false },
				{ Name = "rewardInfo", Type = "PlayerChoiceOptionRewardInfo", Nilable = false },
				{ Name = "rarity", Type = "PlayerChoiceRarity", Nilable = false },
				{ Name = "uiTextureKit", Type = "string", Nilable = false },
				{ Name = "maxStacks", Type = "number", Nilable = false },
				{ Name = "buttons", Type = "table", InnerType = "PlayerChoiceOptionButtonInfo", Nilable = false },
				{ Name = "widgetSetID", Type = "number", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "rarityColor", Type = "table", Mixin = "ColorMixin", Nilable = true },
				{ Name = "typeArtID", Type = "number", Nilable = true },
				{ Name = "headerIconAtlasElement", Type = "string", Nilable = true },
				{ Name = "subHeader", Type = "string", Nilable = true },
			},
		},
		{
			Name = "PlayerChoiceOptionRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyRewards", Type = "table", InnerType = "PlayerChoiceRewardCurrencyInfo", Nilable = false },
				{ Name = "itemRewards", Type = "table", InnerType = "PlayerChoiceRewardItemInfo", Nilable = false },
				{ Name = "repRewards", Type = "table", InnerType = "PlayerChoiceRewardReputationInfo", Nilable = false },
			},
		},
		{
			Name = "PlayerChoiceRewardCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "currencyTexture", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "isCurrencyContainer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerChoiceRewardItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerChoiceRewardReputationInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "factionId", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PlayerChoice);