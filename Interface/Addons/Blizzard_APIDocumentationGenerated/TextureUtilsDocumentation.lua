local TextureUtils =
{
	Name = "TextureUtils",
	Type = "System",
	Namespace = "C_Texture",

	Functions =
	{
		{
			Name = "ClearTitleIconTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "GetAtlasElementID",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},

			Returns =
			{
				{ Name = "elementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAtlasID",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},

			Returns =
			{
				{ Name = "atlasID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAtlasInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AtlasInfo", Nilable = false },
			},
		},
		{
			Name = "GetFilenameFromFileDataID",
			Type = "Function",

			Arguments =
			{
				{ Name = "fileDataID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "filename", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetTitleIconTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "titleID", Type = "string", Nilable = false },
				{ Name = "version", Type = "TitleIconVersion", Nilable = false },
				{ Name = "callback", Type = "GetTitleIconTextureCallback", Nilable = false },
			},
		},
		{
			Name = "IsTitleIconTextureReady",
			Type = "Function",

			Arguments =
			{
				{ Name = "titleID", Type = "string", Nilable = false },
				{ Name = "version", Type = "TitleIconVersion", Nilable = false },
			},

			Returns =
			{
				{ Name = "ready", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTitleIconTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
				{ Name = "titleID", Type = "string", Nilable = false },
				{ Name = "version", Type = "TitleIconVersion", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "TitleIconVersion",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Small", Type = "TitleIconVersion", EnumValue = 0 },
				{ Name = "Medium", Type = "TitleIconVersion", EnumValue = 1 },
				{ Name = "Large", Type = "TitleIconVersion", EnumValue = 2 },
			},
		},
		{
			Name = "AtlasInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "rawSize", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "leftTexCoord", Type = "number", Nilable = false },
				{ Name = "rightTexCoord", Type = "number", Nilable = false },
				{ Name = "topTexCoord", Type = "number", Nilable = false },
				{ Name = "bottomTexCoord", Type = "number", Nilable = false },
				{ Name = "tilesHorizontally", Type = "bool", Nilable = false },
				{ Name = "tilesVertically", Type = "bool", Nilable = false },
				{ Name = "file", Type = "fileID", Nilable = true },
				{ Name = "filename", Type = "string", Nilable = true },
				{ Name = "sliceData", Type = "UITextureSliceData", Nilable = true },
			},
		},
		{
			Name = "GetTitleIconTextureCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TextureUtils);