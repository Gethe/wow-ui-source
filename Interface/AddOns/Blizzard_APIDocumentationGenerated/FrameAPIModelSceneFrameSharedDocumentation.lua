local FrameAPIModelSceneFrameShared =
{
	Tables =
	{
		{
			Name = "ModelLightType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Directional", Type = "ModelLightType", EnumValue = 0 },
				{ Name = "Point", Type = "ModelLightType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(FrameAPIModelSceneFrameShared);