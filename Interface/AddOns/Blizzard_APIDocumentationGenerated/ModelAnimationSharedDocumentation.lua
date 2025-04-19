local ModelAnimationShared =
{
	Tables =
	{
		{
			Name = "ModelBlendOperation",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "ModelBlendOperation", EnumValue = 0 },
				{ Name = "Anim", Type = "ModelBlendOperation", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ModelAnimationShared);