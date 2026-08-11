local SimpleVectorGraphicsAPI =
{
	Name = "SimpleVectorGraphicsAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "ClearSVG",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetSVGFileID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "svgFile", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "HasSVG",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSVG", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSVG",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "svgAsset", Type = "FileAsset", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleVectorGraphicsAPI);