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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "EnableSmoothing",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetBorderScalar",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetBorderTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},
		},
		{
			Name = "SetFillAlpha",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFillTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},
		},
		{
			Name = "SetMapID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMergeThreshold",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "threshold", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetNumSplinePoints",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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