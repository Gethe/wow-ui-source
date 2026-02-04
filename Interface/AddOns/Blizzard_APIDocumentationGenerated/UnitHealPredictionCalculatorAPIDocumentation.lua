local UnitHealPredictionCalculatorAPI =
{
	Name = "UnitHealPredictionCalculatorAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "EvaluateCurrentHealthPercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the percentage of current unit health and evaluates it against the supplied curve." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObjectBase", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaCurveEvaluatedResult", Nilable = false },
			},
		},
		{
			Name = "EvaluateMissingHealthPercent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Calculates the percentage of missing unit health and evaluates it against the supplied curve." },

			Arguments =
			{
				{ Name = "curve", Type = "LuaCurveObjectBase", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaCurveEvaluatedResult", Nilable = false },
			},
		},
		{
			Name = "GetCurrentHealth",
			Type = "Function",
			Documentation = { "Returns the base amount of unit health." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "currentHealth", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentHealthPercent",
			Type = "Function",
			Documentation = { "Returns the percentage of current unit health." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "currentHealthPercent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDamageAbsorbClampMode",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns the configured damage absorb clamping mode." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "damageAbsorbClampMode", Type = "UnitDamageAbsorbClampMode", Nilable = false },
			},
		},
		{
			Name = "GetDamageAbsorbs",
			Type = "Function",
			Documentation = { "Calculates damage absorb values and clamping according to the configured options." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "Amount of applied damage absorb affects with potential reductions from clamping included." } },
				{ Name = "clamped", Type = "bool", Nilable = false, Documentation = { "If true, the value is in excess of the clamp boundary." } },
			},
		},
		{
			Name = "GetHealAbsorbClampMode",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns the configured heal absorb clamping mode." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "healAbsorbClampMode", Type = "UnitHealAbsorbClampMode", Nilable = false },
			},
		},
		{
			Name = "GetHealAbsorbMode",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns the configured heal absorb processing mode." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "healAbsorbMode", Type = "UnitHealAbsorbMode", Nilable = false },
			},
		},
		{
			Name = "GetHealAbsorbs",
			Type = "Function",
			Documentation = { "Calculates heal absorb values and clamping according to the configured options." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "Amount of applied heal absorb affects with potential reductions from incoming heals and clamping included." } },
				{ Name = "clamped", Type = "bool", Nilable = false, Documentation = { "If true, the value is in excess of the clamp boundary." } },
			},
		},
		{
			Name = "GetIncomingHealClampMode",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns the configured incoming heal clamping mode." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "incomingHealClampMode", Type = "UnitIncomingHealClampMode", Nilable = false },
			},
		},
		{
			Name = "GetIncomingHealOverflowPercent",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns the configured incoming heal maximum overflow percentage." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "incomingHealOverflowPercent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetIncomingHeals",
			Type = "Function",
			Documentation = { "Calculates incoming heal values and clamping according to the configured options." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "Amount of incoming heals across all units with potential reductions from heal absorb effects included." } },
				{ Name = "amountFromHealer", Type = "number", Nilable = false, Documentation = { "Amount of incoming heals from the healer unit. Will never exceed the all-units value." } },
				{ Name = "amountFromOthers", Type = "number", Nilable = false, Documentation = { "Amount of incoming heals from units other than theh healer. Calculated as the difference between amount and amount-from-healer." } },
				{ Name = "clamped", Type = "bool", Nilable = false, Documentation = { "If true, the value is in excess of the clamp boundary." } },
			},
		},
		{
			Name = "GetMaximumDamageAbsorbs",
			Type = "Function",
			Documentation = { "Returns the maximum clamping amount for damage absorbs." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maximumDamageAbsorbs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaximumHealAbsorbs",
			Type = "Function",
			Documentation = { "Returns the maximum clamping amount for heal absorbs." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maximumHealAbsorbs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaximumHealth",
			Type = "Function",
			Documentation = { "Returns the base amount of maximum unit health." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maximumHealth", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaximumHealthMode",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns the configured maximum health mode." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maximumHealthMode", Type = "UnitMaximumHealthMode", Nilable = false },
			},
		},
		{
			Name = "GetMaximumIncomingHeals",
			Type = "Function",
			Documentation = { "Returns the maximum clamping amount for incoming heals." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maximumIncomingHeals", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMissingHealth",
			Type = "Function",
			Documentation = { "Returns the base amount of missing unit health." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "missingHealth", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMissingHealthPercent",
			Type = "Function",
			Documentation = { "Returns the percentage of missing unit health." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "missingHealthPercent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPredictedValues",
			Type = "Function",
			Documentation = { "Returns the raw total figures used for data calculations." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "predictedValues", Type = "UnitHealPredictionValues", Nilable = false },
			},
		},
		{
			Name = "GetTotalDamageAbsorbs",
			Type = "Function",
			Documentation = { "Returns the base total amount of all applied damage absorb shields." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "totalDamageAbsorbs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalHealAbsorbs",
			Type = "Function",
			Documentation = { "Returns the base total amount of all applied heal absorption effects." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "totalHealAbsorbs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalIncomingHeals",
			Type = "Function",
			Documentation = { "Returns the base total amount of all incoming heals." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "totalIncomingHeals", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalIncomingHealsFromHealer",
			Type = "Function",
			Documentation = { "Returns the base total amount of all incoming heals from the healer unit, if any." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "totalIncomingHealsFromHealer", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasSecretValues",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns true if the object has been configured with any secret values." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Reset",
			Type = "Function",
			Documentation = { "Resets all stored state on the object." },

			Arguments =
			{
			},
		},
		{
			Name = "ResetPredictedValues",
			Type = "Function",
			Documentation = { "Resets all stored healing values used for calculations." },

			Arguments =
			{
			},
		},
		{
			Name = "SetDamageAbsorbClampMode",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Changes the clamping mode used when calculating damage absorb amounts." },

			Arguments =
			{
				{ Name = "damageAbsorbClampMode", Type = "UnitDamageAbsorbClampMode", Nilable = false },
			},
		},
		{
			Name = "SetHealAbsorbClampMode",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Changes the clamping mode used when calculating heal absorb amounts." },

			Arguments =
			{
				{ Name = "healAbsorbClampMode", Type = "UnitHealAbsorbClampMode", Nilable = false },
			},
		},
		{
			Name = "SetHealAbsorbMode",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Changes the processing mode used when calculating both heal absorb and incoming heal amounts." },

			Arguments =
			{
				{ Name = "healAbsorbMode", Type = "UnitHealAbsorbMode", Nilable = false },
			},
		},
		{
			Name = "SetIncomingHealClampMode",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Changes the clamping mode used when calculating incoming heal amounts." },

			Arguments =
			{
				{ Name = "incomingHealClampMode", Type = "UnitIncomingHealClampMode", Nilable = false },
			},
		},
		{
			Name = "SetIncomingHealOverflowPercent",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Changes the maximum overflow percentage for incoming heals. Increasing this to a value over 1.0 will mean that incoming heals can extend beyond maximum health." },

			Arguments =
			{
				{ Name = "incomingHealOverflowPercent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMaximumHealthMode",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Changes the calculation mode for maximum health values used for clamping." },

			Arguments =
			{
				{ Name = "maximumHealthMode", Type = "UnitMaximumHealthMode", Nilable = false },
			},
		},
		{
			Name = "SetPredictedValues",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the healing values used for all calculations." },

			Arguments =
			{
				{ Name = "predictedValues", Type = "UnitHealPredictionValues", Nilable = false },
			},
		},
		{
			Name = "SetToDefaults",
			Type = "Function",
			Documentation = { "Resets all state on the object, and clears the secret values flag." },

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(UnitHealPredictionCalculatorAPI);