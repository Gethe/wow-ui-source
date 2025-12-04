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
			SynchronousEvent = true,
		},
		{
			Name = "CaptureframesSucceeded",
			Type = "Event",
			LiteralName = "CAPTUREFRAMES_SUCCEEDED",
			SynchronousEvent = true,
		},
		{
			Name = "DisableTaxiBenchmark",
			Type = "Event",
			LiteralName = "DISABLE_TAXI_BENCHMARK",
			SynchronousEvent = true,
		},
		{
			Name = "EnableTaxiBenchmark",
			Type = "Event",
			LiteralName = "ENABLE_TAXI_BENCHMARK",
			SynchronousEvent = true,
		},
		{
			Name = "FirstFrameRendered",
			Type = "Event",
			LiteralName = "FIRST_FRAME_RENDERED",
			UniqueEvent = true,
		},
		{
			Name = "GenericError",
			Type = "Event",
			LiteralName = "GENERIC_ERROR",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "errorMessage", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GlobalMouseDown",
			Type = "Event",
			LiteralName = "GLOBAL_MOUSE_DOWN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "button", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GlobalMouseUp",
			Type = "Event",
			LiteralName = "GLOBAL_MOUSE_UP",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "button", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "InitialHotfixesApplied",
			Type = "Event",
			LiteralName = "INITIAL_HOTFIXES_APPLIED",
			SynchronousEvent = true,
		},
		{
			Name = "LocResult",
			Type = "Event",
			LiteralName = "LOC_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogoutCancel",
			Type = "Event",
			LiteralName = "LOGOUT_CANCEL",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerCamping",
			Type = "Event",
			LiteralName = "PLAYER_CAMPING",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerEnteringWorld",
			Type = "Event",
			LiteralName = "PLAYER_ENTERING_WORLD",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "PlayerLogin",
			Type = "Event",
			LiteralName = "PLAYER_LOGIN",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerLogout",
			Type = "Event",
			LiteralName = "PLAYER_LOGOUT",
			SynchronousEvent = true,
		},
		{
			Name = "PlayerQuiting",
			Type = "Event",
			LiteralName = "PLAYER_QUITING",
			SynchronousEvent = true,
		},
		{
			Name = "SearchDbLoaded",
			Type = "Event",
			LiteralName = "SEARCH_DB_LOADED",
			SynchronousEvent = true,
		},
		{
			Name = "StreamingIcon",
			Type = "Event",
			LiteralName = "STREAMING_ICON",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "streamingStatus", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Sysmsg",
			Type = "Event",
			LiteralName = "SYSMSG",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			UniqueEvent = true,
			Payload =
			{
				{ Name = "errorType", Type = "luaIndex", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
			},
		},
		{
			Name = "UiErrorPopup",
			Type = "Event",
			LiteralName = "UI_ERROR_POPUP",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "errorType", Type = "luaIndex", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
			},
		},
		{
			Name = "UiInfoMessage",
			Type = "Event",
			LiteralName = "UI_INFO_MESSAGE",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "errorType", Type = "luaIndex", Nilable = false },
				{ Name = "message", Type = "string", Nilable = false },
			},
		},
		{
			Name = "VariablesLoaded",
			Type = "Event",
			LiteralName = "VARIABLES_LOADED",
			SynchronousEvent = true,
		},
		{
			Name = "WoWMouseNotFound",
			Type = "Event",
			LiteralName = "WOW_MOUSE_NOT_FOUND",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(System);