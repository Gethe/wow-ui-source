local ActionBarShared =
{
	Tables =
	{
		{
			Name = "ActionBarChargeInfo",
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
			Name = "ActionBarCooldownInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "startTime", Type = "number", Nilable = false, Documentation = { "If cooldown is active, time started; 0 if no cooldown; Current time if isEnabled is false" } },
				{ Name = "duration", Type = "number", Nilable = false, Documentation = { "Cooldown duration in seconds if active; 0 if cooldown is inactive" } },
				{ Name = "isEnabled", Type = "bool", Nilable = false, Documentation = { "False if cooldown is on hold (ex: some cooldowns only start after an active spell is cancelled); True otherwise" } },
				{ Name = "modRate", Type = "number", Nilable = false, Documentation = { "Rate at which cooldown UI should update" } },
				{ Name = "activeCategory", Type = "number", Nilable = true, Documentation = { "Indicates which category is responsible for determining the duration. A nil value indicates the duration was determined through some other logic, e.g. the spell is on hold." } },
				{ Name = "timeUntilEndOfStartRecovery", Type = "number", Nilable = true, Documentation = { "When this is set it indicates that the spell is in recovery and this is how long it will be until that recovery period is finished" } },
				{ Name = "isOnGCD", Type = "bool", Nilable = true, NeverSecret = true, Documentation = { "Whether or not this spell is considered to be on the global cooldown, do not trust this field unless responding to a SPELL_UPDATE_COOLDOWN event" } },
			},
		},
		{
			Name = "ActionUsableState",
			Type = "Structure",
			Fields =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
				{ Name = "usable", Type = "bool", Nilable = false },
				{ Name = "noMana", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ActionBarShared);