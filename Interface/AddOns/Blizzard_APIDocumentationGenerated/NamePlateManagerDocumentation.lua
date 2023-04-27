local NamePlateManager =
{
	Name = "NamePlateManager",
	Type = "System",
	Namespace = "C_NamePlateManager",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ForbiddenNamePlateCreated",
			Type = "Event",
			LiteralName = "FORBIDDEN_NAME_PLATE_CREATED",
			Payload =
			{
				{ Name = "namePlateFrame", Type = "NamePlateFrame", Nilable = false },
			},
		},
		{
			Name = "ForbiddenNamePlateUnitAdded",
			Type = "Event",
			LiteralName = "FORBIDDEN_NAME_PLATE_UNIT_ADDED",
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ForbiddenNamePlateUnitRemoved",
			Type = "Event",
			LiteralName = "FORBIDDEN_NAME_PLATE_UNIT_REMOVED",
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "NamePlateCreated",
			Type = "Event",
			LiteralName = "NAME_PLATE_CREATED",
			Payload =
			{
				{ Name = "namePlateFrame", Type = "NamePlateFrame", Nilable = false },
			},
		},
		{
			Name = "NamePlateUnitAdded",
			Type = "Event",
			LiteralName = "NAME_PLATE_UNIT_ADDED",
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
		{
			Name = "NamePlateUnitRemoved",
			Type = "Event",
			LiteralName = "NAME_PLATE_UNIT_REMOVED",
			Payload =
			{
				{ Name = "unitToken", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(NamePlateManager);