local HousingLayoutPinFrameAPI =
{
	Name = "HousingLayoutPinFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CanMove",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "moveRestriction", Type = "HousingLayoutRestriction", Nilable = false },
			},
		},
		{
			Name = "CanRemove",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "removalRestriction", Type = "HousingLayoutRestriction", Nilable = false },
			},
		},
		{
			Name = "CanRotate",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rotateRestriction", Type = "HousingLayoutRestriction", Nilable = false },
			},
		},
		{
			Name = "Drag",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isAccessible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDoorConnectionInfo",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "connectionInfo", Type = "DoorConnectionInfo", Nilable = true },
			},
		},
		{
			Name = "GetPinType",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "type", Type = "HousingLayoutPinType", Nilable = false },
			},
		},
		{
			Name = "GetRoomGUID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetRoomName",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "IsAnyPartOfRoomSelected",
			Type = "Function",
			Documentation = { "Returns true if this pin's associated room, or anything attached to it, is selected. Ex: If pin is for a door, returns true if its room, or any other doors on that room, are selected" },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isSelected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsOccupiedDoor",
			Type = "Function",
			Documentation = { "Will be nil if pin is not a Door" },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isOccupied", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsSelected",
			Type = "Function",
			Documentation = { "Returns true if this pin's object is itself selected; See IsAnyPartOfRoomSelected for a broader Selected check" },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isSelected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValid",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidForSelectedFloorplan",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Select",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetUpdateCallback",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "PinUpdatedCallback", Nilable = false },
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

APIDocumentation:AddDocumentationTable(HousingLayoutPinFrameAPI);