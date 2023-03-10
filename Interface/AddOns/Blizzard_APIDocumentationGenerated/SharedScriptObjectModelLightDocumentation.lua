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
				{ Name = "point", Type = "vector3", Mixin = "Vector3DMixin", Nilable = false, Documentation = { "If this light is omnidirectional then point refers to a position, otherwise it refers to a direction" } },
				{ Name = "ambientIntensity", Type = "number", Nilable = false, Default = 0 },
				{ Name = "ambientColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = true },
				{ Name = "diffuseIntensity", Type = "number", Nilable = false, Default = 0 },
				{ Name = "diffuseColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SharedScriptObjectModelLight);