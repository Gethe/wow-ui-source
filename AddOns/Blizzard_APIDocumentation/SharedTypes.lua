local SharedTypes =
{
	Tables =
	{
		{
			Name = "colorRGB",
			Type = "Structure",
			Mixin = "ColorMixin",
			Fields =
			{
				{ Name = "r", Type = "number", Nilable = false },
				{ Name = "g", Type = "number", Nilable = false },
				{ Name = "b", Type = "number", Nilable = false },
			},
		},
		{
			Name = "colorRGBA",
			Type = "Structure",
			Mixin = "ColorMixin",
			Fields =
			{
				{ Name = "r", Type = "number", Nilable = false },
				{ Name = "g", Type = "number", Nilable = false },
				{ Name = "b", Type = "number", Nilable = false },
				{ Name = "a", Type = "number", Nilable = false },
			},
		},
		{
			Name = "vector2",
			Type = "Structure",
			Mixin = "Vector2DMixin",
			Fields =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},
		},
		{
			Name = "vector3",
			Type = "Structure",
			Mixin = "Vector3DMixin",
			Fields =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "z", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SharedTypes);