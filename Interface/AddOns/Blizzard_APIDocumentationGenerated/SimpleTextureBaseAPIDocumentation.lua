local SimpleTextureBaseAPI =
{
	Name = "SimpleTextureBaseAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetAtlas",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "atlas", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetBlendMode",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "blendMode", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDesaturation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturation", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHorizTile",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "tiling", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRotation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "radians", Type = "number", Nilable = false },
				{ Name = "normalizedRotationPoint", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "GetTexCoord",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "x", Type = "number", Nilable = false, StrideIndex = 1 },
				{ Name = "y", Type = "number", Nilable = false, StrideIndex = 2 },
			},
		},
		{
			Name = "GetTexelSnappingBias",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "bias", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "textureFile", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetTextureFileID",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "textureFile", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTextureFilePath",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "textureFile", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetVertTile",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "tiling", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetVertexOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "vertexIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsBlockingLoadRequested",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "blocking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDesaturated",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSnappingToPixelGrid",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "snap", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAtlas",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "string", Nilable = false },
				{ Name = "useAtlasSize", Type = "bool", Nilable = false, Default = false },
				{ Name = "filterMode", Type = "string", Nilable = true },
				{ Name = "resetTexCoords", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "SetBlendMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "blendMode", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetBlockingLoadsRequested",
			Type = "Function",

			Arguments =
			{
				{ Name = "blocking", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetColorTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetDesaturated",
			Type = "Function",

			Arguments =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDesaturation",
			Type = "Function",

			Arguments =
			{
				{ Name = "desaturation", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetGradient",
			Type = "Function",

			Arguments =
			{
				{ Name = "orientation", Type = "string", Nilable = false },
				{ Name = "minColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "maxColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "SetHorizTile",
			Type = "Function",

			Arguments =
			{
				{ Name = "tiling", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetMask",
			Type = "Function",

			Arguments =
			{
				{ Name = "file", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetRotation",
			Type = "Function",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
				{ Name = "normalizedRotationPoint", Type = "table", Mixin = "Vector2DMixin", Nilable = true },
			},
		},
		{
			Name = "SetSnapToPixelGrid",
			Type = "Function",

			Arguments =
			{
				{ Name = "snap", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetTexCoord",
			Type = "Function",

			Arguments =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTexelSnappingBias",
			Type = "Function",

			Arguments =
			{
				{ Name = "bias", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "textureAsset", Type = "string", Nilable = true },
				{ Name = "wrapModeHorizontal", Type = "string", Nilable = true },
				{ Name = "wrapModeVertical", Type = "string", Nilable = true },
				{ Name = "filterMode", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetVertTile",
			Type = "Function",

			Arguments =
			{
				{ Name = "tiling", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetVertexOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "vertexIndex", Type = "number", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleTextureBaseAPI);