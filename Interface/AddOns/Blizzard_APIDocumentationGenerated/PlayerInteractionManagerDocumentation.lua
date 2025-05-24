local PlayerInteractionManager =
{
	Name = "PlayerInteractionManager",
	Type = "System",
	Namespace = "C_PlayerInteractionManager",

	Functions =
	{
		{
			Name = "ClearInteraction",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "PlayerInteractionType", Nilable = true },
			},
		},
		{
			Name = "ConfirmationInteraction",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "PlayerInteractionType", Nilable = true },
			},
		},
		{
			Name = "InteractUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
				{ Name = "exactMatch", Type = "bool", Nilable = false, Default = false },
				{ Name = "looseTargeting", Type = "bool", Nilable = false, Default = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInteractingWithNpcOfType",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "PlayerInteractionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "interacting", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsReplacingUnit",
			Type = "Function",

			Returns =
			{
				{ Name = "replacing", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidNPCInteraction",
			Type = "Function",

			Arguments =
			{
				{ Name = "type", Type = "PlayerInteractionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValidInteraction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ReopenInteraction",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "PlayerInteractionManagerFrameHide",
			Type = "Event",
			LiteralName = "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
			Payload =
			{
				{ Name = "type", Type = "PlayerInteractionType", Nilable = false },
			},
		},
		{
			Name = "PlayerInteractionManagerFrameShow",
			Type = "Event",
			LiteralName = "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
			Payload =
			{
				{ Name = "type", Type = "PlayerInteractionType", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PlayerInteractionManager);