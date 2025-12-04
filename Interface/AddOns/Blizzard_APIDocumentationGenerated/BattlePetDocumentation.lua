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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleAuraApplied",
			Type = "Event",
			LiteralName = "PET_BATTLE_AURA_APPLIED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleFinalRound",
			Type = "Event",
			LiteralName = "PET_BATTLE_FINAL_ROUND",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattleHealthChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_HEALTH_CHANGED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleOpeningStart",
			Type = "Event",
			LiteralName = "PET_BATTLE_OPENING_START",
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleOver",
			Type = "Event",
			LiteralName = "PET_BATTLE_OVER",
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleOverrideAbility",
			Type = "Event",
			LiteralName = "PET_BATTLE_OVERRIDE_ABILITY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "abilityIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "owner", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetRoundPlaybackComplete",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "roundNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetRoundResults",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_ROUND_RESULTS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "roundNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PetBattlePetTypeChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_PET_TYPE_CHANGED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "PetBattlePvpDuelRequested",
			Type = "Event",
			LiteralName = "PET_BATTLE_PVP_DUEL_REQUESTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "fullName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "PetBattleQueueProposalAccepted",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED",
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleQueueProposalDeclined",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_PROPOSAL_DECLINED",
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleQueueProposeMatch",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_PROPOSE_MATCH",
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleQueueStatus",
			Type = "Event",
			LiteralName = "PET_BATTLE_QUEUE_STATUS",
			SynchronousEvent = true,
		},
		{
			Name = "PetBattleXpChanged",
			Type = "Event",
			LiteralName = "PET_BATTLE_XP_CHANGED",
			SynchronousEvent = true,
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