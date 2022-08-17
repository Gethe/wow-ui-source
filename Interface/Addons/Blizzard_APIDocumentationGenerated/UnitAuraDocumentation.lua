local UnitAura =
{
	Name = "UnitAuraUpdate",
	Type = "System",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "UnitAura",
			Type = "Event",
			LiteralName = "UNIT_AURA",
			Payload =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitAura);