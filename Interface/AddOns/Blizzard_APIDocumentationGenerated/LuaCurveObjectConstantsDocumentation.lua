local LuaCurveObjectConstants =
{
	Tables =
	{
		{
			Name = "LuaCurveType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Linear", Type = "LuaCurveType", EnumValue = 0, Documentation = { "Linearly interpolates between points." } },
				{ Name = "Step", Type = "LuaCurveType", EnumValue = 1, Documentation = { "Performs no interpolation between points, instead snapping to values exactly." } },
				{ Name = "Cosine", Type = "LuaCurveType", EnumValue = 2, Documentation = { "Interpolates between points with cosine smoothing applied." } },
				{ Name = "Cubic", Type = "LuaCurveType", EnumValue = 3, Documentation = { "Interpolates between points with cubic smoothing applied. Requires a minimum of four points be defined; less than this will fall back to Cosine interpolation." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LuaCurveObjectConstants);