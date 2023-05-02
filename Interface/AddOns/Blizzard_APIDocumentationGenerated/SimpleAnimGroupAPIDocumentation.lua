local SimpleAnimGroupAPI =
{
	Name = "SimpleAnimGroupAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CreateAnimation",
			Type = "Function",

			Arguments =
			{
				{ Name = "animationType", Type = "cstring", Nilable = true },
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "templateName", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "anim", Type = "SimpleAnim", Nilable = false },
			},
		},
		{
			Name = "Finish",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetAnimationSpeedMultiplier",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "animationSpeedMultiplier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAnimations",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scriptObject", Type = "ScriptObject", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetDuration",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "durationSec", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetElapsed",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "elapsedSec", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLoopState",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "loopState", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetLooping",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "loopType", Type = "LoopType", Nilable = false },
			},
		},
		{
			Name = "GetProgress",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "progress", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptTypeName", Type = "cstring", Nilable = false },
				{ Name = "bindingType", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "script", Type = "luaFunction", Nilable = false },
			},
		},
		{
			Name = "HasScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptName", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasScript", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HookScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptTypeName", Type = "cstring", Nilable = false },
				{ Name = "script", Type = "luaFunction", Nilable = false },
				{ Name = "bindingType", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsDone",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isDone", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPaused",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isPaused", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPendingFinish",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isPendingFinish", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlaying",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isPlaying", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsReverse",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isReverse", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSetToFinalAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isSetToFinalAlpha", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Pause",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "Play",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
				{ Name = "offset", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "RemoveAnimations",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "Restart",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
				{ Name = "offset", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetAnimationSpeedMultiplier",
			Type = "Function",

			Arguments =
			{
				{ Name = "animationSpeedMultiplier", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLooping",
			Type = "Function",

			Arguments =
			{
				{ Name = "loopType", Type = "LoopType", Nilable = false },
			},
		},
		{
			Name = "SetPlaying",
			Type = "Function",

			Arguments =
			{
				{ Name = "play", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "scriptTypeName", Type = "cstring", Nilable = false },
				{ Name = "script", Type = "luaFunction", Nilable = true },
			},
		},
		{
			Name = "SetToFinalAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "setToFinalAlpha", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Stop",
			Type = "Function",

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(SimpleAnimGroupAPI);