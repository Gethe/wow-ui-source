local ActionBarFrameLua =
{
	Name = "ActionBar",
	Type = "System",
	Namespace = "C_ActionBar",

	Functions =
	{
		{
			Name = "FindFlyoutActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "FindPetActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "FindSpellActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetPetActionPetBarIndices",
			Type = "Function",

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "HasFlyoutActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "flyoutID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasFlyoutActionButtons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPetActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasPetActionButtons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPetActionPetBarIndices",
			Type = "Function",

			Arguments =
			{
				{ Name = "petActionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasPetActionPetBarIndices", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSpellActionButtons",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSpellActionButtons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAutoCastPetAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAutoCastPetAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabledAutoCastPetAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isEnabledAutoCastPetAction", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOnBarOrSpecialBar",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isOnBarOrSpecialBar", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleAutoCastPetAction",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(ActionBarFrameLua);