local HousingLayoutUITypes =
{
	Tables =
	{
		{
			Name = "HousingLayoutCameraDirection",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "None", Type = "HousingLayoutCameraDirection", EnumValue = 0 },
				{ Name = "Up", Type = "HousingLayoutCameraDirection", EnumValue = 1 },
				{ Name = "Down", Type = "HousingLayoutCameraDirection", EnumValue = 2 },
				{ Name = "Left", Type = "HousingLayoutCameraDirection", EnumValue = 4 },
				{ Name = "Right", Type = "HousingLayoutCameraDirection", EnumValue = 8 },
			},
		},
		{
			Name = "HousingLayoutPinType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Door", Type = "HousingLayoutPinType", EnumValue = 0 },
				{ Name = "Room", Type = "HousingLayoutPinType", EnumValue = 1 },
			},
		},
		{
			Name = "HousingLayoutStairDirection",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Up", Type = "HousingLayoutStairDirection", EnumValue = 0 },
				{ Name = "Down", Type = "HousingLayoutStairDirection", EnumValue = 1 },
			},
		},
		{
			Name = "DoorConnectionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "doorID", Type = "number", Nilable = false },
				{ Name = "connectionType", Type = "HousingRoomComponentType", Nilable = false },
			},
		},
		{
			Name = "RoomOptionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "roomName", Type = "cstring", Nilable = false },
				{ Name = "roomID", Type = "number", Nilable = false },
				{ Name = "learned", Type = "bool", Nilable = false },
				{ Name = "numOwned", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PinUpdatedCallback",
			Type = "CallbackType",
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingLayoutUITypes);