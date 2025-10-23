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
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false, Documentation = { "Base spellID for spell, spellID for PetAction" } },
			},

			Returns =
			{
				{ Name = "canBeBound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ExecuteBinding",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			HasRestrictions = true,
		},
		{
			Name = "SetProfileByInfo",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SynchronousEvent = true,
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