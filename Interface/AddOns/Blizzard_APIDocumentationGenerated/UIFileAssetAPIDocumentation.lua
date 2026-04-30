local UIFileAssetAPI =
{
	Name = "UIFileAssetAPI",
	Type = "System",
	Namespace = "C_UIFileAsset",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFileID",
			Type = "Function",
			Documentation = { "Returns the numeric file ID associated with a file asset." },

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},

			Returns =
			{
				{ Name = "assetFileID", Type = "fileID", Nilable = true, Documentation = { "The file ID corresponding to the given asset. If the asset is already a file ID, it is returned unchanged; otherwise returns nil if the file path is not known to the client." } },
			},
		},
		{
			Name = "IsKnownFile",
			Type = "Function",
			Documentation = { "Determines whether a file asset is known to the client, either as a shipped asset or a locally existing loose file." },

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false, Documentation = { "True if the asset is shipped with the client or refers to a known loose file. Existence or openability of loose files is not verified." } },
			},
		},
		{
			Name = "IsLooseFile",
			Type = "Function",
			Documentation = { "Determines whether a file asset refers to a known loose (local) file." },

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLooseFile", Type = "bool", Nilable = false, Documentation = { "True if the asset refers to a loose file known to the client." } },
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

APIDocumentation:AddDocumentationTable(UIFileAssetAPI);