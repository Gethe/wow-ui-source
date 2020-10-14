local PlayerChoice =
{
	Name = "PlayerChoice",
	Type = "System",
	Namespace = "C_PlayerChoice",

	Functions =
	{
		{
			Name = "GetPlayerChoiceInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "choiceInfo", Type = "PlayerChoiceInfo", Nilable = false },
			},
		},
		{
			Name = "GetPlayerChoiceOptionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "PlayerChoiceOptionInfo", Nilable = false },
			},
		},
		{
			Name = "GetPlayerChoiceRewardInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "rewardIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rewardInfo", Type = "PlayerChoiceRewardInfo", Nilable = false },
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
				{ Name = "numOptions", Type = "number", Nilable = false },
				{ Name = "uiTextureKit", Type = "string", Nilable = false },
				{ Name = "soundKitID", Type = "number", Nilable = true },
				{ Name = "hideWarboardHeader", Type = "bool", Nilable = false },
				{ Name = "keepOpenAfterChoice", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerChoiceOptionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "responseIdentifier", Type = "number", Nilable = false },
				{ Name = "buttonText", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "header", Type = "string", Nilable = false },
				{ Name = "choiceArtID", Type = "number", Nilable = false },
				{ Name = "confirmation", Type = "string", Nilable = true },
				{ Name = "widgetSetID", Type = "number", Nilable = true },
				{ Name = "disabledButton", Type = "bool", Nilable = false },
				{ Name = "desaturatedArt", Type = "bool", Nilable = false },
				{ Name = "disabledOption", Type = "bool", Nilable = false },
				{ Name = "groupID", Type = "number", Nilable = true },
				{ Name = "headerIconAtlasElement", Type = "string", Nilable = true },
				{ Name = "subHeader", Type = "string", Nilable = true },
				{ Name = "buttonTooltip", Type = "string", Nilable = true },
				{ Name = "rewardQuestID", Type = "number", Nilable = true },
				{ Name = "soundKitID", Type = "number", Nilable = true },
				{ Name = "hasRewards", Type = "bool", Nilable = false },
				{ Name = "rarity", Type = "PlayerChoiceRarity", Nilable = false },
				{ Name = "rarityColor", Type = "table", Mixin = "ColorMixin", Nilable = true },
				{ Name = "typeArtID", Type = "number", Nilable = true },
				{ Name = "uiTextureKit", Type = "string", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "maxStacks", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerChoiceRewardCurrencyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyId", Type = "number", Nilable = false },
				{ Name = "currencyTexture", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerChoiceRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "money", Type = "number", Nilable = true },
				{ Name = "xp", Type = "number", Nilable = true },
				{ Name = "itemRewards", Type = "table", InnerType = "PlayerChoiceRewardItemInfo", Nilable = false },
				{ Name = "currencyRewards", Type = "table", InnerType = "PlayerChoiceRewardCurrencyInfo", Nilable = false },
				{ Name = "repRewards", Type = "table", InnerType = "PlayerChoiceRewardReputationInfo", Nilable = false },
			},
		},
		{
			Name = "PlayerChoiceRewardItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemId", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "textureFileId", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
				{ Name = "itemLink", Type = "string", Nilable = false },
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