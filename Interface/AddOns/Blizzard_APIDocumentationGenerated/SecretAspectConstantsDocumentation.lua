local SecretAspectConstants =
{
	Tables =
	{
		{
			Name = "SecretAspect",
			Type = "Enumeration",
			NumValues = 24,
			MinValue = 1,
			MaxValue = 262144,
			Fields =
			{
				{ Name = "ObjectDebug", Type = "SecretAspect", EnumValue = 1 },
				{ Name = "ObjectName", Type = "SecretAspect", EnumValue = 1 },
				{ Name = "ObjectType", Type = "SecretAspect", EnumValue = 1 },
				{ Name = "ObjectSecrets", Type = "SecretAspect", EnumValue = 1 },
				{ Name = "ObjectSecurity", Type = "SecretAspect", EnumValue = 1 },
				{ Name = "Hierarchy", Type = "SecretAspect", EnumValue = 1 },
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
				{ Name = "Desaturation", Type = "SecretAspect", EnumValue = 4096 },
				{ Name = "TexCoords", Type = "SecretAspect", EnumValue = 8192 },
				{ Name = "BarValue", Type = "SecretAspect", EnumValue = 16384 },
				{ Name = "Cooldown", Type = "SecretAspect", EnumValue = 32768 },
				{ Name = "Rotation", Type = "SecretAspect", EnumValue = 65536 },
				{ Name = "MinimumWidth", Type = "SecretAspect", EnumValue = 131072 },
				{ Name = "Padding", Type = "SecretAspect", EnumValue = 262144 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SecretAspectConstants);