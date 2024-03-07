local FrameAPIFogOfWarFrame =
{
	Name = "FrameAPIFogOfWarFrame",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetFogOfWarBackgroundAtlas",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "GetFogOfWarBackgroundTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = true },
			},
		},
		{
			Name = "GetFogOfWarMaskAtlas",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "GetFogOfWarMaskTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = true },
			},
		},
		{
			Name = "GetMaskScalar",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUiMapID",
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
			Name = "SetFogOfWarBackgroundAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "SetFogOfWarBackgroundTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
				{ Name = "horizontalTile", Type = "bool", Nilable = false },
				{ Name = "verticalTile", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFogOfWarMaskAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "SetFogOfWarMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "FileAsset", Nilable = false },
			},
		},
		{
			Name = "SetMaskScalar",
			Type = "Function",

			Arguments =
			{
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetUiMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameAPIFogOfWarFrame);