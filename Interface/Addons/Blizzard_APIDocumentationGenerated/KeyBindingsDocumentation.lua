local KeyBindings =
{
	Name = "KeyBindings",
	Type = "System",
	Namespace = "C_KeyBindings",

	Functions =
	{
		{
			Name = "GetCustomBindingType",
			Type = "Function",

			Arguments =
			{
				{ Name = "bindingIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "customBindingType", Type = "CustomBindingType", Nilable = true },
			},
		},
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
		{
			Name = "CustomBindingType",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "VoicePushToTalk", Type = "CustomBindingType", EnumValue = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(KeyBindings);