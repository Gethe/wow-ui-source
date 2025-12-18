local SimpleTextureBaseAPI =
{
	Name = "SimpleTextureBaseAPI",
	Type = "ScriptObject",
	Environment = "All",

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
			Name = "ClearVertexOffsets",
			Type = "Function",

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
			SecretReturnsForAspect = { Enum.SecretAspect.Desaturation },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Rotation },

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
			SecretReturnsForAspect = { Enum.SecretAspect.TexCoords },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "ulX", Type = "number", Nilable = false },
				{ Name = "ulY", Type = "number", Nilable = false },
				{ Name = "llX", Type = "number", Nilable = false },
				{ Name = "llY", Type = "number", Nilable = false },
				{ Name = "urX", Type = "number", Nilable = false },
				{ Name = "urY", Type = "number", Nilable = false },
				{ Name = "lrX", Type = "number", Nilable = false },
				{ Name = "lrY", Type = "number", Nilable = false },
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
			MayReturnNothing = true,

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
			MayReturnNothing = true,

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
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",

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
			SecretReturnsForAspect = { Enum.SecretAspect.Desaturation },

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
			Name = "ResetTexCoord",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetAtlas",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
				{ Name = "useAtlasSize", Type = "bool", Nilable = false, Default = false },
				{ Name = "filterMode", Type = "FilterMode", Nilable = true },
				{ Name = "resetTexCoords", Type = "bool", Nilable = true },
				{ Name = "wrapModeHorizontal", Type = "cstring", Nilable = true },
				{ Name = "wrapModeVertical", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "SetBlendMode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "blendMode", Type = "BlendMode", Nilable = false },
			},
		},
		{
			Name = "SetBlockingLoadsRequested",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "blocking", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetColorTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			SecretArgumentsAddAspect = { Enum.SecretAspect.Desaturation },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetDesaturation",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Desaturation },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "SetGradient",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "tiling", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetMask",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "file", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetRotation",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Rotation },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "radians", Type = "number", Nilable = false },
				{ Name = "normalizedRotationPoint", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
			},
		},
		{
			Name = "SetSnapToPixelGrid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "snap", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetSpriteSheetCell",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.TexCoords },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "cell", Type = "luaIndex", Nilable = false, ConditionalSecret = true },
				{ Name = "numRows", Type = "number", Nilable = false },
				{ Name = "numColumns", Type = "number", Nilable = false },
				{ Name = "cellWidth", Type = "number", Nilable = true },
				{ Name = "cellHeight", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SetTexCoord",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.TexCoords },
			SecretArguments = "AllowedWhenTainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "bias", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "SetTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			SecretArguments = "AllowedWhenUntainted",
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
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Controls whether the center and sides are Stretched or Tiled when using nineslice texture rendering. Defaults to Stretched." },

			Arguments =
			{
				{ Name = "sliceMode", Type = "UITextureSliceMode", Nilable = false },
			},
		},
		{
			Name = "SetVertTile",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "tiling", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetVertexOffset",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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