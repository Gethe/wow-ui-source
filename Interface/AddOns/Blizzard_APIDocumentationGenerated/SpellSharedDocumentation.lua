local SpellShared =
{
	Tables =
	{
		{
			Name = "SpellChargeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currentCharges", Type = "number", Nilable = false, Documentation = { "Number of charges currently available" } },
				{ Name = "maxCharges", Type = "number", Nilable = false, Documentation = { "Max number of charges that can be accumulated" } },
				{ Name = "cooldownStartTime", Type = "number", Nilable = false, Documentation = { "If charge cooldown is active, time at which the most recent charge cooldown began; 0 if cooldown is not active" } },
				{ Name = "cooldownDuration", Type = "number", Nilable = false, Documentation = { "Cooldown duration in seconds required to generate a charge" } },
				{ Name = "chargeModRate", Type = "number", Nilable = false, Documentation = { "Rate at which cooldown UI should update" } },
			},
		},
		{
			Name = "SpellPowerCostInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "PowerType", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false, Documentation = { "The name or 'power token' for this power type (ex: MANA, FOCUS, etc)" } },
				{ Name = "cost", Type = "number", Nilable = false, Documentation = { "Full cost including optional cost; Optional cost is cost the spell will use but isn't required (ex: Rogue spell might cost 1CP but have optional cost of up to 5 more)" } },
				{ Name = "minCost", Type = "number", Nilable = false, Documentation = { "Cost excluding optional cost; This is min required to cast the spell" } },
				{ Name = "costPercent", Type = "number", Nilable = false, Documentation = { "Cost as a percentage of base maximum resource; May be 0 if the cost is simply a flat cost" } },
				{ Name = "costPerSec", Type = "number", Nilable = false, Documentation = { "Cost as a percentage of base maximum resource consumed per second, used by channel spells; May be 0 if cost is simply a flat cost" } },
				{ Name = "requiredAuraID", Type = "number", Nilable = false, Documentation = { "An aura the caster must have for the cost to apply; Usually based on things like active spec or shapeshift form" } },
				{ Name = "hasRequiredAura", Type = "bool", Nilable = false, Documentation = { "True if there is a requiredAuraID and the caster currently has that aura; Caster is either the current player or their pet, depending on spell type" } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellShared);