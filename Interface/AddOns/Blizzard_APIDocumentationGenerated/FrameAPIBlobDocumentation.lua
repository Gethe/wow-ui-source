local FrameAPIBlob =
{
	Name = "FrameAPIBlob",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "DrawAll",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "DrawBlob",
			Type = "Function",

			Arguments =
			{
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "draw", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "DrawNone",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "EnableMerging",
			Type = "Function",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EnableSmoothing",
			Type = "Function",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "GetMapID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetBorderAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetBorderScalar",
			Type = "Function",

			Arguments =
			{
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetBorderTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},
		},
		{
			Name = "SetFillAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFillTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},
		},
		{
			Name = "SetMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMergeThreshold",
			Type = "Function",

			Arguments =
			{
				{ Name = "threshold", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetNumSplinePoints",
			Type = "Function",

			Arguments =
			{
				{ Name = "numSplinePoints", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameAPIBlob);