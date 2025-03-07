local EncodingUtil =
{
	Name = "EncodingUtil",
	Type = "System",
	Namespace = "C_EncodingUtil",

	Functions =
	{
		{
			Name = "CompressString",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "source", Type = "stringView", Nilable = false },
				{ Name = "method", Type = "CompressionMethod", Nilable = false },
				{ Name = "level", Type = "CompressionLevel", Nilable = false, Default = "Default" },
			},

			Returns =
			{
				{ Name = "output", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DecodeBase64",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "source", Type = "stringView", Nilable = false },
				{ Name = "variant", Type = "Base64Variant", Nilable = false, Default = "Standard" },
			},

			Returns =
			{
				{ Name = "output", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DecompressString",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "source", Type = "stringView", Nilable = false },
				{ Name = "method", Type = "CompressionMethod", Nilable = false },
			},

			Returns =
			{
				{ Name = "output", Type = "string", Nilable = false },
			},
		},
		{
			Name = "DeserializeJSON",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "source", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "LuaValueVariant", Nilable = true },
			},
		},
		{
			Name = "EncodeBase64",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "source", Type = "stringView", Nilable = false },
				{ Name = "variant", Type = "Base64Variant", Nilable = false, Default = "Standard" },
			},

			Returns =
			{
				{ Name = "output", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SerializeJSON",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "value", Type = "LuaValueVariant", Nilable = true },
			},

			Returns =
			{
				{ Name = "output", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "Base64Variant",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Standard", Type = "Base64Variant", EnumValue = 0, Documentation = { "Encodes with the alphabet defined in RFC 4648 (with potential padding bytes)" } },
				{ Name = "StandardUrlSafe", Type = "Base64Variant", EnumValue = 1, Documentation = { "Encodes with the 'URL and Filename Safe' alphabet from RFC 4648 (with potential padding bytes)" } },
			},
		},
		{
			Name = "CompressionLevel",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Default", Type = "CompressionLevel", EnumValue = 0 },
				{ Name = "OptimizeForSpeed", Type = "CompressionLevel", EnumValue = 1 },
				{ Name = "OptimizeForSize", Type = "CompressionLevel", EnumValue = 2 },
			},
		},
		{
			Name = "CompressionMethod",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Deflate", Type = "CompressionMethod", EnumValue = 0 },
				{ Name = "Zlib", Type = "CompressionMethod", EnumValue = 1 },
				{ Name = "Gzip", Type = "CompressionMethod", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncodingUtil);