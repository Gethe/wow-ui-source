local SecretAspectConstants =
{
	Tables =
	{
		{
			Name = "SecretAspect",
			Type = "Enumeration",
			NumValues = 17,
			MinValue = 1,
			MaxValue = 65536,
			Fields =
			{
				{ Name = "ObjectType", Type = "SecretAspect", EnumValue = 1 },
				{ Name = "ID", Type = "SecretAspect", EnumValue = 2 },
				{ Name = "Toplevel", Type = "SecretAspect", EnumValue = 4 },
				{ Name = "Text", Type = "SecretAspect", EnumValue = 8 },
				{ Name = "SecureText", Type = "SecretAspect", EnumValue = 16 },
				{ Name = "Shown", Type = "SecretAspect", EnumValue = 32 },
				{ Name = "Scale", Type = "SecretAspect", EnumValue = 64 },
				{ Name = "Alpha", Type = "SecretAspect", EnumValue = 128 },
				{ Name = "FrameLevel", Type = "SecretAspect", EnumValue = 256 },
				{ Name = "ScrollRange", Type = "SecretAspect", EnumValue = 512 },
				{ Name = "Cursor", Type = "SecretAspect", EnumValue = 1024 },
				{ Name = "VertexColor", Type = "SecretAspect", EnumValue = 2048 },
				{ Name = "Hierarchy", Type = "SecretAspect", EnumValue = 4096 },
				{ Name = "Desaturation", Type = "SecretAspect", EnumValue = 8192 },
				{ Name = "TexCoords", Type = "SecretAspect", EnumValue = 16384 },
				{ Name = "BarValue", Type = "SecretAspect", EnumValue = 32768 },
				{ Name = "Cooldown", Type = "SecretAspect", EnumValue = 65536 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SecretAspectConstants);