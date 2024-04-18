local SpellShared =
{
	Tables =
	{
		{
			Name = "SpellCooldownInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "startTime", Type = "number", Nilable = false, Documentation = { "If cooldown is active, time started; 0 if no cooldown; Current time if isEnabled is false" } },
				{ Name = "duration", Type = "number", Nilable = false, Documentation = { "Cooldown duration in seconds if active; 0 if cooldown is inactive" } },
				{ Name = "isEnabled", Type = "bool", Nilable = false, Documentation = { "False if cooldown is on hold (ex: some cooldowns only start after an active spell is cancelled); True otherwise" } },
				{ Name = "modRate", Type = "number", Nilable = false, Documentation = { "Rate at which cooldown UI should update" } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SpellShared);