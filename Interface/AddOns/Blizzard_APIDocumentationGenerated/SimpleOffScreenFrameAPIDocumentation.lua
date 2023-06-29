local SimpleOffScreenFrameAPI =
{
	Name = "SimpleOffScreenFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ApplySnapshot",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
				{ Name = "snapshotID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Flush",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetMaxSnapshots",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maxSnapshots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsSnapshotValid",
			Type = "Function",

			Arguments =
			{
				{ Name = "snapshotID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMaxSnapshots",
			Type = "Function",

			Arguments =
			{
				{ Name = "maxSnapshots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TakeSnapshot",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "snapshotID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TestPrintToFile",
			Type = "Function",
			Documentation = { "Unavailable in public builds" },

			Arguments =
			{
				{ Name = "snapshotID", Type = "number", Nilable = false },
				{ Name = "filename", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UsesNPOT",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "usesNPOT", Type = "bool", Nilable = true },
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

APIDocumentation:AddDocumentationTable(SimpleOffScreenFrameAPI);