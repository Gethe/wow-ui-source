local MountConstants =
{
	Tables =
	{
		{
			Name = "MountType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Ground", Type = "MountType", EnumValue = 0 },
				{ Name = "Flying", Type = "MountType", EnumValue = 1 },
				{ Name = "Aquatic", Type = "MountType", EnumValue = 2 },
				{ Name = "Dragonriding", Type = "MountType", EnumValue = 3 },
				{ Name = "RideAlong", Type = "MountType", EnumValue = 4 },
			},
		},
		{
			Name = "MountTypeFlag",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "IsFlyingMount", Type = "MountTypeFlag", EnumValue = 1 },
				{ Name = "IsAquaticMount", Type = "MountTypeFlag", EnumValue = 2 },
				{ Name = "IsDragonRidingMount", Type = "MountTypeFlag", EnumValue = 4 },
				{ Name = "IsRideAlongMount", Type = "MountTypeFlag", EnumValue = 8 },
			},
		},
		{
			Name = "MountDynamicFlightConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "TRAIT_SYSTEM_ID", Type = "number", Value = 1 },
				{ Name = "TREE_ID", Type = "number", Value = 672 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MountConstants);