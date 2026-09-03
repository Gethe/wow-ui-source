local TimedSignalMapShared =
{
	Tables =
	{
		{
			Name = "TimedSignalMapEntry",
			Type = "Structure",
			Documentation = { "Structure associating a key with a scheduled time." },
			Fields =
			{
				{ Name = "key", Type = "number", Nilable = false, Documentation = { "The key that has been scheduled." } },
				{ Name = "time", Type = "FrameTime", Nilable = false, Documentation = { "Absolute time, on the same clock as GetTime(), at which the key is scheduled to signal." } },
			},
		},
		{
			Name = "TimedSignalMapCallback",
			Type = "CallbackType",
			Documentation = { "Invoked by a timed signal map when a scheduled time has arrived." },

			Arguments =
			{
				{ Name = "key", Type = "number", Nilable = false, ConditionalSecret = true, Documentation = { "The key whose scheduled time has arrived; secret if the timed signal map has secret values." } },
			},
		},
	},

	Predicates =
	{
		{
			Name = "RequiresTimedSignalMapAccess",
			Type = "Precondition",
			FailureMode = "Error",
			Documentation = { "Guarded APIs on a timed signal map raise an error when the map holds secret values and is accessed from a tainted execution context." },
		},
	},
};

APIDocumentation:AddDocumentationTable(TimedSignalMapShared);