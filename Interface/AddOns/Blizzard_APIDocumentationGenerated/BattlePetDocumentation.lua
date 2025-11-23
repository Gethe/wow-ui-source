local BattlePet =
{
	Name = "BattlePet",
	Type = "System",
	Namespace = "C_BattlePet",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "PetBattleAbilityChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_ABILITY_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "abilityID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleActionSelected",
			Type = "Event",
			LiteralName = "PET_BATTLE_ACTION_SELECTED",
		},
		{
			Name = "PetBattleAuraApplied",
			Type = "Event",
			LiteralName = "PET_BATTLE_AURA_APPLIED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleAuraCanceled",
			Type = "Event",
			LiteralName = "PET_BATTLE_AURA_CANCELED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleAuraChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_AURA_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "auraInstanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleCaptured",
			Type = "Event",
			LiteralName = "PET_BATTLE_CAPTURED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleClose",
			Type = "Event",
			LiteralName = "PET_BATTLE_CLOSE",
		},
		{
			Name = "PetBattleFinalRound",
			Type = "Event",
			LiteralName = "PET_BATTLE_FINAL_ROUND",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleHealthChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_HEALTH_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "healthChange", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleLevelChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_LEVEL_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "newLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleMaxHealthChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_MAX_HEALTH_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "healthChange", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleOpeningDone",
			Type = "Event",
			LiteralName = "PET_BATTLE_OPENING_DONE",
		},
		{
			Name = "PetBattleOpeningStart",
			Type = "Event",
			LiteralName = "PET_BATTLE_OPENING_START",
		},
		{
			Name = "PetBattleOver",
			Type = "Event",
			LiteralName = "PET_BATTLE_OVER",
		},
		{
			Name = "PetBattleOverrideAbility",
			Type = "Event",
			LiteralName = "PET_BATTLE_OVERRIDE_ABILITY",
			Payload =
			{
				{ Name = "abilityIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetRoundPlaybackComplete",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE",
			Payload =
			{
				{ Name = "roundNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetRoundResults",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_ROUND_RESULTS",
			Payload =
			{
				{ Name = "roundNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetTypeChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_TYPE_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "stateValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePvpDuelRequestCancel",
			Type = "Event",
			LiteralName = "PET_BATTLE_PVP_DUEL_REQUEST_CANCEL",
		},
		{
			Name = "PetBattlePvpDuelRequested",
			Type = "Event",
			LiteralName = "PET_BATTLE_PVP_DUEL_REQUESTED",
			Payload =
			{
				{ Name = "fullName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "PetBattleQueueProposalAccepted",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED",
		},
		{
			Name = "PetBattleQueueProposalDeclined",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_PROPOSAL_DECLINED",
		},
		{
			Name = "PetBattleQueueProposeMatch",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_PROPOSE_MATCH",
		},
		{
			Name = "PetBattleQueueStatus",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_STATUS",
		},
		{
			Name = "PetBattleXpChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_XP_CHANGED",
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
				{ Name = "petIndex", Type = "number", Nilable = false },
				{ Name = "xpChange", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(BattlePet);