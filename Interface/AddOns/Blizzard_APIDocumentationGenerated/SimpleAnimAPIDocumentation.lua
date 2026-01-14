local SimpleAnimAPI =
{
	Name = "SimpleAnimAPI",
	Type = "ScriptObject",

	Functions =
	{
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
			Name = "GetEndDelay",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "delaySec", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOrder",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "order", Type = "number", Nilable = false },
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
			Name = "GetRegionParent",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "region", Type = "CScriptObject", Nilable = false },
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
			Name = "GetSmoothProgress",
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
			Name = "GetSmoothing",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "weights", Type = "SmoothingType", Nilable = false },
			},
		},
		{
			Name = "GetStartDelay",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "delaySec", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTarget",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "target", Type = "CScriptObject", Nilable = false },
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
			Name = "IsDelaying",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isDelaying", Type = "bool", Nilable = false },
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
			Name = "IsStopped",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isStopped", Type = "bool", Nilable = false },
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
			},
		},
		{
			Name = "Restart",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetChildKey",
			Type = "Function",

			Arguments =
			{
				{ Name = "childKey", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDuration",
			Type = "Function",

			Arguments =
			{
				{ Name = "durationSec", Type = "number", Nilable = false },
				{ Name = "recomputeGroupDuration", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetEndDelay",
			Type = "Function",

			Arguments =
			{
				{ Name = "delaySec", Type = "number", Nilable = false },
				{ Name = "recomputeGroupDuration", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "newOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetParent",
			Type = "Function",

			Arguments =
			{
				{ Name = "parent", Type = "SimpleAnimGroup", Nilable = false },
				{ Name = "order", Type = "number", Nilable = true },
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
			Name = "SetSmoothProgress",
			Type = "Function",

			Arguments =
			{
				{ Name = "durationSec", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetSmoothing",
			Type = "Function",

			Arguments =
			{
				{ Name = "weights", Type = "SmoothingType", Nilable = false },
			},
		},
		{
			Name = "SetStartDelay",
			Type = "Function",

			Arguments =
			{
				{ Name = "delaySec", Type = "number", Nilable = false },
				{ Name = "recomputeGroupDuration", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetTarget",
			Type = "Function",

			Arguments =
			{
				{ Name = "target", Type = "CScriptObject", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTargetKey",
			Type = "Function",

			Arguments =
			{
				{ Name = "key", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTargetName",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTargetParent",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimAPI);