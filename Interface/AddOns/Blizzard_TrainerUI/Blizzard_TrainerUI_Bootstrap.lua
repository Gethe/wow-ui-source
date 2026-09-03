local AddonName = ...;

function ClassTrainerFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function ClassTrainerFrame_Show()
	if ClassTrainerFrame_LoadUI() then
		ShowUIPanel(ClassTrainerFrame);
		if ( not ClassTrainerFrame:IsVisible() ) then
			CloseTrainer();
			return;
		end
	end
end

local function ClassTrainerFrame_Hide()
	if ClassTrainerFrame then
		HideUIPanel(ClassTrainerFrame);
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "ClassTrainerFrame",
		loadFunc = ClassTrainerFrame_LoadUI,
		showFunc = ClassTrainerFrame_Show,
		hideFunc = ClassTrainerFrame_Hide,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.Trainer, frameInfo);
end

RegisterWithPlayerInteractionManager();
