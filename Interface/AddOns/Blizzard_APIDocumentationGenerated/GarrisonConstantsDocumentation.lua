local GarrisonConstants =
{
	Tables =
	{
		{
			Name = "ContributionState",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "ContributionState", EnumValue = 0 },
				{ Name = "Building", Type = "ContributionState", EnumValue = 1 },
				{ Name = "Active", Type = "ContributionState", EnumValue = 2 },
				{ Name = "UnderAttack", Type = "ContributionState", EnumValue = 3 },
				{ Name = "Destroyed", Type = "ContributionState", EnumValue = 4 },
			},
		},
		{
			Name = "CovenantSkill",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 2730,
			MaxValue = 2733,
			Fields =
			{
				{ Name = "Kyrian", Type = "CovenantSkill", EnumValue = 2730 },
				{ Name = "Venthyr", Type = "CovenantSkill", EnumValue = 2731 },
				{ Name = "NightFae", Type = "CovenantSkill", EnumValue = 2732 },
				{ Name = "Necrolord", Type = "CovenantSkill", EnumValue = 2733 },
			},
		},
		{
			Name = "CovenantType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "CovenantType", EnumValue = 0 },
				{ Name = "Kyrian", Type = "CovenantType", EnumValue = 1 },
				{ Name = "Venthyr", Type = "CovenantType", EnumValue = 2 },
				{ Name = "NightFae", Type = "CovenantType", EnumValue = 3 },
				{ Name = "Necrolord", Type = "CovenantType", EnumValue = 4 },
			},
		},
		{
			Name = "FollowerAbilityCastResult",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 0,
			MaxValue = 14,
			Fields =
			{
				{ Name = "Success", Type = "FollowerAbilityCastResult", EnumValue = 0 },
				{ Name = "Failure", Type = "FollowerAbilityCastResult", EnumValue = 1 },
				{ Name = "NoPendingCast", Type = "FollowerAbilityCastResult", EnumValue = 2 },
				{ Name = "InvalidTarget", Type = "FollowerAbilityCastResult", EnumValue = 3 },
				{ Name = "InvalidFollowerSpell", Type = "FollowerAbilityCastResult", EnumValue = 4 },
				{ Name = "RerollNotAllowed", Type = "FollowerAbilityCastResult", EnumValue = 5 },
				{ Name = "SingleMissionDuration", Type = "FollowerAbilityCastResult", EnumValue = 6 },
				{ Name = "MustTargetFollower", Type = "FollowerAbilityCastResult", EnumValue = 7 },
				{ Name = "MustTargetTrait", Type = "FollowerAbilityCastResult", EnumValue = 8 },
				{ Name = "InvalidFollowerType", Type = "FollowerAbilityCastResult", EnumValue = 9 },
				{ Name = "MustBeUnique", Type = "FollowerAbilityCastResult", EnumValue = 10 },
				{ Name = "CannotTargetLimitedUseFollower", Type = "FollowerAbilityCastResult", EnumValue = 11 },
				{ Name = "MustTargetLimitedUseFollower", Type = "FollowerAbilityCastResult", EnumValue = 12 },
				{ Name = "AlreadyAtMaxDurability", Type = "FollowerAbilityCastResult", EnumValue = 13 },
				{ Name = "CannotTargetNonAutoMissionFollower", Type = "FollowerAbilityCastResult", EnumValue = 14 },
			},
		},
		{
			Name = "GarrAutoBoardIndex",
			Type = "Enumeration",
			NumValues = 14,
			MinValue = -1,
			MaxValue = 12,
			Fields =
			{
				{ Name = "None", Type = "GarrAutoBoardIndex", EnumValue = -1 },
				{ Name = "AllyLeftBack", Type = "GarrAutoBoardIndex", EnumValue = 0 },
				{ Name = "AllyRightBack", Type = "GarrAutoBoardIndex", EnumValue = 1 },
				{ Name = "AllyLeftFront", Type = "GarrAutoBoardIndex", EnumValue = 2 },
				{ Name = "AllyCenterFront", Type = "GarrAutoBoardIndex", EnumValue = 3 },
				{ Name = "AllyRightFront", Type = "GarrAutoBoardIndex", EnumValue = 4 },
				{ Name = "EnemyLeftFront", Type = "GarrAutoBoardIndex", EnumValue = 5 },
				{ Name = "EnemyCenterLeftFront", Type = "GarrAutoBoardIndex", EnumValue = 6 },
				{ Name = "EnemyCenterRightFront", Type = "GarrAutoBoardIndex", EnumValue = 7 },
				{ Name = "EnemyRightFront", Type = "GarrAutoBoardIndex", EnumValue = 8 },
				{ Name = "EnemyLeftBack", Type = "GarrAutoBoardIndex", EnumValue = 9 },
				{ Name = "EnemyCenterLeftBack", Type = "GarrAutoBoardIndex", EnumValue = 10 },
				{ Name = "EnemyCenterRightBack", Type = "GarrAutoBoardIndex", EnumValue = 11 },
				{ Name = "EnemyRightBack", Type = "GarrAutoBoardIndex", EnumValue = 12 },
			},
		},
		{
			Name = "GarrAutoCombatSpellTutorialFlag",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "GarrAutoCombatSpellTutorialFlag", EnumValue = 0 },
				{ Name = "Single", Type = "GarrAutoCombatSpellTutorialFlag", EnumValue = 1 },
				{ Name = "Column", Type = "GarrAutoCombatSpellTutorialFlag", EnumValue = 2 },
				{ Name = "Row", Type = "GarrAutoCombatSpellTutorialFlag", EnumValue = 3 },
				{ Name = "All", Type = "GarrAutoCombatSpellTutorialFlag", EnumValue = 4 },
			},
		},
		{
			Name = "GarrAutoCombatTutorial",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 1,
			MaxValue = 1024,
			Fields =
			{
				{ Name = "SelectMission", Type = "GarrAutoCombatTutorial", EnumValue = 1 },
				{ Name = "PlaceCompanion", Type = "GarrAutoCombatTutorial", EnumValue = 2 },
				{ Name = "HealCompanion", Type = "GarrAutoCombatTutorial", EnumValue = 4 },
				{ Name = "LevelHeal", Type = "GarrAutoCombatTutorial", EnumValue = 8 },
				{ Name = "BeneficialEffect", Type = "GarrAutoCombatTutorial", EnumValue = 16 },
				{ Name = "AttackSingle", Type = "GarrAutoCombatTutorial", EnumValue = 32 },
				{ Name = "AttackColumn", Type = "GarrAutoCombatTutorial", EnumValue = 64 },
				{ Name = "AttackRow", Type = "GarrAutoCombatTutorial", EnumValue = 128 },
				{ Name = "AttackAll", Type = "GarrAutoCombatTutorial", EnumValue = 256 },
				{ Name = "TroopTutorial", Type = "GarrAutoCombatTutorial", EnumValue = 512 },
				{ Name = "EnvironmentalEffect", Type = "GarrAutoCombatTutorial", EnumValue = 1024 },
			},
		},
		{
			Name = "GarrAutoCombatantRole",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "None", Type = "GarrAutoCombatantRole", EnumValue = 0 },
				{ Name = "Melee", Type = "GarrAutoCombatantRole", EnumValue = 1 },
				{ Name = "RangedPhysical", Type = "GarrAutoCombatantRole", EnumValue = 2 },
				{ Name = "RangedMagic", Type = "GarrAutoCombatantRole", EnumValue = 3 },
				{ Name = "HealSupport", Type = "GarrAutoCombatantRole", EnumValue = 4 },
				{ Name = "Tank", Type = "GarrAutoCombatantRole", EnumValue = 5 },
			},
		},
		{
			Name = "GarrAutoEventFlags",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "GarrAutoEventFlags", EnumValue = 0 },
				{ Name = "AutoAttack", Type = "GarrAutoEventFlags", EnumValue = 1 },
				{ Name = "Passive", Type = "GarrAutoEventFlags", EnumValue = 2 },
				{ Name = "Environment", Type = "GarrAutoEventFlags", EnumValue = 4 },
			},
		},
		{
			Name = "GarrAutoMissionEventType",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "MeleeDamage", Type = "GarrAutoMissionEventType", EnumValue = 0 },
				{ Name = "RangeDamage", Type = "GarrAutoMissionEventType", EnumValue = 1 },
				{ Name = "SpellMeleeDamage", Type = "GarrAutoMissionEventType", EnumValue = 2 },
				{ Name = "SpellRangeDamage", Type = "GarrAutoMissionEventType", EnumValue = 3 },
				{ Name = "Heal", Type = "GarrAutoMissionEventType", EnumValue = 4 },
				{ Name = "PeriodicDamage", Type = "GarrAutoMissionEventType", EnumValue = 5 },
				{ Name = "PeriodicHeal", Type = "GarrAutoMissionEventType", EnumValue = 6 },
				{ Name = "ApplyAura", Type = "GarrAutoMissionEventType", EnumValue = 7 },
				{ Name = "RemoveAura", Type = "GarrAutoMissionEventType", EnumValue = 8 },
				{ Name = "Died", Type = "GarrAutoMissionEventType", EnumValue = 9 },
			},
		},
		{
			Name = "GarrAutoPreviewTargetType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "None", Type = "GarrAutoPreviewTargetType", EnumValue = 0 },
				{ Name = "Damage", Type = "GarrAutoPreviewTargetType", EnumValue = 1 },
				{ Name = "Heal", Type = "GarrAutoPreviewTargetType", EnumValue = 2 },
				{ Name = "Buff", Type = "GarrAutoPreviewTargetType", EnumValue = 4 },
				{ Name = "Debuff", Type = "GarrAutoPreviewTargetType", EnumValue = 8 },
			},
		},
		{
			Name = "GarrFollowerMissionCompleteState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Alive", Type = "GarrFollowerMissionCompleteState", EnumValue = 0 },
				{ Name = "KilledByMissionFailure", Type = "GarrFollowerMissionCompleteState", EnumValue = 1 },
				{ Name = "SavedByPreventDeath", Type = "GarrFollowerMissionCompleteState", EnumValue = 2 },
				{ Name = "OutOfDurability", Type = "GarrFollowerMissionCompleteState", EnumValue = 3 },
			},
		},
		{
			Name = "GarrFollowerQuality",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "None", Type = "GarrFollowerQuality", EnumValue = 0 },
				{ Name = "Common", Type = "GarrFollowerQuality", EnumValue = 1 },
				{ Name = "Uncommon", Type = "GarrFollowerQuality", EnumValue = 2 },
				{ Name = "Rare", Type = "GarrFollowerQuality", EnumValue = 3 },
				{ Name = "Epic", Type = "GarrFollowerQuality", EnumValue = 4 },
				{ Name = "Legendary", Type = "GarrFollowerQuality", EnumValue = 5 },
				{ Name = "Title", Type = "GarrFollowerQuality", EnumValue = 6 },
			},
		},
		{
			Name = "GarrTalentCostType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Initial", Type = "GarrTalentCostType", EnumValue = 0 },
				{ Name = "Respec", Type = "GarrTalentCostType", EnumValue = 1 },
				{ Name = "MakePermanent", Type = "GarrTalentCostType", EnumValue = 2 },
				{ Name = "TreeReset", Type = "GarrTalentCostType", EnumValue = 3 },
			},
		},
		{
			Name = "GarrTalentFeatureSubtype",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Generic", Type = "GarrTalentFeatureSubtype", EnumValue = 0 },
				{ Name = "Bastion", Type = "GarrTalentFeatureSubtype", EnumValue = 1 },
				{ Name = "Revendreth", Type = "GarrTalentFeatureSubtype", EnumValue = 2 },
				{ Name = "Ardenweald", Type = "GarrTalentFeatureSubtype", EnumValue = 3 },
				{ Name = "Maldraxxus", Type = "GarrTalentFeatureSubtype", EnumValue = 4 },
			},
		},
		{
			Name = "GarrTalentFeatureType",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Generic", Type = "GarrTalentFeatureType", EnumValue = 0 },
				{ Name = "AnimaDiversion", Type = "GarrTalentFeatureType", EnumValue = 1 },
				{ Name = "TravelPortals", Type = "GarrTalentFeatureType", EnumValue = 2 },
				{ Name = "Adventures", Type = "GarrTalentFeatureType", EnumValue = 3 },
				{ Name = "ReservoirUpgrades", Type = "GarrTalentFeatureType", EnumValue = 4 },
				{ Name = "SanctumUnique", Type = "GarrTalentFeatureType", EnumValue = 5 },
				{ Name = "SoulBinds", Type = "GarrTalentFeatureType", EnumValue = 6 },
				{ Name = "AnimaDiversionMap", Type = "GarrTalentFeatureType", EnumValue = 7 },
				{ Name = "Cyphers", Type = "GarrTalentFeatureType", EnumValue = 8 },
			},
		},
		{
			Name = "GarrTalentResearchCostSource",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Talent", Type = "GarrTalentResearchCostSource", EnumValue = 0 },
				{ Name = "Tree", Type = "GarrTalentResearchCostSource", EnumValue = 1 },
			},
		},
		{
			Name = "GarrTalentSocketType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "GarrTalentSocketType", EnumValue = 0 },
				{ Name = "Spell", Type = "GarrTalentSocketType", EnumValue = 1 },
				{ Name = "Conduit", Type = "GarrTalentSocketType", EnumValue = 2 },
			},
		},
		{
			Name = "GarrTalentTreeType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Tiers", Type = "GarrTalentTreeType", EnumValue = 0 },
				{ Name = "Classic", Type = "GarrTalentTreeType", EnumValue = 1 },
			},
		},
		{
			Name = "GarrTalentType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Standard", Type = "GarrTalentType", EnumValue = 0 },
				{ Name = "Minor", Type = "GarrTalentType", EnumValue = 1 },
				{ Name = "Major", Type = "GarrTalentType", EnumValue = 2 },
				{ Name = "Socket", Type = "GarrTalentType", EnumValue = 3 },
			},
		},
		{
			Name = "GarrTalentUI",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Generic", Type = "GarrTalentUI", EnumValue = 0 },
				{ Name = "CovenantSanctum", Type = "GarrTalentUI", EnumValue = 1 },
				{ Name = "SoulBinds", Type = "GarrTalentUI", EnumValue = 2 },
				{ Name = "AnimaDiversionMap", Type = "GarrTalentUI", EnumValue = 3 },
			},
		},
		{
			Name = "GarrisonTalentAvailability",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Available", Type = "GarrisonTalentAvailability", EnumValue = 0 },
				{ Name = "Unavailable", Type = "GarrisonTalentAvailability", EnumValue = 1 },
				{ Name = "UnavailableAnotherIsResearching", Type = "GarrisonTalentAvailability", EnumValue = 2 },
				{ Name = "UnavailableNotEnoughResources", Type = "GarrisonTalentAvailability", EnumValue = 3 },
				{ Name = "UnavailableNotEnoughGold", Type = "GarrisonTalentAvailability", EnumValue = 4 },
				{ Name = "UnavailableTierUnavailable", Type = "GarrisonTalentAvailability", EnumValue = 5 },
				{ Name = "UnavailablePlayerCondition", Type = "GarrisonTalentAvailability", EnumValue = 6 },
				{ Name = "UnavailableAlreadyHave", Type = "GarrisonTalentAvailability", EnumValue = 7 },
				{ Name = "UnavailableRequiresPrerequisiteTalent", Type = "GarrisonTalentAvailability", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GarrisonConstants);