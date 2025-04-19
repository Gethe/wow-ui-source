local StableInfo =
{
	Name = "StableInfo",
	Type = "System",
	Namespace = "C_StableInfo",

	Functions =
	{
		{
			Name = "ClosePetStables",
			Type = "Function",
		},
		{
			Name = "GetActivePetList",
			Type = "Function",

			Returns =
			{
				{ Name = "activePets", Type = "table", InnerType = "PetInfo", Nilable = false },
			},
		},
		{
			Name = "GetAvailablePetSpecInfos",
			Type = "Function",

			Returns =
			{
				{ Name = "petSpecInfos", Type = "table", InnerType = "PetSpecInfo", Nilable = false },
			},
		},
		{
			Name = "GetNumActivePets",
			Type = "Function",

			Returns =
			{
				{ Name = "numActivePets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumStablePets",
			Type = "Function",

			Returns =
			{
				{ Name = "numStablePets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStablePetFoodTypes",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "foodTypes", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetStablePetInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "petInfo", Type = "PetInfo", Nilable = true },
			},
		},
		{
			Name = "GetStabledPetList",
			Type = "Function",

			Returns =
			{
				{ Name = "stabledPets", Type = "table", InnerType = "PetInfo", Nilable = false },
			},
		},
		{
			Name = "IsAtStableMaster",
			Type = "Function",

			Returns =
			{
				{ Name = "isAtStableMaster", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPetFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PickupStablePet",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetPetFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetPetSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "PetInfoUpdate",
			Type = "Event",
			LiteralName = "PET_INFO_UPDATE",
		},
		{
			Name = "PetStableClosed",
			Type = "Event",
			LiteralName = "PET_STABLE_CLOSED",
		},
		{
			Name = "PetStableFavoritesUpdated",
			Type = "Event",
			LiteralName = "PET_STABLE_FAVORITES_UPDATED",
		},
		{
			Name = "PetStableShow",
			Type = "Event",
			LiteralName = "PET_STABLE_SHOW",
		},
		{
			Name = "PetStableUpdate",
			Type = "Event",
			LiteralName = "PET_STABLE_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "PetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "slotID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "familyName", Type = "string", Nilable = false },
				{ Name = "specialization", Type = "string", Nilable = false },
				{ Name = "type", Type = "string", Nilable = false },
				{ Name = "petAbilities", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "specAbilities", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "displayID", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isExotic", Type = "bool", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false, Default = 718 },
				{ Name = "petNumber", Type = "number", Nilable = false },
				{ Name = "creatureID", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetSpecInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "specIndex", Type = "luaIndex", Nilable = false },
				{ Name = "specializationName", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(StableInfo);