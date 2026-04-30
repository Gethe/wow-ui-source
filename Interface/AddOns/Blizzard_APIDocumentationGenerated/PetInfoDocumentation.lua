local PetInfo =
{
	Name = "PetInfo",
	Type = "System",
	Namespace = "C_PetInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetPetTalentTree",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "talentTreeName", Type = "stringView", Nilable = false },
			},
		},
		{
			Name = "PetAssistMode",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "PetAttackStart",
			Type = "Event",
			LiteralName = "PET_ATTACK_START",
			SynchronousEvent = true,
		},
		{
			Name = "PetAttackStop",
			Type = "Event",
			LiteralName = "PET_ATTACK_STOP",
			SynchronousEvent = true,
		},
		{
			Name = "PetBarHidegrid",
			Type = "Event",
			LiteralName = "PET_BAR_HIDEGRID",
			SynchronousEvent = true,
		},
		{
			Name = "PetBarShowgrid",
			Type = "Event",
			LiteralName = "PET_BAR_SHOWGRID",
			SynchronousEvent = true,
		},
		{
			Name = "PetBarUpdateCooldown",
			Type = "Event",
			LiteralName = "PET_BAR_UPDATE_COOLDOWN",
			SynchronousEvent = true,
		},
		{
			Name = "PetDismissStart",
			Type = "Event",
			LiteralName = "PET_DISMISS_START",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "delay", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetForceNameDeclension",
			Type = "Event",
			LiteralName = "PET_FORCE_NAME_DECLENSION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "petNumber", Type = "number", Nilable = true },
				{ Name = "declinedName1", Type = "cstring", Nilable = true },
				{ Name = "declinedName2", Type = "cstring", Nilable = true },
				{ Name = "declinedName3", Type = "cstring", Nilable = true },
				{ Name = "declinedName4", Type = "cstring", Nilable = true },
				{ Name = "declinedName5", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "PetUiClose",
			Type = "Event",
			LiteralName = "PET_UI_CLOSE",
			SynchronousEvent = true,
		},
		{
			Name = "RaisedAsGhoul",
			Type = "Event",
			LiteralName = "RAISED_AS_GHOUL",
			SynchronousEvent = true,
		},
		{
			Name = "UpdatePossessBar",
			Type = "Event",
			LiteralName = "UPDATE_POSSESS_BAR",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateVehicleActionbar",
			Type = "Event",
			LiteralName = "UPDATE_VEHICLE_ACTIONBAR",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "PetTamerMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "position", Type = "vector2", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = true },
				{ Name = "textureIndex", Type = "number", Nilable = true },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PetInfo);