local eventHandlers = {
	["CONFIRM_DISENCHANT_ROLL"] = function(...) GameEvent.HandleConfirmDisenchantRoll(...) end,
	["PET_BATTLE_PVP_DUEL_REQUEST_CANCEL"] = function(...) GameEvent.HandlePetBattlePvpDuelRequestCancel(...) end,
	["PET_BATTLE_PVP_DUEL_REQUESTED"] = function(...) GameEvent.HandlePetBattlePvpDuelRequested(...) end,
	["PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED"] = function(...) GameEvent.HandlePetBattleQueueProposalResult(...) end,
	["PET_BATTLE_QUEUE_PROPOSAL_DECLINED"] = function(...) GameEvent.HandlePetBattleQueueProposalResult(...) end,
	["PET_BATTLE_QUEUE_PROPOSE_MATCH"] = function(...) GameEvent.HandlePetBattleQueueProposeMatch(...) end,
	["QUEST_CHOICE_UPDATE"] = function(...) GameEvent.HandleQuestChoiceUpdate(...) end,
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
