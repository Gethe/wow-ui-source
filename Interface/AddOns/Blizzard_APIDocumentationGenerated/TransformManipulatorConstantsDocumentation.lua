local TransformManipulatorConstants =
{
	Tables =
	{
		{
			Name = "TransformManipulatorAxis",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "X", Type = "TransformManipulatorAxis", EnumValue = 1 },
				{ Name = "Y", Type = "TransformManipulatorAxis", EnumValue = 2 },
				{ Name = "Z", Type = "TransformManipulatorAxis", EnumValue = 4 },
			},
		},
		{
			Name = "TransformManipulatorControlState",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Default", Type = "TransformManipulatorControlState", EnumValue = 0 },
				{ Name = "Hidden", Type = "TransformManipulatorControlState", EnumValue = 1 },
				{ Name = "Dimmed", Type = "TransformManipulatorControlState", EnumValue = 2 },
				{ Name = "ExternallyHighlighted", Type = "TransformManipulatorControlState", EnumValue = 3 },
				{ Name = "Hovered", Type = "TransformManipulatorControlState", EnumValue = 4 },
				{ Name = "Selected", Type = "TransformManipulatorControlState", EnumValue = 5 },
				{ Name = "Moving", Type = "TransformManipulatorControlState", EnumValue = 6 },
			},
		},
		{
			Name = "TransformManipulatorDirection",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Positive", Type = "TransformManipulatorDirection", EnumValue = 0 },
				{ Name = "Negative", Type = "TransformManipulatorDirection", EnumValue = 1 },
			},
		},
		{
			Name = "TransformManipulatorEvent",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Start", Type = "TransformManipulatorEvent", EnumValue = 0 },
				{ Name = "Change", Type = "TransformManipulatorEvent", EnumValue = 1 },
				{ Name = "Complete", Type = "TransformManipulatorEvent", EnumValue = 2 },
				{ Name = "Cancel", Type = "TransformManipulatorEvent", EnumValue = 3 },
				{ Name = "Hover", Type = "TransformManipulatorEvent", EnumValue = 4 },
				{ Name = "MouseDown", Type = "TransformManipulatorEvent", EnumValue = 5 },
				{ Name = "MouseUp", Type = "TransformManipulatorEvent", EnumValue = 6 },
			},
		},
		{
			Name = "TransformManipulatorMode",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Translate", Type = "TransformManipulatorMode", EnumValue = 0 },
				{ Name = "Rotate", Type = "TransformManipulatorMode", EnumValue = 1 },
				{ Name = "Scale", Type = "TransformManipulatorMode", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransformManipulatorConstants);