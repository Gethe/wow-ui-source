local Vehicle =
{
	Name = "Vehicle",
	Type = "System",
	Namespace = "C_Vehicle",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "PlayerGainsVehicleData",
			Type = "Event",
			LiteralName = "PLAYER_GAINS_VEHICLE_DATA",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
				{ Name = "vehicleUIIndicatorID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PlayerLosesVehicleData",
			Type = "Event",
			LiteralName = "PLAYER_LOSES_VEHICLE_DATA",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitEnteredVehicle",
			Type = "Event",
			LiteralName = "UNIT_ENTERED_VEHICLE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "UnitExitingVehicle",
			Type = "Event",
			LiteralName = "UNIT_EXITING_VEHICLE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitTokenVariant", Nilable = false },
			},
		},
		{
			Name = "VehicleAngleShow",
			Type = "Event",
			LiteralName = "VEHICLE_ANGLE_SHOW",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "shouldShow", Type = "number", Nilable = true },
			},
		},
		{
			Name = "VehiclePassengersChanged",
			Type = "Event",
			LiteralName = "VEHICLE_PASSENGERS_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "VehiclePowerShow",
			Type = "Event",
			LiteralName = "VEHICLE_POWER_SHOW",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "shouldShow", Type = "number", Nilable = true },
			},
		},
		{
			Name = "VehicleUpdate",
			Type = "Event",
			LiteralName = "VEHICLE_UPDATE",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Vehicle);