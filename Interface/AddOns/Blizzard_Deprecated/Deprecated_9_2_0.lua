
-- These are functions that were deprecated in 9.2.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Pet battle enum conversions
do
	Enum.PetBattleState = Enum.PetbattleState;

	LE_PET_BATTLE_STATE_CREATED = Enum.PetbattleState.Created;
	LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE = Enum.PetbattleState.WaitingPreBattle;
	LE_PET_BATTLE_STATE_ROUND_IN_PROGRESS = Enum.PetbattleState.RoundInProgress;
	LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS = Enum.PetbattleState.WaitingForFrontPets;
	LE_PET_BATTLE_STATE_CREATED_FAILED = Enum.PetbattleState.CreatedFailed;
	LE_PET_BATTLE_STATE_FINAL_ROUND = Enum.PetbattleState.FinalRound;
	LE_PET_BATTLE_STATE_FINISHED = Enum.PetbattleState.Finished;
end

-- Unit Sex enum conversions
do
	Enum.Unitsex = Enum.UnitSex;
end
