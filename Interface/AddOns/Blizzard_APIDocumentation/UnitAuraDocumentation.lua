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
				{ Name = "isFullUpdate", Type = "bool", Nilable = false },
				{ Name = "updatedAuras", Type = "table", InnerType = "UnitAuraUpdateInfo", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitAura);