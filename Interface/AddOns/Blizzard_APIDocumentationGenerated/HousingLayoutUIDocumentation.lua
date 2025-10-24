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
			Name = "ConfirmStairChoice",
			Type = "Function",

			Arguments =
			{
				{ Name = "choice", Type = "HousingLayoutStairDirection", Nilable = true },
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
			Name = "GetRoomPlacementBudget",
			Type = "Function",

			Returns =
			{
				{ Name = "placementBudget", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedDoor",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "If a door is selected, returns its component id and the guid of the room it belongs to; Otherwise returns nothing" },

			Returns =
			{
				{ Name = "selectedDoorComponentID", Type = "number", Nilable = false },
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
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
			Name = "GetSelectedRoom",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "If a Room is selected, returns the room's guid; Otherwise returns nothing" },

			Returns =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetSelectedStairwellRoomCount",
			Type = "Function",

			Returns =
			{
				{ Name = "stairwellRoomCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSpentPlacementBudget",
			Type = "Function",

			Returns =
			{
				{ Name = "spentPlacementBudget", Type = "number", Nilable = false },
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
			Documentation = { "Returns true if a door component is currently selected" },

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
			Documentation = { "Returns true if a room is selected, will NOT return true if a door is selected" },

			Returns =
			{
				{ Name = "hasSelectedRoom", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasStairs",
			Type = "Function",

			Arguments =
			{
				{ Name = "roomRecordID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasStairs", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasValidConnection",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "direction", Type = "HousingLayoutCameraDirection", Nilable = false },
				{ Name = "isPressed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveRoom",
			Type = "Function",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RotateFocusedRoom",
			Type = "Function",
			Documentation = { "Rotates either the currently dragged or currently selected room, if either exist" },

			Arguments =
			{
				{ Name = "isLeft", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RotateRoom",
			Type = "Function",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "isLeft", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SelectFloorplan",
			Type = "Function",

			Arguments =
			{
				{ Name = "roomID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetViewedFloor",
			Type = "Function",

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
		{
			Name = "ShowStairDirectionConfirmation",
			Type = "Event",
			LiteralName = "SHOW_STAIR_DIRECTION_CONFIRMATION",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingLayoutUI);