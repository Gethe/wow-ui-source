local eventHandlers = {
	["CONFIRM_DISENCHANT_ROLL"] = GameEvent.HandleConfirmDisenchantRoll,
	["PET_BATTLE_PVP_DUEL_REQUEST_CANCEL"] = GameEvent.HandlePetBattlePvpDuelRequestCancel,
	["PET_BATTLE_PVP_DUEL_REQUESTED"] = GameEvent.HandlePetBattlePvpDuelRequested,
	["PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED"] = GameEvent.HandlePetBattleQueueProposalResult,
	["PET_BATTLE_QUEUE_PROPOSAL_DECLINED"] = GameEvent.HandlePetBattleQueueProposalResult,
	["PET_BATTLE_QUEUE_PROPOSE_MATCH"] = GameEvent.HandlePetBattleQueueProposeMatch,
	["QUEST_CHOICE_UPDATE"] = GameEvent.HandleQuestChoiceUpdate,
};

function GameEvent.RegisterMistsEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end

function GameEvent.InitEvents()
	GameEvent.RegisterSharedEvents();
	GameEvent.RegisterClassicEvents();
	GameEvent.RegisterVanillaEvents();
	GameEvent.RegisterTBCEvents();
	GameEvent.RegisterWrathEvents();
	GameEvent.RegisterCataEvents();
	GameEvent.RegisterMistsEvents();
end
