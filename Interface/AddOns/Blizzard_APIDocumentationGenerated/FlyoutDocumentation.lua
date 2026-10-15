local Flyout =
{
	Name = "Flyout",
	Type = "System",
	Namespace = "C_Flyout",
	Environment = "All",

	Functions =
	{
		{
			Name = "FlyoutHasSpell",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSpell", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetFlyoutID",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFlyoutInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "FlyoutInfo", Nilable = false },
			},
		},
		{
			Name = "GetFlyoutSlotInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotInfo", Type = "FlyoutSlotInfo", Nilable = false },
			},
		},
		{
			Name = "GetFlyoutTexture",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "textureID", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetNumFlyouts",
			Type = "Function",

			Returns =
			{
				{ Name = "numFlyouts", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "FlyoutInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "numSlots", Type = "number", Nilable = false },
				{ Name = "isKnown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FlyoutSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "overrideSpellID", Type = "number", Nilable = false },
				{ Name = "isKnown", Type = "bool", Nilable = false },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "specID", Type = "number", Nilable = true },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(Flyout);