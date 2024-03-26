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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GameCursor);