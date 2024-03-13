local ImmersiveInteractionManager =
{
	Name = "ImmersiveInteraction",
	Type = "System",
	Namespace = "C_ImmersiveInteraction",

	Functions =
	{
		{
			Name = "HasImmersiveInteraction",
			Type = "Function",

			Returns =
			{
				{ Name = "immersiveInteraction", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ImmersiveInteractionBegin",
			Type = "Event",
			LiteralName = "IMMERSIVE_INTERACTION_BEGIN",
		},
		{
			Name = "ImmersiveInteractionEnd",
			Type = "Event",
			LiteralName = "IMMERSIVE_INTERACTION_END",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ImmersiveInteractionManager);