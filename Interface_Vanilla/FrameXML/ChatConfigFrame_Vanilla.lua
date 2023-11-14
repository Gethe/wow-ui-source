COMBAT_CONFIG_MESSAGETYPES_MISC = {
	[1] = {
		text = DAMAGE_SHIELD,
		checked = function () return HasMessageType("DAMAGE_SHIELD", "DAMAGE_SHIELD_MISSED"); end;
		func = function (self, checked) ToggleMessageType(checked, "DAMAGE_SHIELD", "DAMAGE_SHIELD_MISSED"); end;
		tooltip = DAMAGE_SHIELD_COMBATLOG_TOOLTIP,
	},
	[2] = {
		text = ENVIRONMENTAL_DAMAGE,
		checked = function () return HasMessageType("ENVIRONMENTAL_DAMAGE"); end;
		func = function (self, checked) ToggleMessageType(checked, "ENVIRONMENTAL_DAMAGE"); end;
		tooltip = ENVIRONMENTAL_DAMAGE_COMBATLOG_TOOLTIP,
	},
	[3] = {
		text = KILLS,
		checked = function () return HasMessageType("PARTY_KILL"); end;
		func = function (self, checked) ToggleMessageType(checked, "PARTY_KILL"); end;
		tooltip = KILLS_COMBATLOG_TOOLTIP,
	},
	[4] = {
		text = DEATHS,
		type = {"UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES"};
		checked = function () return HasMessageType("UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES"); end;
		func = function (self, checked) ToggleMessageType(checked, "UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES"); end;
		tooltip = DEATHS_COMBATLOG_TOOLTIP,
	},
	[5] = {
		text = PET_LOYALTY,
		type = {"UNIT_LOYALTY"};
		checked = function () return HasMessageType("UNIT_LOYALTY"); end;
		func = function (self, checked) ToggleMessageType(checked, "UNIT_LOYALTY"); end;
		tooltip = UNIT_LOYALTY_COMBATLOG_TOOLTIP,
	},
};
