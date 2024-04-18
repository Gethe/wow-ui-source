local ClickBindings =
{
	Name = "ClickBindings",
	Type = "System",
	Namespace = "C_ClickBindings",

	Functions =
	{
		{
			Name = "CanSpellBeClickBound",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canBeBound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ExecuteBinding",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetToken", Type = "cstring", Nilable = false },
				{ Name = "button", Type = "cstring", Nilable = false },
				{ Name = "modifiers", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetBindingType",
			Type = "Function",

			Arguments =
			{
				{ Name = "button", Type = "cstring", Nilable = false },
				{ Name = "modifiers", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "type", Type = "ClickBindingType", Nilable = false },
			},
		},
		{
			Name = "GetEffectiveInteractionButton",
			Type = "Function",

			Arguments =
			{
				{ Name = "button", Type = "cstring", Nilable = false },
				{ Name = "modifiers", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "effectiveButton", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetProfileInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "infoVec", Type = "table", InnerType = "ClickBindingInfo", Nilable = false },
			},
		},
		{
			Name = "GetStringFromModifiers",
			Type = "Function",

			Arguments =
			{
				{ Name = "modifiers", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "modifierString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTutorialShown",
			Type = "Function",

			Returns =
			{
				{ Name = "tutorialShown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MakeModifiers",
			Type = "Function",

			Returns =
			{
				{ Name = "modifiers", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResetCurrentProfile",
			Type = "Function",
		},
		{
			Name = "SetProfileByInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "infoVec", Type = "table", InnerType = "ClickBindingInfo", Nilable = false },
			},
		},
		{
			Name = "SetTutorialShown",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ClickbindingsSetHighlightsShown",
			Type = "Event",
			LiteralName = "CLICKBINDINGS_SET_HIGHLIGHTS_SHOWN",
			Payload =
			{
				{ Name = "showHighlights", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ClickBindings);