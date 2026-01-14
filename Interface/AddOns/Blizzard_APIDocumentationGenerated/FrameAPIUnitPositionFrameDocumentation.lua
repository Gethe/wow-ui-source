local FrameAPIUnitPositionFrame =
{
	Name = "FrameAPIUnitPositionFrame",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AddUnit",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitTokenString", Type = "cstring", Nilable = false },
				{ Name = "asset", Type = "TextureAssetDisk", Nilable = false },
				{ Name = "width", Type = "uiUnit", Nilable = true },
				{ Name = "height", Type = "uiUnit", Nilable = true },
				{ Name = "r", Type = "number", Nilable = true },
				{ Name = "g", Type = "number", Nilable = true },
				{ Name = "b", Type = "number", Nilable = true },
				{ Name = "a", Type = "number", Nilable = true },
				{ Name = "sublayer", Type = "number", Nilable = true },
				{ Name = "showFacing", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ClearUnits",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "FinalizeUnits",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetMouseOverUnits",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "units", Type = "string", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetPlayerPingScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
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
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPlayerPingScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPlayerPingTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "textureType", Type = "PingTextureType", Nilable = false },
				{ Name = "asset", Type = "FileAsset", Nilable = false },
				{ Name = "width", Type = "uiUnit", Nilable = false, Default = 0 },
				{ Name = "height", Type = "uiUnit", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetUiMapID",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetUnitColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "string", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StartPlayerPing",
			Type = "Function",

			Arguments =
			{
				{ Name = "duration", Type = "number", Nilable = false, Default = 0 },
				{ Name = "fadeDuration", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "StopPlayerPing",
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

APIDocumentation:AddDocumentationTable(FrameAPIUnitPositionFrame);