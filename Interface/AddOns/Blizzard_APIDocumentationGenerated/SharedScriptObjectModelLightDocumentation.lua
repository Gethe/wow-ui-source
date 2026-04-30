local SharedScriptObjectModelLight =
{
	Tables =
	{
		{
			Name = "ModelLight",
			Type = "Structure",
			Fields =
			{
				{ Name = "omnidirectional", Type = "bool", Nilable = false, Default = false },
				{ Name = "point", Type = "vector3", Nilable = false, Documentation = { "If this light is omnidirectional then point refers to a position, otherwise it refers to a direction" } },
				{ Name = "ambientIntensity", Type = "number", Nilable = false, Default = 0 },
				{ Name = "ambientColor", Type = "colorRGB", Nilable = true },
				{ Name = "diffuseIntensity", Type = "number", Nilable = false, Default = 0 },
				{ Name = "diffuseColor", Type = "colorRGB", Nilable = true },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SharedScriptObjectModelLight);