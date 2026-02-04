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
		{
			Name = "WorldCursorTooltipUpdate",
			Type = "Event",
			LiteralName = "WORLD_CURSOR_TOOLTIP_UPDATE",
			SynchronousEvent = true,
			Documentation = { "Sends an update when the mouse enters or leaves something in-world (object, unit, etc) that should display a tooltip" },
			Payload =
			{
				{ Name = "anchorType", Type = "WorldCursorAnchorType", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Cursor);