local HousingLayoutUI =
{
	Name = "HousingLayoutUI",
	Type = "System",
	Namespace = "C_HousingLayout",

	Functions =
	{
		{
			Name = "AnyRoomsOnFloor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "floor", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "anyRooms", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CancelActiveLayoutEditing",
			Type = "Function",
		},
		{
			Name = "CreateNewRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomRecordID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DeselectFloorplan",
			Type = "Function",
		},
		{
			Name = "DeselectRoomOrDoor",
			Type = "Function",
		},
		{
			Name = "GetNumActiveRooms",
			Type = "Function",

			Returns =
			{
				{ Name = "numRooms", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRoomOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "roomOptions", Type = "table", InnerType = "RoomOptionInfo", Nilable = false },
			},
		},
		{
			Name = "GetRoomPlacementBudget",
			Type = "Function",

			Returns =
			{
				{ Name = "placementBudget", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedFloorplan",
			Type = "Function",

			Returns =
			{
				{ Name = "roomID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetViewedFloor",
			Type = "Function",

			Returns =
			{
				{ Name = "floor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasAnySelections",
			Type = "Function",
			Documentation = { "Returns true if any room, door, or floorplan is currently selected or being dragged" },

			Returns =
			{
				{ Name = "hasAnySelections", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSelectedDoor",
			Type = "Function",

			Returns =
			{
				{ Name = "hasSelectedDoor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSelectedFloorplan",
			Type = "Function",

			Returns =
			{
				{ Name = "hasSelectedFloorplan", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasSelectedRoom",
			Type = "Function",

			Returns =
			{
				{ Name = "hasSelectedRoom", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasValidConnection",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "roomId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canPlace", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBaseRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBaseRoom", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDraggingRoom",
			Type = "Function",

			Returns =
			{
				{ Name = "isDragging", Type = "bool", Nilable = false },
				{ Name = "isAccessibleDrag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MoveDraggedRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "sourceDoorIndex", Type = "number", Nilable = false },
				{ Name = "destRoom", Type = "WOWGUID", Nilable = false },
				{ Name = "destDoorIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MoveLayoutCamera",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "direction", Type = "HousingLayoutCameraDirection", Nilable = false },
				{ Name = "isPressed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RotateDraggedRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isLeft", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RotateFocusedRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Rotates either the currently dragged or currently selected room, if either exist" },

			Arguments =
			{
				{ Name = "isLeft", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RotateRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "isLeft", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SelectFloorplan",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetViewedFloor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "floor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StartDrag",
			Type = "Function",
		},
		{
			Name = "StopDrag",
			Type = "Function",
		},
		{
			Name = "StopDraggingRoom",
			Type = "Function",
		},
		{
			Name = "ZoomLayoutCamera",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "zoomIn", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingLayoutDoorSelected",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_DOOR_SELECTED",
			Payload =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutDoorSelectionChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_DOOR_SELECTION_CHANGED",
			Payload =
			{
				{ Name = "hasSelection", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutDragTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_DRAG_TARGET_CHANGED",
			Payload =
			{
				{ Name = "isDraggingRoom", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutFloorplanSelectionChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED",
			Payload =
			{
				{ Name = "hasSelection", Type = "bool", Nilable = false },
				{ Name = "roomID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutNumFloorsChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_NUM_FLOORS_CHANGED",
			Payload =
			{
				{ Name = "prevNumFloors", Type = "number", Nilable = false },
				{ Name = "numFloors", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutPinFrameAdded",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_PIN_FRAME_ADDED",
			Payload =
			{
				{ Name = "pinFrame", Type = "HousingLayoutPinFrame", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutPinFrameReleased",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_PIN_FRAME_RELEASED",
			Payload =
			{
				{ Name = "pinFrame", Type = "HousingLayoutPinFrame", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutPinFramesReleased",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_PIN_FRAMES_RELEASED",
		},
		{
			Name = "HousingLayoutRoomComponentThemeSetChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_COMPONENT_THEME_SET_CHANGED",
			Payload =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "newThemeSet", Type = "number", Nilable = false },
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutRoomMoveInvalid",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_MOVE_INVALID",
		},
		{
			Name = "HousingLayoutRoomMoved",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_MOVED",
		},
		{
			Name = "HousingLayoutRoomReceived",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_RECEIVED",
			Payload =
			{
				{ Name = "prevNumFloors", Type = "number", Nilable = false },
				{ Name = "currNumFloors", Type = "number", Nilable = false },
				{ Name = "isUpstairs", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutRoomRemoved",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_REMOVED",
		},
		{
			Name = "HousingLayoutRoomReturned",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_RETURNED",
		},
		{
			Name = "HousingLayoutRoomSelectionChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_SELECTION_CHANGED",
			Payload =
			{
				{ Name = "hasSelection", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutRoomSnapped",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_SNAPPED",
		},
		{
			Name = "HousingLayoutViewedFloorChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_VIEWED_FLOOR_CHANGED",
			Payload =
			{
				{ Name = "floor", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingLayoutUI);