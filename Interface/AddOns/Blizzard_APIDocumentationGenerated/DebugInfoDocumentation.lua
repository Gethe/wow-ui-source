local DebugInfo =
{
	Name = "DebugInfo",
	Type = "System",

	Functions =
	{
		{
			Name = "GetDebugAnimationStats",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitGUID", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "upperBodyAnim", Type = "cstring", Nilable = false },
				{ Name = "lowerBodyAnim", Type = "cstring", Nilable = false },
				{ Name = "mountAnim", Type = "cstring", Nilable = false },
				{ Name = "upperBodyPrimaryAnim", Type = "cstring", Nilable = false },
				{ Name = "upperBodyPrimaryAnimVariation", Type = "number", Nilable = false },
				{ Name = "upperBodySecondaryAnim", Type = "cstring", Nilable = false },
				{ Name = "upperBodySecondaryAnimVariation", Type = "number", Nilable = false },
				{ Name = "lowerBodyPrimaryAnim", Type = "cstring", Nilable = false },
				{ Name = "lowerBodyPrimaryAnimVariation", Type = "number", Nilable = false },
				{ Name = "lowerBodySecondaryAnim", Type = "cstring", Nilable = false },
				{ Name = "lowerBodySecondaryAnimVariation", Type = "number", Nilable = false },
				{ Name = "animKitID", Type = "number", Nilable = true },
				{ Name = "mountAnimKitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetDebugPerf",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDebugSpellEffects",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDebugStats",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDebugTargetCustomizationInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDebugUnitInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "unitGUID", Type = "WOWGUID", Nilable = false },
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

APIDocumentation:AddDocumentationTable(DebugInfo);