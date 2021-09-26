local PetInfo =
{
	Name = "PetInfo",
	Type = "System",
	Namespace = "C_PetInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "PetAttackStart",
			Type = "Event",
			LiteralName = "PET_ATTACK_START",
		},
		{
			Name = "PetAttackStop",
			Type = "Event",
			LiteralName = "PET_ATTACK_STOP",
		},
		{
			Name = "PetBarHidegrid",
			Type = "Event",
			LiteralName = "PET_BAR_HIDEGRID",
		},
		{
			Name = "PetBarShowgrid",
			Type = "Event",
			LiteralName = "PET_BAR_SHOWGRID",
		},
		{
			Name = "PetBarUpdateCooldown",
			Type = "Event",
			LiteralName = "PET_BAR_UPDATE_COOLDOWN",
		},
		{
			Name = "PetDismissStart",
			Type = "Event",
			LiteralName = "PET_DISMISS_START",
			Payload =
			{
				{ Name = "delay", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetForceNameDeclension",
			Type = "Event",
			LiteralName = "PET_FORCE_NAME_DECLENSION",
			Payload =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "declinedName1", Type = "string", Nilable = true },
				{ Name = "declinedName2", Type = "string", Nilable = true },
				{ Name = "declinedName3", Type = "string", Nilable = true },
				{ Name = "declinedName4", Type = "string", Nilable = true },
				{ Name = "declinedName5", Type = "string", Nilable = true },
			},
		},
		{
			Name = "PetUiClose",
			Type = "Event",
			LiteralName = "PET_UI_CLOSE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PetInfo);