
function GameEvent.HandleLogoutCancel(_dispatcher, _event)
	StaticPopup_Hide("CAMP");
	StaticPopup_Hide("QUIT");
end

function GameEvent.HandlePetBattlePvpDuelRequested(_dispatcher, _event, arg1)
	StaticPopup_Show("PET_BATTLE_PVP_DUEL_REQUESTED", arg1);
end

function GameEvent.HandlePetBattlePvpDuelRequestCancel(_dispatcher, _event)
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED");
end

function GameEvent.HandlePetBattleQueueProposeMatch(_dispatcher, _event)
	PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE);
	StaticPopupSpecial_Show(PetBattleQueueReadyFrame);
end

function GameEvent.HandlePetBattleQueueProposalResult(_dispatcher, _event)
	StaticPopupSpecial_Hide(PetBattleQueueReadyFrame);
end

function GameEvent.HandleConfirmDisenchantRoll(_dispatcher, _event, arg1, arg2)
	ConfirmDisenchantRollDialog_Show(arg1, arg2);
end

function GameEvent.HandleQuestChoiceUpdate(_dispatcher, _event)
	ShowQuestChoiceFrame();
end

function GameEvent.HandleProductDistributionsUpdated(_dispatcher, event)
	CheckActiveStoreForFree(event);
end
