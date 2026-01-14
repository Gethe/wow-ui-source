local Vehicle =
{
	Name = "Vehicle",
	Type = "System",
	Namespace = "C_Vehicle",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "PlayerGainsVehicleData",
			Type = "Event",
			LiteralName = "PLAYER_GAINS_VEHICLE_DATA",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
				{ Name = "vehicleUIIndicatorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerLosesVehicleData",
			Type = "Event",
			LiteralName = "PLAYER_LOSES_VEHICLE_DATA",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "UnitEnteredVehicle",
			Type = "Event",
			LiteralName = "UNIT_ENTERED_VEHICLE",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
				{ Name = "showVehicleFrame", Type = "bool", Nilable = false },
				{ Name = "isControlSeat", Type = "bool", Nilable = false },
				{ Name = "vehicleUIIndicatorID", Type = "number", Nilable = false },
				{ Name = "vehicleGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "mayChooseExit", Type = "bool", Nilable = false },
				{ Name = "hasPitch", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitEnteringVehicle",
			Type = "Event",
			LiteralName = "UNIT_ENTERING_VEHICLE",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
				{ Name = "showVehicleFrame", Type = "bool", Nilable = false },
				{ Name = "isControlSeat", Type = "bool", Nilable = false },
				{ Name = "vehicleUIIndicatorID", Type = "number", Nilable = false },
				{ Name = "vehicleGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "mayChooseExit", Type = "bool", Nilable = false },
				{ Name = "hasPitch", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitExitedVehicle",
			Type = "Event",
			LiteralName = "UNIT_EXITED_VEHICLE",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "UnitExitingVehicle",
			Type = "Event",
			LiteralName = "UNIT_EXITING_VEHICLE",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "VehicleAngleShow",
			Type = "Event",
			LiteralName = "VEHICLE_ANGLE_SHOW",
			Payload =
			{
				{ Name = "shouldShow", Type = "number", Nilable = true },
			},
		},
		{
			Name = "VehiclePassengersChanged",
			Type = "Event",
			LiteralName = "VEHICLE_PASSENGERS_CHANGED",
		},
		{
			Name = "VehiclePowerShow",
			Type = "Event",
			LiteralName = "VEHICLE_POWER_SHOW",
			Payload =
			{
				{ Name = "shouldShow", Type = "number", Nilable = true },
			},
		},
		{
			Name = "VehicleUpdate",
			Type = "Event",
			LiteralName = "VEHICLE_UPDATE",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Vehicle);