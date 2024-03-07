local KeyBindings =
{
	Name = "KeyBindings",
	Type = "System",
	Namespace = "C_KeyBindings",

	Functions =
	{
		{
			Name = "GetBindingIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "action", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "bindingIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetCustomBindingType",
			Type = "Function",

			Arguments =
			{
				{ Name = "bindingIndex", Type = "luaIndex", Nilable = false },
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
				{ Name = "key", Type = "cstring", Nilable = false },
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
			Name = "BindingSet",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Default", Type = "BindingSet", EnumValue = 0 },
				{ Name = "Account", Type = "BindingSet", EnumValue = 1 },
				{ Name = "Character", Type = "BindingSet", EnumValue = 2 },
				{ Name = "Current", Type = "BindingSet", EnumValue = 3 },
			},
		},
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