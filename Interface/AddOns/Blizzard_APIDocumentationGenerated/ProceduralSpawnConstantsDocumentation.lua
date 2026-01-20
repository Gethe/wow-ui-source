local ProceduralSpawnConstants =
{
	Tables =
	{
		{
			Name = "ProceduralSpawnInteractionMode",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "ProceduralSpawnInteractionMode", EnumValue = 0 },
				{ Name = "Paint", Type = "ProceduralSpawnInteractionMode", EnumValue = 1 },
				{ Name = "Manipulate", Type = "ProceduralSpawnInteractionMode", EnumValue = 2 },
			},
		},
		{
			Name = "ProceduralSpawnVolumeChunkFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "ProceduralSpawnVolumeChunkFlags", EnumValue = 0 },
				{ Name = "AllSubChunksSet", Type = "ProceduralSpawnVolumeChunkFlags", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ProceduralSpawnConstants);