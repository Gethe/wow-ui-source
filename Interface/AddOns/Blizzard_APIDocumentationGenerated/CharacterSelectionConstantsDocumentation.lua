local CharacterSelectionConstants =
{
	Tables =
	{
		{
			Name = "WarbandEventState",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "None", Type = "WarbandEventState", EnumValue = 0 },
				{ Name = "DelayingEvent", Type = "WarbandEventState", EnumValue = 1 },
				{ Name = "SheathingWeapon", Type = "WarbandEventState", EnumValue = 2 },
				{ Name = "DelayingStandStateTransition", Type = "WarbandEventState", EnumValue = 3 },
				{ Name = "StandStateTransitioning", Type = "WarbandEventState", EnumValue = 4 },
				{ Name = "ShowingWeapon", Type = "WarbandEventState", EnumValue = 5 },
				{ Name = "StandStateLooping", Type = "WarbandEventState", EnumValue = 6 },
				{ Name = "NumWarbandEventStates", Type = "WarbandEventState", EnumValue = 7 },
			},
		},
		{
			Name = "WarbandGroupFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "WarbandGroupFlags", EnumValue = 0 },
				{ Name = "Collapsed", Type = "WarbandGroupFlags", EnumValue = 1 },
			},
		},
		{
			Name = "WarbandPlacementDisplayInfoType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Model", Type = "WarbandPlacementDisplayInfoType", EnumValue = 0 },
				{ Name = "Creature", Type = "WarbandPlacementDisplayInfoType", EnumValue = 1 },
				{ Name = "Item", Type = "WarbandPlacementDisplayInfoType", EnumValue = 2 },
			},
		},
		{
			Name = "WarbandSceneAnimationEvent",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
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
				{ Name = "Ffx", Type = "WarbandSceneAnimationEvent", EnumValue = 9 },
			},
		},
		{
			Name = "WarbandSceneAnimationSheatheState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Maintain", Type = "WarbandSceneAnimationSheatheState", EnumValue = 0 },
				{ Name = "SheatheWeapons", Type = "WarbandSceneAnimationSheatheState", EnumValue = 1 },
				{ Name = "ShowWeapons", Type = "WarbandSceneAnimationSheatheState", EnumValue = 2 },
			},
		},
		{
			Name = "WarbandSceneAnimationStandState",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Maintain", Type = "WarbandSceneAnimationStandState", EnumValue = 0 },
				{ Name = "Stand", Type = "WarbandSceneAnimationStandState", EnumValue = 1 },
				{ Name = "SitOnGround", Type = "WarbandSceneAnimationStandState", EnumValue = 2 },
				{ Name = "Kneel", Type = "WarbandSceneAnimationStandState", EnumValue = 3 },
				{ Name = "ReadyStance", Type = "WarbandSceneAnimationStandState", EnumValue = 4 },
				{ Name = "SitOnChairLow", Type = "WarbandSceneAnimationStandState", EnumValue = 5 },
				{ Name = "SitOnChairMedium", Type = "WarbandSceneAnimationStandState", EnumValue = 6 },
				{ Name = "SitOnChairHigh", Type = "WarbandSceneAnimationStandState", EnumValue = 7 },
				{ Name = "Sleep", Type = "WarbandSceneAnimationStandState", EnumValue = 8 },
			},
		},
		{
			Name = "WarbandSceneAnimationStandStateFlags",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 256,
			Fields =
			{
				{ Name = "Maintain", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 1 },
				{ Name = "Stand", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 2 },
				{ Name = "SitOnGround", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 4 },
				{ Name = "Kneel", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 8 },
				{ Name = "ReadyStance", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 16 },
				{ Name = "SitOnChairLow", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 32 },
				{ Name = "SitOnChairMedium", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 64 },
				{ Name = "SitOnChairHigh", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 128 },
				{ Name = "Sleep", Type = "WarbandSceneAnimationStandStateFlags", EnumValue = 256 },
			},
		},
		{
			Name = "WarbandScenePlacementType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Character", Type = "WarbandScenePlacementType", EnumValue = 0 },
				{ Name = "Pet", Type = "WarbandScenePlacementType", EnumValue = 1 },
				{ Name = "Chair", Type = "WarbandScenePlacementType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CharacterSelectionConstants);