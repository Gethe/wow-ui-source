local TimedSignalMapAPI =
{
	Name = "TimedSignalMapAPI",
	Type = "ScriptObject",
	ObjectType = "Userdata",
	Environment = "All",
	Documentation = { "An object that manages a collection of integer keys, each scheduled to signal at a specific time.", "When a key's time arrives it is removed from the map and passed to the map's callback, letting you track many keyed deadlines through a single callback rather than scheduling each one individually." },

	Functions =
	{
		{
			Name = "CancelAllSignals",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			Documentation = { "Cancels all scheduled signals." },

			Arguments =
			{
			},
		},
		{
			Name = "CancelSignal",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Cancels the scheduled signal for the specified key, if one exists." },

			Arguments =
			{
				{ Name = "key", Type = "number", Nilable = false, Documentation = { "Key to cancel. No effect if the key is not scheduled." } },
			},
		},
		{
			Name = "GetNextSignal",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			Documentation = { "Returns the next key due to signal along with its scheduled time." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "key", Type = "number", Nilable = false, Documentation = { "The key that has been scheduled." } },
				{ Name = "time", Type = "FrameTime", Nilable = false, Documentation = { "Absolute time, on the same clock as GetTime(), at which the key is scheduled to signal." } },
			},
		},
		{
			Name = "GetSignalCount",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			Documentation = { "Returns the number of keys currently scheduled to signal." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "count", Type = "size", Nilable = false, Documentation = { "Count of scheduled keys." } },
			},
		},
		{
			Name = "GetSignalTime",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the absolute time at which the specified key is scheduled to signal." },

			Arguments =
			{
				{ Name = "key", Type = "number", Nilable = false, Documentation = { "Key to query." } },
			},

			Returns =
			{
				{ Name = "time", Type = "FrameTime", Nilable = true, Documentation = { "Absolute time the key will signal; nil if not scheduled." } },
			},
		},
		{
			Name = "HasSignal",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns whether the specified key is currently scheduled to signal." },

			Arguments =
			{
				{ Name = "key", Type = "number", Nilable = false, Documentation = { "Key to test." } },
			},

			Returns =
			{
				{ Name = "hasSignal", Type = "bool", Nilable = false, Documentation = { "True if the key is scheduled to signal." } },
			},
		},
		{
			Name = "SignalAfter",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Schedules the specified key to signal after a delay from the current time, replacing any existing schedule for that key." },

			Arguments =
			{
				{ Name = "key", Type = "number", Nilable = false, Documentation = { "Key to signal. Re-scheduling an existing key replaces its time." } },
				{ Name = "secondsFromNow", Type = "Seconds", Nilable = false, Documentation = { "Delay in seconds from now, converted to an absolute time when scheduled." } },
			},
		},
		{
			Name = "SignalAt",
			Type = "Function",
			RequiresTimedSignalMapAccess = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Schedules the specified key to signal at an absolute time, replacing any existing schedule for that key." },

			Arguments =
			{
				{ Name = "key", Type = "number", Nilable = false, Documentation = { "Key to signal. Re-scheduling an existing key replaces its time." } },
				{ Name = "time", Type = "FrameTime", Nilable = false, Documentation = { "Absolute time at which to signal, on the same clock as GetTime()." } },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(TimedSignalMapAPI);