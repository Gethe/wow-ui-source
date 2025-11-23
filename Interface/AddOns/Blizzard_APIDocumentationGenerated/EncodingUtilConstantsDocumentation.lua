local EncodingUtilConstants =
{
	Tables =
	{
		{
			Name = "EncodingLimits",
			Type = "Constants",
			Values =
			{
				{ Name = "EncodingDecompressSizeLimit", Type = "size", Value = 104857600 },
				{ Name = "EncodingStackSizeLimit", Type = "number", Value = 100 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncodingUtilConstants);