local NamePlate =
{
	Name = "NamePlate",
	Type = "System",
	Namespace = "C_NamePlate",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetNamePlateForUnit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitTokenNamePlate", Nilable = false },
				{ Name = "includeForbidden", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "nameplate", Type = "NamePlateFrame", Nilable = false },
			},
		},
		{
			Name = "GetNamePlateSize",
			Type = "Function",

			Returns =
			{
				{ Name = "width", Type = "uiUnit", Nilable = false },
				{ Name = "height", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetNamePlates",
			Type = "Function",

			Returns =
			{
				{ Name = "nameplates", Type = "table", InnerType = "NamePlateFrame", Nilable = false },
			},
		},
		{
			Name = "SetNamePlateSize",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "width", Type = "uiUnit", Nilable = false },
				{ Name = "height", Type = "uiUnit", Nilable = false },
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

APIDocumentation:AddDocumentationTable(NamePlate);