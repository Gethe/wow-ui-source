local GamepadTargeting =
{
	Name = "GamepadTargetingManager",
	Type = "System",
	Namespace = "C_GamepadTargeting",
	Environment = "All",

	Functions =
	{
		{
			Name = "Disable",
			Type = "Function",

			Returns =
			{
				{ Name = "targetAlreadySelected", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Enable",
			Type = "Function",
		},
		{
			Name = "HasReticleHoverTarget",
			Type = "Function",

			Returns =
			{
				{ Name = "hasReticleHoverTarget", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filter", Type = "GamepadTargetingFilters", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "GamepadTargetingFilters",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Hostile", Type = "GamepadTargetingFilters", EnumValue = 0 },
				{ Name = "Friendly", Type = "GamepadTargetingFilters", EnumValue = 1 },
				{ Name = "All", Type = "GamepadTargetingFilters", EnumValue = 2 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(GamepadTargeting);