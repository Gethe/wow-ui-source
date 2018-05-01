local PetInfo =
{
	Name = "PetInfo",
	Type = "System",
	Namespace = "C_PetInfo",

	Functions =
	{
		{
			Name = "GetPetTamersForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "petTamers", Type = "table", InnerType = "PetTamerMapInfo", Nilable = false },
			},
		},
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
		{
			Name = "RaisedAsGhoul",
			Type = "Event",
			LiteralName = "RAISED_AS_GHOUL",
		},
		{
			Name = "UpdatePossessBar",
			Type = "Event",
			LiteralName = "UPDATE_POSSESS_BAR",
		},
		{
			Name = "UpdateVehicleActionbar",
			Type = "Event",
			LiteralName = "UPDATE_VEHICLE_ACTIONBAR",
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
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = true },
				{ Name = "textureIndex", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PetInfo);