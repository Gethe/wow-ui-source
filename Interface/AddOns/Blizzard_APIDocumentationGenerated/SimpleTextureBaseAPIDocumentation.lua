local SimpleTextureBaseAPI =
{
	Name = "SimpleTextureBaseAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ClearTextureSlice",
			Type = "Function",
			Documentation = { "Disable shader based nineslice texture rendering. Since SetAtlas will automatically load slice data for the atlas from the DB, can be useful if you want to disable nineslice after setting an atlas." },

			Arguments =
			{
			},
		},
		{
			Name = "GetAtlas",
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
			Name = "GetBlendMode",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "blendMode", Type = "BlendMode", Nilable = false },
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
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
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
				{ Name = "normalizedRotationPoint", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
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
				{ Name = "bias", Type = "normalizedValue", Nilable = false },
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
				{ Name = "textureFile", Type = "cstring", Nilable = true },
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
				{ Name = "textureFile", Type = "fileID", Nilable = false },
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
				{ Name = "textureFile", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetTextureSliceMargins",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTextureSliceMode",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "sliceMode", Type = "UITextureSliceMode", Nilable = false },
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
				{ Name = "vertexIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
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
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
				{ Name = "useAtlasSize", Type = "bool", Nilable = false, Default = false },
				{ Name = "filterMode", Type = "FilterMode", Nilable = true },
				{ Name = "resetTexCoords", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "SetBlendMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "blendMode", Type = "BlendMode", Nilable = false },
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
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
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
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "SetGradient",
			Type = "Function",

			Arguments =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
				{ Name = "minColor", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
				{ Name = "maxColor", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
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
				{ Name = "file", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetRotation",
			Type = "Function",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
				{ Name = "normalizedRotationPoint", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
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
				{ Name = "bias", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "SetTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "textureAsset", Type = "cstring", Nilable = true },
				{ Name = "wrapModeHorizontal", Type = "cstring", Nilable = true },
				{ Name = "wrapModeVertical", Type = "cstring", Nilable = true },
				{ Name = "filterMode", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTextureSliceMargins",
			Type = "Function",
			Documentation = { "Enables nineslice texture rendering using the specified pixel margins. Preferred over legacy nineslice approach that uses 9 separate textures." },

			Arguments =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTextureSliceMode",
			Type = "Function",
			Documentation = { "Controls whether the center and sides are Stretched or Tiled when using nineslice texture rendering. Defaults to Stretched." },

			Arguments =
			{
				{ Name = "sliceMode", Type = "UITextureSliceMode", Nilable = false },
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
				{ Name = "vertexIndex", Type = "luaIndex", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
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