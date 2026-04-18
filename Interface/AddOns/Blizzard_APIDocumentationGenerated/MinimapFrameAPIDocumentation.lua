local MinimapFrameAPI =
{
	Name = "MinimapFrameAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetPingPosition",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "positionX", Type = "number", Nilable = false },
				{ Name = "positionY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetZoom",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "zoomFactor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetZoomLevels",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "zoomLevels", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PingLocation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "locationX", Type = "number", Nilable = false },
				{ Name = "locationY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetBlipTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetCorpsePOIArrowTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetIconTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetMaskTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetPOIArrowTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetPlayerTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetStaticPOIArrowTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetZoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "zoomFactor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UpdateBlips",
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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(MinimapFrameAPI);