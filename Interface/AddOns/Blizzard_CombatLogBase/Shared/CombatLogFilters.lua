COMBATLOG_FILTER_ME = bit.bor(
	Enum.CombatLogObject.AffiliationMine,
	Enum.CombatLogObject.ReactionFriendly,
	Enum.CombatLogObject.ControlPlayer,
	Enum.CombatLogObject.TypePlayer
);

COMBATLOG_FILTER_MINE = bit.bor(
	Enum.CombatLogObject.AffiliationMine,
	Enum.CombatLogObject.ReactionFriendly,
	Enum.CombatLogObject.ControlPlayer,
	Enum.CombatLogObject.TypePlayer,
	Enum.CombatLogObject.TypeObject
);

COMBATLOG_FILTER_MY_PET = bit.bor(
	Enum.CombatLogObject.AffiliationMine,
	Enum.CombatLogObject.ReactionFriendly,
	Enum.CombatLogObject.ControlPlayer,
	Enum.CombatLogObject.TypeGuardian,
	Enum.CombatLogObject.TypePet
);

COMBATLOG_FILTER_FRIENDLY_UNITS = bit.bor(
	Enum.CombatLogObject.AffiliationParty,
	Enum.CombatLogObject.AffiliationRaid,
	Enum.CombatLogObject.AffiliationOutsider,
	Enum.CombatLogObject.ReactionFriendly,
	Enum.CombatLogObject.ControlPlayer,
	Enum.CombatLogObject.ControlNpc,
	Enum.CombatLogObject.TypePlayer,
	Enum.CombatLogObject.TypeNpc,
	Enum.CombatLogObject.TypePet,
	Enum.CombatLogObject.TypeGuardian,
	Enum.CombatLogObject.TypeObject
);

COMBATLOG_FILTER_HOSTILE_PLAYERS = bit.bor(
	Enum.CombatLogObject.AffiliationParty,
	Enum.CombatLogObject.AffiliationRaid,
	Enum.CombatLogObject.AffiliationOutsider,
	Enum.CombatLogObject.ReactionHostile,
	Enum.CombatLogObject.ControlPlayer,
	Enum.CombatLogObject.TypePlayer,
	Enum.CombatLogObject.TypeNpc,
	Enum.CombatLogObject.TypePet,
	Enum.CombatLogObject.TypeGuardian,
	Enum.CombatLogObject.TypeObject
);

COMBATLOG_FILTER_HOSTILE_UNITS = bit.bor(
	Enum.CombatLogObject.AffiliationParty,
	Enum.CombatLogObject.AffiliationRaid,
	Enum.CombatLogObject.AffiliationOutsider,
	Enum.CombatLogObject.ReactionHostile,
	Enum.CombatLogObject.ControlNpc,
	Enum.CombatLogObject.TypePlayer,
	Enum.CombatLogObject.TypeNpc,
	Enum.CombatLogObject.TypePet,
	Enum.CombatLogObject.TypeGuardian,
	Enum.CombatLogObject.TypeObject
);

COMBATLOG_FILTER_NEUTRAL_UNITS = bit.bor(
	Enum.CombatLogObject.AffiliationParty,
	Enum.CombatLogObject.AffiliationRaid,
	Enum.CombatLogObject.AffiliationOutsider,
	Enum.CombatLogObject.ReactionNeutral,
	Enum.CombatLogObject.ControlPlayer,
	Enum.CombatLogObject.ControlNpc,
	Enum.CombatLogObject.TypePlayer,
	Enum.CombatLogObject.TypeNpc,
	Enum.CombatLogObject.TypePet,
	Enum.CombatLogObject.TypeGuardian,
	Enum.CombatLogObject.TypeObject
);

COMBATLOG_FILTER_UNKNOWN_UNITS = Enum.CombatLogObject.None;
COMBATLOG_FILTER_EVERYTHING = bit.bnot(0);
