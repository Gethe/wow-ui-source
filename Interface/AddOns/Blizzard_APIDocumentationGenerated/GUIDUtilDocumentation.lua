local GUIDUtil =
{
	Name = "GUIDUtil",
	Type = "System",
	Namespace = "C_GUIDUtil",

	Functions =
	{
		{
			Name = "GetCreatureID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureID", Type = "number", Nilable = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GUIDUtil);