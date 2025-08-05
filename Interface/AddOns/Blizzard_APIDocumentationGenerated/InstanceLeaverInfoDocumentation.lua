local InstanceLeaverInfo =
{
	Name = "InstanceLeaverInfo",
	Type = "System",
	Namespace = "C_InstanceLeaver",

	Functions =
	{
		{
			Name = "IsPlayerLeaver",
			Type = "Function",
			Documentation = { "Returns whether the player is considered a leaver for repeatedly abandoning mythic+ groups." },

			Returns =
			{
				{ Name = "isLeaver", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "InstanceLeaverStatusChanged",
			Type = "Event",
			LiteralName = "INSTANCE_LEAVER_STATUS_CHANGED",
			Payload =
			{
				{ Name = "isLeaver", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(InstanceLeaverInfo);