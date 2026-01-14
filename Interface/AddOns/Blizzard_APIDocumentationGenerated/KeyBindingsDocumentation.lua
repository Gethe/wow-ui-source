local KeyBindings =
{
	Name = "KeyBindings",
	Type = "System",
	Namespace = "C_KeyBindings",

	Functions =
	{
		{
			Name = "ActivateBindingContext",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "newContext", Type = "BindingContext", Nilable = false },
			},
		},
		{
			Name = "DeactivateBindingContext",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "context", Type = "BindingContext", Nilable = false },
			},
		},
		{
			Name = "GetBindingByKey",
			Type = "Function",

			Arguments =
			{
				{ Name = "action", Type = "cstring", Nilable = false },
				{ Name = "context", Type = "BindingContext", Nilable = true },
			},

			Returns =
			{
				{ Name = "binding", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetBindingContextForAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "action", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "context", Type = "BindingContext", Nilable = true },
			},
		},
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
		{
			Name = "GetSearchTagsForAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "action", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "searchTags", Type = "table", InnerType = "string", Nilable = true },
			},
		},
		{
			Name = "GetTurnStrafeStyle",
			Type = "Function",

			Returns =
			{
				{ Name = "style", Type = "TurnStrafeStyle", Nilable = false },
			},
		},
		{
			Name = "IsBindingContextActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "context", Type = "BindingContext", Nilable = false },
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTurnStrafeStyle",
			Type = "Function",
			Documentation = { "Can only set to Modern or Legacy." },

			Arguments =
			{
				{ Name = "style", Type = "TurnStrafeStyle", Nilable = false },
			},
		},
		{
			Name = "UpdateTurnStrafeBindingsForCharacter",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "BindingsLoaded",
			Type = "Event",
			LiteralName = "BINDINGS_LOADED",
		},
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
			Name = "NotifyTurnStrafeChange",
			Type = "Event",
			LiteralName = "NOTIFY_TURN_STRAFE_CHANGE",
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
			Name = "BindingContext",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "None", Type = "BindingContext", EnumValue = 0 },
				{ Name = "HousingEditor", Type = "BindingContext", EnumValue = 1 },
				{ Name = "HousingEditorBasicDecorMode", Type = "BindingContext", EnumValue = 2 },
				{ Name = "HousingEditorExpertDecorMode", Type = "BindingContext", EnumValue = 3 },
				{ Name = "HousingEditorCustomizeMode", Type = "BindingContext", EnumValue = 4 },
				{ Name = "HousingEditorCleanupMode", Type = "BindingContext", EnumValue = 5 },
				{ Name = "HousingEditorLayoutMode", Type = "BindingContext", EnumValue = 6 },
				{ Name = "HousingEditorBasicAndExpertDecorMode", Type = "BindingContext", EnumValue = 7 },
				{ Name = "HousingEditorExteriorCustomizationMode", Type = "BindingContext", EnumValue = 8 },
				{ Name = "ReservedFutureFeatureBinding01", Type = "BindingContext", EnumValue = 9 },
			},
		},
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
		{
			Name = "TurnStrafeStyle",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Modern", Type = "TurnStrafeStyle", EnumValue = 0 },
				{ Name = "Legacy", Type = "TurnStrafeStyle", EnumValue = 1 },
				{ Name = "Custom", Type = "TurnStrafeStyle", EnumValue = 2 },
			},
		},
		{
			Name = "InputCommandCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "keystate", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(KeyBindings);