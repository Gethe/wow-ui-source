local Cursor =
{
	Name = "Cursor",
	Type = "System",
	Namespace = "C_Cursor",

	Functions =
	{
		{
			Name = "DropCursorCommunitiesStream",
			Type = "Function",
		},
		{
			Name = "GetCursorCommunitiesStream",
			Type = "Function",

			Returns =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetCursorItem",
			Type = "Function",

			Returns =
			{
				{ Name = "item", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "SetCursorCommunitiesStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BattlePetCursorClear",
			Type = "Event",
			LiteralName = "BATTLE_PET_CURSOR_CLEAR",
		},
		{
			Name = "CommunitiesStreamCursorClear",
			Type = "Event",
			LiteralName = "COMMUNITIES_STREAM_CURSOR_CLEAR",
		},
		{
			Name = "CursorChanged",
			Type = "Event",
			LiteralName = "CURSOR_CHANGED",
			Payload =
			{
				{ Name = "isDefault", Type = "bool", Nilable = false },
				{ Name = "newCursorType", Type = "UICursorType", Nilable = false },
				{ Name = "oldCursorType", Type = "UICursorType", Nilable = false },
				{ Name = "oldCursorVirtualID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CursorUpdate",
			Type = "Event",
			LiteralName = "CURSOR_UPDATE",
		},
		{
			Name = "MountCursorClear",
			Type = "Event",
			LiteralName = "MOUNT_CURSOR_CLEAR",
		},
	},

	Tables =
	{
		{
			Name = "UICursorType",
			Type = "Enumeration",
			NumValues = 21,
			MinValue = 0,
			MaxValue = 21,
			Fields =
			{
				{ Name = "Default", Type = "UICursorType", EnumValue = 0 },
				{ Name = "Item", Type = "UICursorType", EnumValue = 1 },
				{ Name = "Money", Type = "UICursorType", EnumValue = 2 },
				{ Name = "Spell", Type = "UICursorType", EnumValue = 3 },
				{ Name = "PetAction", Type = "UICursorType", EnumValue = 4 },
				{ Name = "Merchant", Type = "UICursorType", EnumValue = 5 },
				{ Name = "ActionBar", Type = "UICursorType", EnumValue = 6 },
				{ Name = "Macro", Type = "UICursorType", EnumValue = 7 },
				{ Name = "AmmoObsolete", Type = "UICursorType", EnumValue = 9 },
				{ Name = "Pet", Type = "UICursorType", EnumValue = 10 },
				{ Name = "GuildBank", Type = "UICursorType", EnumValue = 11 },
				{ Name = "GuildBankMoney", Type = "UICursorType", EnumValue = 12 },
				{ Name = "EquipmentSet", Type = "UICursorType", EnumValue = 13 },
				{ Name = "Currency", Type = "UICursorType", EnumValue = 14 },
				{ Name = "Flyout", Type = "UICursorType", EnumValue = 15 },
				{ Name = "VoidItem", Type = "UICursorType", EnumValue = 16 },
				{ Name = "BattlePet", Type = "UICursorType", EnumValue = 17 },
				{ Name = "Mount", Type = "UICursorType", EnumValue = 18 },
				{ Name = "Toy", Type = "UICursorType", EnumValue = 19 },
				{ Name = "CommunitiesStream", Type = "UICursorType", EnumValue = 20 },
				{ Name = "ConduitCollectionItem", Type = "UICursorType", EnumValue = 21 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Cursor);