local KeyBindings =
{
	Name = "KeyBindings",
	Type = "System",
	Namespace = "C_KeyBindings",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ModifierStateChanged",
			Type = "Event",
			LiteralName = "MODIFIER_STATE_CHANGED",
			Payload =
			{
				{ Name = "key", Type = "string", Nilable = false },
				{ Name = "down", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UpdateBindings",
			Type = "Event",
			LiteralName = "UPDATE_BINDINGS",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(KeyBindings);