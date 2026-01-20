local DeathInfo =
{
	Name = "DeathInfo",
	Type = "System",
	Namespace = "C_DeathInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCorpseMapPosition",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
			},
		},
		{
			Name = "GetDeathReleasePosition",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
			},
		},
		{
			Name = "GetGraveyardsForMap",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "graveyards", Type = "table", InnerType = "GraveyardMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetSelfResurrectOptions",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "options", Type = "table", InnerType = "SelfResurrectOption", Nilable = false },
			},
		},
		{
			Name = "UseSelfResurrectOption",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "optionType", Type = "SelfResurrectOptionType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AreaSpiritHealerInRange",
			Type = "Event",
			LiteralName = "AREA_SPIRIT_HEALER_IN_RANGE",
			SynchronousEvent = true,
		},
		{
			Name = "AreaSpiritHealerOutOfRange",
			Type = "Event",
			LiteralName = "AREA_SPIRIT_HEALER_OUT_OF_RANGE",
			SynchronousEvent = true,
		},
		{
			Name = "CemeteryPreferenceUpdated",
			Type = "Event",
			LiteralName = "CEMETERY_PREFERENCE_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "ConfirmXpLoss",
			Type = "Event",
			LiteralName = "CONFIRM_XP_LOSS",
			SynchronousEvent = true,
		},
		{
			Name = "CorpseInInstance",
			Type = "Event",
			LiteralName = "CORPSE_IN_INSTANCE",
			SynchronousEvent = true,
		},
		{
			Name = "CorpseInRange",
			Type = "Event",
			LiteralName = "CORPSE_IN_RANGE",
			SynchronousEvent = true,
		},
		{
			Name = "CorpseOutOfRange",
			Type = "Event",
			LiteralName = "CORPSE_OUT_OF_RANGE",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerAlive",
			Type = "Event",
			LiteralName = "PLAYER_ALIVE",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerDead",
			Type = "Event",
			LiteralName = "PLAYER_DEAD",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerSkinned",
			Type = "Event",
			LiteralName = "PLAYER_SKINNED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasFreeRepop", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerUnghost",
			Type = "Event",
			LiteralName = "PLAYER_UNGHOST",
			SynchronousEvent = true,
		},
		{
			Name = "RequestCemeteryListResponse",
			Type = "Event",
			LiteralName = "REQUEST_CEMETERY_LIST_RESPONSE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isGossipTriggered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ResurrectRequest",
			Type = "Event",
			LiteralName = "RESURRECT_REQUEST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "inviter", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SelfResSpellChanged",
			Type = "Event",
			LiteralName = "SELF_RES_SPELL_CHANGED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "SelfResurrectOptionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Spell", Type = "SelfResurrectOptionType", EnumValue = 0 },
				{ Name = "Item", Type = "SelfResurrectOptionType", EnumValue = 1 },
			},
		},
		{
			Name = "GraveyardMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "textureIndex", Type = "number", Nilable = false },
				{ Name = "graveyardID", Type = "number", Nilable = false },
				{ Name = "isGraveyardSelectable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SelfResurrectOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "optionType", Type = "SelfResurrectOptionType", Nilable = false },
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "isLimited", Type = "bool", Nilable = false },
				{ Name = "priority", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DeathInfo);