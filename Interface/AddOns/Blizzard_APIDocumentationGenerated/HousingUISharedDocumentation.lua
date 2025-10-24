local HousingUIShared =
{
	Tables =
	{
		{
			Name = "HouseLevelRewardType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Value", Type = "HouseLevelRewardType", EnumValue = 0 },
				{ Name = "Object", Type = "HouseLevelRewardType", EnumValue = 1 },
			},
		},
		{
			Name = "HouseLevelRewardValueType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "ExteriorDecor", Type = "HouseLevelRewardValueType", EnumValue = 0 },
				{ Name = "InteriorDecor", Type = "HouseLevelRewardValueType", EnumValue = 1 },
				{ Name = "Rooms", Type = "HouseLevelRewardValueType", EnumValue = 2 },
				{ Name = "Fixtures", Type = "HouseLevelRewardValueType", EnumValue = 3 },
			},
		},
		{
			Name = "HouseInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "plotID", Type = "number", Nilable = false },
				{ Name = "houseName", Type = "string", Nilable = true },
				{ Name = "ownerName", Type = "string", Nilable = true },
				{ Name = "plotCost", Type = "number", Nilable = true },
				{ Name = "neighborhoodName", Type = "string", Nilable = true },
				{ Name = "moveOutTime", Type = "time_t", Nilable = true },
				{ Name = "plotReserved", Type = "bool", Nilable = true },
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "houseGUID", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "HouseLevelFavor",
			Type = "Structure",
			Fields =
			{
				{ Name = "houseGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "houseLevel", Type = "number", Nilable = false },
				{ Name = "houseFavor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HouseLevelReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "HouseLevelRewardType", Nilable = false },
				{ Name = "asset", Type = "ModelAsset", Nilable = true },
				{ Name = "iconTexture", Type = "FileAsset", Nilable = true },
				{ Name = "iconAtlas", Type = "textureAtlas", Nilable = true },
				{ Name = "objectName", Type = "string", Nilable = true },
				{ Name = "tooltipText", Type = "string", Nilable = true },
				{ Name = "valueType", Type = "HouseLevelRewardValueType", Nilable = true },
				{ Name = "oldValue", Type = "number", Nilable = true },
				{ Name = "newValue", Type = "number", Nilable = true },
			},
		},
		{
			Name = "HouseOwnerCharacterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "characterName", Type = "string", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
				{ Name = "error", Type = "HouseOwnerError", Nilable = false },
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HouseholdMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "characterName", Type = "string", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "NeighborhoodInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "neighborhoodType", Type = "NeighborhoodType", Nilable = false },
				{ Name = "neighborhoodOwnerType", Type = "NeighborhoodOwnerType", Nilable = false, Default = "None" },
				{ Name = "neighborhoodName", Type = "string", Nilable = false },
				{ Name = "neighborhoodGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "ownerGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "suggestionReason", Type = "HouseFinderSuggestionReason", Nilable = true },
				{ Name = "ownerName", Type = "string", Nilable = true },
				{ Name = "locationName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "NeighborhoodPlotMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "mapPosition", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "plotDataID", Type = "number", Nilable = false },
				{ Name = "plotID", Type = "number", Nilable = false },
				{ Name = "ownerType", Type = "HousingPlotOwnerType", Nilable = false, Default = "None" },
				{ Name = "plotCost", Type = "number", Nilable = true },
				{ Name = "ownerName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "NeighborhoodRosterMemberInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "residentName", Type = "string", Nilable = false },
				{ Name = "residentType", Type = "ResidentType", Nilable = false },
				{ Name = "isOnline", Type = "bool", Nilable = false },
				{ Name = "plotID", Type = "number", Nilable = false },
				{ Name = "subdivision", Type = "number", Nilable = true },
			},
		},
		{
			Name = "NeighborhoodRosterMemberUpdateInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "residentType", Type = "ResidentType", Nilable = false },
				{ Name = "isOnline", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingUIShared);