local Bounties =
{
	Name = "Bounties",
	Type = "System",
	Namespace = "C_Bounties",

	Functions =
	{
		{
			Name = "GetBountiesForMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bounties", Type = "table", InnerType = "BountyInfo", Nilable = true },
			},
		},
		{
			Name = "GetBountyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "bountyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bounty", Type = "BountyInfo", Nilable = true },
			},
		},
		{
			Name = "GetBountySetInfoForMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "displayLocation", Type = "MapOverlayDisplayLocation", Nilable = false },
				{ Name = "lockQuestID", Type = "number", Nilable = false },
				{ Name = "bountySetID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "MapOverlayDisplayLocation",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Default", Type = "MapOverlayDisplayLocation", EnumValue = 0 },
				{ Name = "BottomLeft", Type = "MapOverlayDisplayLocation", EnumValue = 1 },
				{ Name = "TopLeft", Type = "MapOverlayDisplayLocation", EnumValue = 2 },
				{ Name = "BottomRight", Type = "MapOverlayDisplayLocation", EnumValue = 3 },
				{ Name = "TopRight", Type = "MapOverlayDisplayLocation", EnumValue = 4 },
				{ Name = "Hidden", Type = "MapOverlayDisplayLocation", EnumValue = 5 },
			},
		},
		{
			Name = "BountyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "factionID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "numObjectives", Type = "number", Nilable = false },
				{ Name = "turninRequirementText", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Bounties);