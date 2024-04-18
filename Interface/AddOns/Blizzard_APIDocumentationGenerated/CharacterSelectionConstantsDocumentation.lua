local CharacterSelectionConstants =
{
	Tables =
	{
		{
			Name = "WarbandSceneAnimationEvent",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "StartingPose", Type = "WarbandSceneAnimationEvent", EnumValue = 0 },
				{ Name = "Idle", Type = "WarbandSceneAnimationEvent", EnumValue = 1 },
				{ Name = "Mouseover", Type = "WarbandSceneAnimationEvent", EnumValue = 2 },
				{ Name = "Select", Type = "WarbandSceneAnimationEvent", EnumValue = 3 },
				{ Name = "Deselect", Type = "WarbandSceneAnimationEvent", EnumValue = 4 },
				{ Name = "Insert", Type = "WarbandSceneAnimationEvent", EnumValue = 5 },
				{ Name = "EnterWorld", Type = "WarbandSceneAnimationEvent", EnumValue = 6 },
				{ Name = "Spin", Type = "WarbandSceneAnimationEvent", EnumValue = 7 },
				{ Name = "Poke", Type = "WarbandSceneAnimationEvent", EnumValue = 8 },
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