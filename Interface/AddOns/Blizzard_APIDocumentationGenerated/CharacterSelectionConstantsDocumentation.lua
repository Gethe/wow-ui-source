local CharacterSelectionConstants =
{
	Tables =
	{
		{
			Name = "WarbandSceneAnimationEvent",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Idle", Type = "WarbandSceneAnimationEvent", EnumValue = 0 },
				{ Name = "Mouseover", Type = "WarbandSceneAnimationEvent", EnumValue = 1 },
				{ Name = "Select", Type = "WarbandSceneAnimationEvent", EnumValue = 2 },
				{ Name = "Deselect", Type = "WarbandSceneAnimationEvent", EnumValue = 3 },
				{ Name = "Insert", Type = "WarbandSceneAnimationEvent", EnumValue = 4 },
				{ Name = "EnterWorld", Type = "WarbandSceneAnimationEvent", EnumValue = 5 },
				{ Name = "Spin", Type = "WarbandSceneAnimationEvent", EnumValue = 6 },
				{ Name = "Poke", Type = "WarbandSceneAnimationEvent", EnumValue = 7 },
			},
		},
		{
			Name = "WarbandSceneSlotType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Character", Type = "WarbandSceneSlotType", EnumValue = 0 },
				{ Name = "Pet", Type = "WarbandSceneSlotType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CharacterSelectionConstants);