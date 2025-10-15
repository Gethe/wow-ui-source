local DamageMeter =
{
	Name = "DamageMeter",
	Type = "System",
	Namespace = "C_DamageMeter",

	Functions =
	{
		{
			Name = "IsDamageMeterAvailable",
			Type = "Function",
			Documentation = { "Returns whether the player can enable and use the Damage Meter." },

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(DamageMeter);