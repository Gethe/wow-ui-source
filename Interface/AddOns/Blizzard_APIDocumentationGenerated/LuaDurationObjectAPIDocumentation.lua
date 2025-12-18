local LuaDurationObjectAPI =
{
	Name = "LuaDurationObjectAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "Assign",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Copies another duration object and assigns it to this one." },

			Arguments =
			{
				{ Name = "other", Type = "LuaDurationObject", Nilable = false },
			},
		},
		{
			Name = "Copy",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns a copy of this duration object." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "copy", Type = "LuaDurationObject", Nilable = false },
			},
		},
		{
			Name = "EvaluateElapsedDuration",
			Type = "Function",
			SecretWhenCurveSecret = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the elapsed duration in seconds and evaluates it against a supplied curve." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObjectBase", Nilable = false },
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaCurveEvaluatedResult", Nilable = false },
			},
		},
		{
			Name = "EvaluateElapsedPercent",
			Type = "Function",
			SecretWhenCurveSecret = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the elapsed duration as a percentage value and evaluates it against a supplied curve." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObjectBase", Nilable = false },
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaCurveEvaluatedResult", Nilable = false },
			},
		},
		{
			Name = "EvaluateRemainingDuration",
			Type = "Function",
			SecretWhenCurveSecret = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the remaining duration in seconds and evaluates it against a supplied curve." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObjectBase", Nilable = false },
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaCurveEvaluatedResult", Nilable = false },
			},
		},
		{
			Name = "EvaluateRemainingPercent",
			Type = "Function",
			SecretWhenCurveSecret = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the remaining duration as a percentage value and evaluates it against a supplied curve." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObjectBase", Nilable = false },
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaCurveEvaluatedResult", Nilable = false },
			},
		},
		{
			Name = "GetElapsedDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the elapsed duration of the stored time span." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "elapsedDuration", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "GetElapsedPercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the elapsed duration as a percentage value." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "elapsedPercent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEndTime",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the end time of the stored time span." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "endTime", Type = "FrameTime", Nilable = false },
			},
		},
		{
			Name = "GetModRate",
			Type = "Function",
			Documentation = { "Returns the divisor used to convert a duration from real time to base time." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "modRate", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRemainingDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the remaining duration of the stored time span." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "remainingDuration", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "GetRemainingPercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the remaining duration as a percentage value." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "remainingPercent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStartTime",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the start time of the stored time span." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "startTime", Type = "FrameTime", Nilable = false },
			},
		},
		{
			Name = "GetTotalDuration",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the total duration of the stored time span." },

			Arguments =
			{
				{ Name = "modifier", Type = "DurationTimeModifier", Nilable = false, Default = "RealTime" },
			},

			Returns =
			{
				{ Name = "totalDuration", Type = "DurationSeconds", Nilable = false },
			},
		},
		{
			Name = "HasSecretValues",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns true if the duration has been configured with any secret values." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsZero",
			Type = "Function",
			Documentation = { "Returns true if the duration object is measuring a zero duration time span." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isZero", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Reset",
			Type = "Function",
			Documentation = { "Resets the duration object to represent a zero duration time span." },

			Arguments =
			{
			},
		},
		{
			Name = "SetTimeFromEnd",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the duration object to represent an end time and a duration." },

			Arguments =
			{
				{ Name = "endTime", Type = "FrameTime", Nilable = false },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1, Documentation = { "Optional divisor for converting this time span to a base time." } },
			},
		},
		{
			Name = "SetTimeFromStart",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the duration object to represent a start time and a duration." },

			Arguments =
			{
				{ Name = "startTime", Type = "FrameTime", Nilable = false },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "modRate", Type = "number", Nilable = false, Default = 1, Documentation = { "Optional divisor for converting this time span to a base time." } },
			},
		},
		{
			Name = "SetTimeSpan",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Configures the duration object to represent a fixed start and end time span. If the end time is earlier than the start time, the duration will clamp to zero." },

			Arguments =
			{
				{ Name = "startTime", Type = "FrameTime", Nilable = false },
				{ Name = "endTime", Type = "FrameTime", Nilable = false },
			},
		},
		{
			Name = "SetToDefaults",
			Type = "Function",
			Documentation = { "Resets all state on the duration, and clears the secret values flag." },

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

APIDocumentation:AddDocumentationTable(LuaDurationObjectAPI);