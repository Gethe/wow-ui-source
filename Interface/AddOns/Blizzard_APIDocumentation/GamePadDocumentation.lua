local GamePad =
{
	Name = "GamePad",
	Type = "System",
	Namespace = "C_GamePad",

	Functions =
	{
		{
			Name = "ApplyConfigs",
			Type = "Function",
		},
		{
			Name = "AxisIndexToConfigName",
			Type = "Function",

			Arguments =
			{
				{ Name = "axisIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ButtonBindingToIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "bindingName", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "buttonIndex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ButtonIndexToBinding",
			Type = "Function",

			Arguments =
			{
				{ Name = "buttonIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "bindingName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ButtonIndexToConfigName",
			Type = "Function",

			Arguments =
			{
				{ Name = "buttonIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "DeleteConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "GamePadConfigID", Nilable = false },
			},
		},
		{
			Name = "GetActiveDeviceID",
			Type = "Function",

			Returns =
			{
				{ Name = "deviceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAllConfigIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "configIDs", Type = "table", InnerType = "GamePadConfigID", Nilable = false },
			},
		},
		{
			Name = "GetAllDeviceIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "deviceIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCombinedDeviceID",
			Type = "Function",

			Returns =
			{
				{ Name = "deviceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "GamePadConfigID", Nilable = false },
			},

			Returns =
			{
				{ Name = "config", Type = "GamePadConfig", Nilable = true },
			},
		},
		{
			Name = "GetDeviceMappedState",
			Type = "Function",

			Arguments =
			{
				{ Name = "deviceID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "state", Type = "GamePadMappedState", Nilable = true },
			},
		},
		{
			Name = "GetDeviceRawState",
			Type = "Function",

			Arguments =
			{
				{ Name = "deviceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rawState", Type = "GamePadRawState", Nilable = true },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "config", Type = "GamePadConfig", Nilable = false },
			},
		},
		{
			Name = "StickIndexToConfigName",
			Type = "Function",

			Arguments =
			{
				{ Name = "stickIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configName", Type = "string", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "GamePadConfigsChanged",
			Type = "Event",
			LiteralName = "GAME_PAD_CONFIGS_CHANGED",
		},
		{
			Name = "GamePadConnected",
			Type = "Event",
			LiteralName = "GAME_PAD_CONNECTED",
		},
		{
			Name = "GamePadDisconnected",
			Type = "Event",
			LiteralName = "GAME_PAD_DISCONNECTED",
		},
	},

	Tables =
	{
		{
			Name = "GamePadAxisConfig",
			Type = "Structure",
			Fields =
			{
				{ Name = "axis", Type = "string", Nilable = false },
				{ Name = "shift", Type = "number", Nilable = true },
				{ Name = "scale", Type = "number", Nilable = true },
				{ Name = "deadzone", Type = "number", Nilable = true },
				{ Name = "buttonThreshold", Type = "number", Nilable = true },
				{ Name = "buttonPos", Type = "string", Nilable = true },
				{ Name = "buttonNeg", Type = "string", Nilable = true },
				{ Name = "comment", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GamePadConfig",
			Type = "Structure",
			Fields =
			{
				{ Name = "comment", Type = "string", Nilable = true },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "configID", Type = "GamePadConfigID", Nilable = false },
				{ Name = "labelStyle", Type = "string", Nilable = true },
				{ Name = "rawButtonMappings", Type = "table", InnerType = "GamePadRawButtonMapping", Nilable = false },
				{ Name = "rawAxisMappings", Type = "table", InnerType = "GamePadRawAxisMapping", Nilable = false },
				{ Name = "axisConfigs", Type = "table", InnerType = "GamePadAxisConfig", Nilable = false },
				{ Name = "stickConfigs", Type = "table", InnerType = "GamePadStickConfig", Nilable = false },
			},
		},
		{
			Name = "GamePadConfigID",
			Type = "Structure",
			Fields =
			{
				{ Name = "vendorID", Type = "number", Nilable = true },
				{ Name = "productID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GamePadMappedState",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "labelStyle", Type = "string", Nilable = false },
				{ Name = "buttonCount", Type = "number", Nilable = false },
				{ Name = "axisCount", Type = "number", Nilable = false },
				{ Name = "stickCount", Type = "number", Nilable = false },
				{ Name = "buttons", Type = "table", InnerType = "bool", Nilable = false },
				{ Name = "axes", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "sticks", Type = "table", InnerType = "GamePadStick", Nilable = false },
			},
		},
		{
			Name = "GamePadRawAxisMapping",
			Type = "Structure",
			Fields =
			{
				{ Name = "rawIndex", Type = "number", Nilable = false },
				{ Name = "axis", Type = "string", Nilable = true },
				{ Name = "comment", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GamePadRawButtonMapping",
			Type = "Structure",
			Fields =
			{
				{ Name = "rawIndex", Type = "number", Nilable = false },
				{ Name = "button", Type = "string", Nilable = true },
				{ Name = "axis", Type = "string", Nilable = true },
				{ Name = "axisValue", Type = "number", Nilable = true },
				{ Name = "comment", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GamePadRawState",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "vendorID", Type = "number", Nilable = false },
				{ Name = "productID", Type = "number", Nilable = false },
				{ Name = "rawButtonCount", Type = "number", Nilable = false },
				{ Name = "rawAxisCount", Type = "number", Nilable = false },
				{ Name = "rawButtons", Type = "table", InnerType = "bool", Nilable = false },
				{ Name = "rawAxes", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GamePadStick",
			Type = "Structure",
			Fields =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "len", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GamePadStickConfig",
			Type = "Structure",
			Fields =
			{
				{ Name = "stick", Type = "string", Nilable = false },
				{ Name = "axisX", Type = "string", Nilable = true },
				{ Name = "axisY", Type = "string", Nilable = true },
				{ Name = "deadzone", Type = "number", Nilable = true },
				{ Name = "comment", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GamePad);