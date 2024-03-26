local Cursor =
{
	Name = "Cursor",
	Type = "System",
	Namespace = "C_Cursor",

	Functions =
	{
		{
			Name = "GetCursorItem",
			Type = "Function",

			Returns =
			{
				{ Name = "item", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
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
			Name = "MountCursorClear",
			Type = "Event",
			LiteralName = "MOUNT_CURSOR_CLEAR",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Cursor);