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
			Name = "ConfirmStairChoice",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "choice", Type = "HousingLayoutStairDirection", Nilable = true, Documentation = { "If not set, the pending stair operation will be cancelled" } },
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
			Documentation = { "Returns the max room placement budget for the current house interior; Can be increased via house level" },

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
			Documentation = { "Returns how much of the current house's room placement budget has been spent; Different kinds of rooms take up different budget amounts, so this value isn't an individual room count, see GetNumActiveRooms for that" },

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
			Name = "HasRoomPlacementBudget",
			Type = "Function",
			Documentation = { "Returns whether there's a max room placement budget available and active for the current player, in the current house interior" },

			Returns =
			{
				{ Name = "hasBudget", Type = "bool", Nilable = false },
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
			SecretArguments = "AllowedWhenUntainted",

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
			Documentation = { "Attempt to move the room currently being dragged to a specific connection point on a specific other room" },

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
			Documentation = { "Attempt to return a previously placed room to the House Chest" },

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
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
			Documentation = { "Attempt to rotate an already placed room" },

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

			Returns =
			{
				{ Name = "zoomChanged", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingLayoutDoorSelected",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_DOOR_SELECTED",
			SynchronousEvent = true,
			Documentation = { "Fired when one of the door nodes of an already placed room has been selected" },
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
			SynchronousEvent = true,
			Documentation = { "Fired when one of the door nodes of an already placed room has been selected or deselected" },
			Payload =
			{
				{ Name = "hasSelection", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutDragTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_DRAG_TARGET_CHANGED",
			SynchronousEvent = true,
			Documentation = { "Fired when an already placed room has either started or stopped being dragged" },
			Payload =
			{
				{ Name = "isDraggingRoom", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutFloorplanSelectionChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_FLOORPLAN_SELECTION_CHANGED",
			SynchronousEvent = true,
			Documentation = { "Fired when a room option in the House Chest has been selected or deselected" },
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "pinFrame", Type = "HousingLayoutPinFrame", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutPinFrameReleased",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_PIN_FRAME_RELEASED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "pinFrame", Type = "HousingLayoutPinFrame", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutPinFramesReleased",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_PIN_FRAMES_RELEASED",
			SynchronousEvent = true,
		},
		{
			Name = "HousingLayoutRoomComponentThemeSetChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_COMPONENT_THEME_SET_CHANGED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "HousingLayoutRoomMoved",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_MOVED",
			SynchronousEvent = true,
			Documentation = { "Fired when a previously placed room has been moved to a different position or rotation" },
		},
		{
			Name = "HousingLayoutRoomReceived",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_RECEIVED",
			SynchronousEvent = true,
			Documentation = { "Fired when info for a newly placed room has been recieved while in Layout Mode" },
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
			SynchronousEvent = true,
			Documentation = { "Fired when a previously placed room has been removed while in Layout Mode" },
		},
		{
			Name = "HousingLayoutRoomReturned",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_RETURNED",
			SynchronousEvent = true,
			Documentation = { "Fired when a room that was being dragged is let go of without being placed, and is returned to the House Chest" },
		},
		{
			Name = "HousingLayoutRoomSelectionChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_SELECTION_CHANGED",
			SynchronousEvent = true,
			Documentation = { "Fired when an already placed room has been selected or deselected" },
			Payload =
			{
				{ Name = "hasSelection", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingLayoutRoomSnapped",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_ROOM_SNAPPED",
			SynchronousEvent = true,
			Documentation = { "Fired when a room being dragged has been snapped to a particular door connection" },
		},
		{
			Name = "HousingLayoutViewedFloorChanged",
			Type = "Event",
			LiteralName = "HOUSING_LAYOUT_VIEWED_FLOOR_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "floor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShowStairDirectionConfirmation",
			Type = "Event",
			LiteralName = "SHOW_STAIR_DIRECTION_CONFIRMATION",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingLayoutUI);