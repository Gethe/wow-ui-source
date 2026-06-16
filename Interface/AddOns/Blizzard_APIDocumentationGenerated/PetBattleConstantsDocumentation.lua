local PetBattleConstants =
{
	Tables =
	{
		{
			Name = "PetBattleQueueStatus",
			Type = "Enumeration",
			NumValues = 22,
			MinValue = 0,
			MaxValue = 21,
			Fields =
			{
				{ Name = "None", Type = "PetBattleQueueStatus", EnumValue = 0 },
				{ Name = "Queued", Type = "PetBattleQueueStatus", EnumValue = 1 },
				{ Name = "QueuedUpdate", Type = "PetBattleQueueStatus", EnumValue = 2 },
				{ Name = "AlreadyQueued", Type = "PetBattleQueueStatus", EnumValue = 3 },
				{ Name = "JoinFailed", Type = "PetBattleQueueStatus", EnumValue = 4 },
				{ Name = "JoinFailedSlots", Type = "PetBattleQueueStatus", EnumValue = 5 },
				{ Name = "JoinFailedJournalLock", Type = "PetBattleQueueStatus", EnumValue = 6 },
				{ Name = "JoinFailedNeutral", Type = "PetBattleQueueStatus", EnumValue = 7 },
				{ Name = "MatchAccepted", Type = "PetBattleQueueStatus", EnumValue = 8 },
				{ Name = "MatchDeclined", Type = "PetBattleQueueStatus", EnumValue = 9 },
				{ Name = "MatchOpponentDeclined", Type = "PetBattleQueueStatus", EnumValue = 10 },
				{ Name = "ProposalTimedOut", Type = "PetBattleQueueStatus", EnumValue = 11 },
				{ Name = "Removed", Type = "PetBattleQueueStatus", EnumValue = 12 },
				{ Name = "RequeuedAfterInternalError", Type = "PetBattleQueueStatus", EnumValue = 13 },
				{ Name = "RequeuedAfterOpponentRemoved", Type = "PetBattleQueueStatus", EnumValue = 14 },
				{ Name = "Matchmaking", Type = "PetBattleQueueStatus", EnumValue = 15 },
				{ Name = "LostConnection", Type = "PetBattleQueueStatus", EnumValue = 16 },
				{ Name = "Shutdown", Type = "PetBattleQueueStatus", EnumValue = 17 },
				{ Name = "Suspended", Type = "PetBattleQueueStatus", EnumValue = 18 },
				{ Name = "Unsuspended", Type = "PetBattleQueueStatus", EnumValue = 19 },
				{ Name = "InBattle", Type = "PetBattleQueueStatus", EnumValue = 20 },
				{ Name = "NoBattlingHere", Type = "PetBattleQueueStatus", EnumValue = 21 },
			},
		},
		{
			Name = "PetbattleSlot",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Slot_0", Type = "PetbattleSlot", EnumValue = 0 },
				{ Name = "Slot_1", Type = "PetbattleSlot", EnumValue = 1 },
				{ Name = "Slot_2", Type = "PetbattleSlot", EnumValue = 2 },
			},
		},
		{
			Name = "PetbattleState",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Created", Type = "PetbattleState", EnumValue = 0 },
				{ Name = "WaitingPreBattle", Type = "PetbattleState", EnumValue = 1 },
				{ Name = "RoundInProgress", Type = "PetbattleState", EnumValue = 2 },
				{ Name = "WaitingForFrontPets", Type = "PetbattleState", EnumValue = 3 },
				{ Name = "CreatedFailed", Type = "PetbattleState", EnumValue = 4 },
				{ Name = "FinalRound", Type = "PetbattleState", EnumValue = 5 },
				{ Name = "Finished", Type = "PetbattleState", EnumValue = 6 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PetBattleConstants);