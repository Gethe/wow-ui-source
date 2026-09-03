local AddonName = ...;

local function DelvesDifficultyPickerFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function ShowDelvesDifficultyPickerFrame()
	DelvesDifficultyPickerFrame:TryShow();
end

local function RegisterWithPlayerInteractionManager()
	RegisterPlayerInteraction(Enum.PlayerInteractionType.TieredEntrance,
		{
			frame = "DelvesDifficultyPickerFrame",
			loadFunc = DelvesDifficultyPickerFrame_LoadUI,
			showFunc = ShowDelvesDifficultyPickerFrame,
		});
end

RegisterWithPlayerInteractionManager();
