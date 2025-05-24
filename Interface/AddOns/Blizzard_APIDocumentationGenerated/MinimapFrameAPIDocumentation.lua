local MinimapFrameAPI =
{
	Name = "MinimapFrameAPI",
	Type = "ScriptObject",

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

			Arguments =
			{
				{ Name = "locationX", Type = "number", Nilable = false },
				{ Name = "locationY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetArchBlobInsideAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetArchBlobInsideTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetArchBlobOutsideAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetArchBlobOutsideTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetArchBlobRingAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetArchBlobRingScalar",
			Type = "Function",

			Arguments =
			{
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetArchBlobRingTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetBlipTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetCorpsePOIArrowTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetIconTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetPOIArrowTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetPlayerTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetQuestBlobInsideAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetQuestBlobInsideTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetQuestBlobOutsideAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetQuestBlobOutsideTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetQuestBlobRingAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetQuestBlobRingScalar",
			Type = "Function",

			Arguments =
			{
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetQuestBlobRingTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetStaticPOIArrowTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetTaskBlobInsideAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTaskBlobInsideTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetTaskBlobOutsideAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTaskBlobOutsideTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetTaskBlobRingAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTaskBlobRingScalar",
			Type = "Function",

			Arguments =
			{
				{ Name = "scalar", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTaskBlobRingTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetZoom",
			Type = "Function",

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
};

APIDocumentation:AddDocumentationTable(MinimapFrameAPI);