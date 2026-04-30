local Cursor =
{
	Name = "Cursor",
	Type = "System",
	Namespace = "C_Cursor",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCursorItem",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "item", Type = "ItemLocation", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BattlePetCursorClear",
			Type = "Event",
			LiteralName = "BATTLE_PET_CURSOR_CLEAR",
			SynchronousEvent = true,
		},
		{
			Name = "CursorChanged",
			Type = "Event",
			LiteralName = "CURSOR_CHANGED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(Cursor);