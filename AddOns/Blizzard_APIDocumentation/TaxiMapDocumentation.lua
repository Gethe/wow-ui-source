local TaxiMap =
{
	Name = "TaxiMap",
	Type = "System",
	Namespace = "C_TaxiMap",

	Functions =
	{
		{
			Name = "GetAllTaxiNodes",
			Type = "Function",
			Documentation = { "Returns information on taxi nodes at the given flight master." },

			Returns =
			{
				{ Name = "taxiNodes", Type = "table", InnerType = "TaxiNodeInfo", Nilable = false },
			},
		},
		{
			Name = "GetTaxiNodesForMap",
			Type = "Function",
			Documentation = { "Returns information on taxi nodes for a given map, without considering the current flight master." },

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mapTaxiNodes", Type = "table", InnerType = "MapTaxiNodeInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "TaximapClosed",
			Type = "Event",
			LiteralName = "TAXIMAP_CLOSED",
		},
		{
			Name = "TaximapOpened",
			Type = "Event",
			LiteralName = "TAXIMAP_OPENED",
			Payload =
			{
				{ Name = "system", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "FlightPathFaction",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Neutral", Type = "FlightPathFaction", EnumValue = 0 },
				{ Name = "Horde", Type = "FlightPathFaction", EnumValue = 1 },
				{ Name = "Alliance", Type = "FlightPathFaction", EnumValue = 2 },
			},
		},
		{
			Name = "FlightPathState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Current", Type = "FlightPathState", EnumValue = 0 },
				{ Name = "Reachable", Type = "FlightPathState", EnumValue = 1 },
				{ Name = "Unreachable", Type = "FlightPathState", EnumValue = 2 },
			},
		},
		{
			Name = "TaxiNodeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "state", Type = "FlightPathState", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = false },
				{ Name = "textureKitPrefix", Type = "string", Nilable = true },
			},
		},
		{
			Name = "MapTaxiNodeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
				{ Name = "faction", Type = "FlightPathFaction", Nilable = false },
				{ Name = "textureKitPrefix", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TaxiMap);