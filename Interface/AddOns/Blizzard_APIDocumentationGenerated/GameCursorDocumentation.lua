local GameCursor =
{
	Name = "GameCursor",
	Type = "System",

	Functions =
	{
		{
			Name = "ClearCursor",
			Type = "Function",
		},
		{
			Name = "ClearCursorHoveredItem",
			Type = "Function",
		},
		{
			Name = "CursorHasItem",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CursorHasMacro",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CursorHasMoney",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CursorHasSpell",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DeleteCursorItem",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "DropCursorMoney",
			Type = "Function",
		},
		{
			Name = "EquipCursorItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetCursorInfo",
			Type = "Function",
		},
		{
			Name = "GetCursorMoney",
			Type = "Function",

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PickupPlayerMoney",
			Type = "Function",

			Arguments =
			{
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
			},
		},
		{
			Name = "ResetCursor",
			Type = "Function",
		},
		{
			Name = "SellCursorItem",
			Type = "Function",
		},
		{
			Name = "SetCursor",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCursorHoveredItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "item", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "SetCursorHoveredItemTradeItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCursorVirtualItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "cursorType", Type = "UICursorType", Nilable = false },
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

APIDocumentation:AddDocumentationTable(GameCursor);