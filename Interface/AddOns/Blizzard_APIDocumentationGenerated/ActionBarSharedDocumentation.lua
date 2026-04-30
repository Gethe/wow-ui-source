local ActionBarShared =
{
	Tables =
	{
		{
			Name = "ActionUsableState",
			Type = "Structure",
			Fields =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
				{ Name = "usable", Type = "bool", Nilable = false },
				{ Name = "noMana", Type = "bool", Nilable = false },
			},
		},
	},
	Predicates =
	{
		{
			Name = "RequiresValidActionSlot",
			Type = "Precondition",
			FailureMode = "ReturnNothing",
		},
	},
};

APIDocumentation:AddDocumentationTable(ActionBarShared);