local System =
{
	Name = "SystemInfo",
	Type = "System",
	Namespace = "C_System",

	Functions =
	{
		{
			Name = "GetFrameStack",
			Type = "Function",

			Returns =
			{
				{ Name = "objects", Type = "table", InnerType = "ScriptRegion", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CaptureframesFailed",
			Type = "Event",
			LiteralName = "CAPTUREFRAMES_FAILED",
		},
		{
			Name = "CaptureframesSucceeded",
			Type = "Event",
			LiteralName = "CAPTUREFRAMES_SUCCEEDED",
		},
		{
			Name = "DisableTaxiBenchmark",
			Type = "Event",
			LiteralName = "DISABLE_TAXI_BENCHMARK",
		},
		{
			Name = "EnableTaxiBenchmark",
			Type = "Event",
			LiteralName = "ENABLE_TAXI_BENCHMARK",
		},
		{
			Name = "FirstFrameRendered",
			Type = "Event",
			LiteralName = "FIRST_FRAME_RENDERED",
		},
		{
			Name = "GenericError",
			Type = "Event",
			LiteralName = "GENERIC_ERROR",
			Payload =
			{
				{ Name = "errorMessage", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GlobalMouseDown",
			Type = "Event",
			LiteralName = "GLOBAL_MOUSE_DOWN",
			Payload =
			{
				{ Name = "button", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GlobalMouseUp",
			Type = "Event",
			LiteralName = "GLOBAL_MOUSE_UP",
			Payload =
			{
				{ Name = "button", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "InitialHotfixesApplied",
			Type = "Event",
			LiteralName = "INITIAL_HOTFIXES_APPLIED",
		},
		{
			Name = "LocResult",
			Type = "Event",
			LiteralName = "LOC_RESULT",
			Payload =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogoutCancel",
			Type = "Event",
			LiteralName = "LOGOUT_CANCEL",
		},
		{
			Name = "PlayerCamping",
			Type = "Event",
			LiteralName = "PLAYER_CAMPING",
		},
		{
			Name = "PlayerEnteringWorld",
			Type = "Event",
			LiteralName = "PLAYER_ENTERING_WORLD",
			Payload =
			{
				{ Name = "isInitialLogin", Type = "bool", Nilable = false },
				{ Name = "isReloadingUi", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlayerLeavingWorld",
			Type = "Event",
			LiteralName = "PLAYER_LEAVING_WORLD",
		},
		{
			Name = "PlayerLogin",
			Type = "Event",
			LiteralName = "PLAYER_LOGIN",
		},
		{
			Name = "PlayerLogout",
			Type = "Event",
			LiteralName = "PLAYER_LOGOUT",
		},
		{
			Name = "PlayerQuiting",
			Type = "Event",
			LiteralName = "PLAYER_QUITING",
		},
		{
			Name = "SearchDbLoaded",
			Type = "Event",
			LiteralName = "SEARCH_DB_LOADED",
		},
		{
			Name = "StreamingIcon",
			Type = "Event",
			LiteralName = "STREAMING_ICON",
			Payload =
			{
				{ Name = "streamingStatus", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Sysmsg",
			Type = "Event",
			LiteralName = "SYSMSG",
			Payload =
			{
				{ Name = "string", Type = "cstring", Nilable = false },
				{ Name = "r", Type = "number", Nilable = false },
				{ Name = "g", Type = "number", Nilable = false },
				{ Name = "b", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TimePlayedMsg",
			Type = "Event",
			LiteralName = "TIME_PLAYED_MSG",
			Payload =
			{
				{ Name = "totalTimePlayed", Type = "number", Nilable = false },
				{ Name = "timePlayedThisLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UiErrorMessage",
			Type = "Event",
			LiteralName = "UI_ERROR_MESSAGE",
			Payload =
			{
				{ Name = "errorType", Type = "luaIndex", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "UiInfoMessage",
			Type = "Event",
			LiteralName = "UI_INFO_MESSAGE",
			Payload =
			{
				{ Name = "errorType", Type = "luaIndex", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "VariablesLoaded",
			Type = "Event",
			LiteralName = "VARIABLES_LOADED",
		},
		{
			Name = "WoWMouseNotFound",
			Type = "Event",
			LiteralName = "WOW_MOUSE_NOT_FOUND",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(System);