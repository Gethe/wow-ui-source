local Cursor =
{
	Name = "Cursor",
	Type = "System",
	Namespace = "C_Cursor",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "BattlePetCursorClear",
			Type = "Event",
			LiteralName = "BATTLE_PET_CURSOR_CLEAR",
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
	},
};

APIDocumentation:AddDocumentationTable(Cursor);