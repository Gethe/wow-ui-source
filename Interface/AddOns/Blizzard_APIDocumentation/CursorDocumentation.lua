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