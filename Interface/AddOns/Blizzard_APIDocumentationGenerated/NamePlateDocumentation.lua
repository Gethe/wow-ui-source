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
				{ Name = "unitToken", Type = "UnitTokenRestrictedForAddOns", Nilable = false },
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
			Name = "GetTargetClampingInsets",
			Type = "Function",

			Returns =
			{
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
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
		{
			Name = "SetTargetClampingInsets",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "top", Type = "uiUnit", Nilable = false, Default = 0 },
				{ Name = "bottom", Type = "uiUnit", Nilable = false, Default = 0 },
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