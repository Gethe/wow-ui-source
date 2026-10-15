local GamepadUI =
{
	Name = "GamepadUI",
	Type = "System",
	Namespace = "C_GamepadUI",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFirstGamepadActionBarStorageSlotIndexForActiveStance",
			Type = "Function",

			Returns =
			{
				{ Name = "activeStanceFirstGamepadStorageSlotIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "GetFirstGamepadActionStorageSlotIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "firstGamepadActionStorageSlotIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetFirstGamepadPetActionStorageSlotIndex",
			Type = "Function",

			Returns =
			{
				{ Name = "firstGamepadPetActionStorageSlotID", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "IsValidGamepadActionStorageSlotIndex",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gamepadActionStorageSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidGamepadPossessBarStorageSlotIndex",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gamepadPossessBarStorageSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "GamepadPossessBarOverrideChanged",
			Type = "Event",
			LiteralName = "GAMEPAD_POSSESS_BAR_OVERRIDE_CHANGED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "oldOverride", Type = "GamepadPossessBarOverride", Nilable = false },
				{ Name = "newOverride", Type = "GamepadPossessBarOverride", Nilable = false },
			},
		},
		{
			Name = "GamepadStanceBarOverrideChanged",
			Type = "Event",
			LiteralName = "GAMEPAD_STANCE_BAR_OVERRIDE_CHANGED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "oldOverride", Type = "GamepadStanceBarOverride", Nilable = false },
				{ Name = "newOverride", Type = "GamepadStanceBarOverride", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "GamepadPossessBarOverride",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 1,
			MaxValue = 12,
			Fields =
			{
				{ Name = "SpecialPageTopBar", Type = "GamepadPossessBarOverride", EnumValue = 1 },
				{ Name = "Page1LeftBar", Type = "GamepadPossessBarOverride", EnumValue = 2 },
				{ Name = "Page1RightBar", Type = "GamepadPossessBarOverride", EnumValue = 3 },
				{ Name = "Page1BottomBar", Type = "GamepadPossessBarOverride", EnumValue = 4 },
				{ Name = "Page2TopBar", Type = "GamepadPossessBarOverride", EnumValue = 5 },
				{ Name = "Page2LeftBar", Type = "GamepadPossessBarOverride", EnumValue = 6 },
				{ Name = "Page2RightBar", Type = "GamepadPossessBarOverride", EnumValue = 7 },
				{ Name = "Page2BottomBar", Type = "GamepadPossessBarOverride", EnumValue = 8 },
				{ Name = "Page3TopBar", Type = "GamepadPossessBarOverride", EnumValue = 9 },
				{ Name = "Page3LeftBar", Type = "GamepadPossessBarOverride", EnumValue = 10 },
				{ Name = "Page3RightBar", Type = "GamepadPossessBarOverride", EnumValue = 11 },
				{ Name = "Page3BottomBar", Type = "GamepadPossessBarOverride", EnumValue = 12 },
			},
		},
		{
			Name = "GamepadStanceBarOverride",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 1,
			MaxValue = 12,
			Fields =
			{
				{ Name = "None", Type = "GamepadStanceBarOverride", EnumValue = 1 },
				{ Name = "Page1LeftBar", Type = "GamepadStanceBarOverride", EnumValue = 2 },
				{ Name = "Page1RightBar", Type = "GamepadStanceBarOverride", EnumValue = 3 },
				{ Name = "Page1BottomBar", Type = "GamepadStanceBarOverride", EnumValue = 4 },
				{ Name = "Page2TopBar", Type = "GamepadStanceBarOverride", EnumValue = 5 },
				{ Name = "Page2LeftBar", Type = "GamepadStanceBarOverride", EnumValue = 6 },
				{ Name = "Page2RightBar", Type = "GamepadStanceBarOverride", EnumValue = 7 },
				{ Name = "Page2BottomBar", Type = "GamepadStanceBarOverride", EnumValue = 8 },
				{ Name = "Page3TopBar", Type = "GamepadStanceBarOverride", EnumValue = 9 },
				{ Name = "Page3LeftBar", Type = "GamepadStanceBarOverride", EnumValue = 10 },
				{ Name = "Page3RightBar", Type = "GamepadStanceBarOverride", EnumValue = 11 },
				{ Name = "Page3BottomBar", Type = "GamepadStanceBarOverride", EnumValue = 12 },
			},
		},
		{
			Name = "GamepadActionBarConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP", Type = "number", Value = 4 },
				{ Name = "NUM_GROUPS_PER_GAMEPAD_ACTION_BAR", Type = "number", Value = 2 },
				{ Name = "NUM_SLOTS_PER_GAMEPAD_ACTION_BAR", Type = "number", Value = Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR_GROUP * Constants.GamepadActionBarConstants.NUM_GROUPS_PER_GAMEPAD_ACTION_BAR },
				{ Name = "NUM_PAGEABLE_BARS_IN_GAMEPAD_ACTION_BAR_PAGE_UNIT", Type = "number", Value = 4 },
				{ Name = "NUM_PAGEABLE_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT_STANDARD_PAGE", Type = "number", Value = Constants.GamepadActionBarConstants.NUM_PAGEABLE_BARS_IN_GAMEPAD_ACTION_BAR_PAGE_UNIT * Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR },
				{ Name = "NUM_RESERVED_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT", Type = "number", Value = 4 },
				{ Name = "NUM_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT", Type = "number", Value = 4 },
				{ Name = "NUM_STANDARD_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT", Type = "number", Value = 3 },
				{ Name = "GAMEPAD_ACTION_BAR_PAGE_UNIT_SPECIAL_PAGE_INDEX", Type = "number", Value = 4 },
				{ Name = "NUM_PAGEABLE_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT", Type = "number", Value = Constants.GamepadActionBarConstants.NUM_PAGEABLE_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT_STANDARD_PAGE * Constants.GamepadActionBarConstants.NUM_STANDARD_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT },
				{ Name = "NUM_GAMEPAD_STANCE_ACTION_BARS", Type = "number", Value = 5 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(GamepadUI);