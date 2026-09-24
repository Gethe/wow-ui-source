-- Camelot-specific trainer UI overrides

function TrainerUI_UseCategories()
	return C_Trainer.GetTrainerType() ~= Enum.TrainerType.Pet;
end
