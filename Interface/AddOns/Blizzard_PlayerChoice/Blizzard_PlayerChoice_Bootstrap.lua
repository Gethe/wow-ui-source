local AddonName = ...;

function PlayerChoice_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local toggleButtons = nil;

local function FillToggleButtonsIfNeeded()
	if toggleButtons == nil then
		toggleButtons =
		{
			TorghastPlayerChoiceToggleButton,
			CypherPlayerChoiceToggleButton,
			GenericPlayerChoiceToggleButton,
		};
	end
end

function PlayerChoiceFrame_TryShow()
	if PlayerChoice_LoadUI() then
		PlayerChoiceFrame:TryShow();
	end
end

function PlayerChoiceToggle_TryShow()
	if not PlayerChoice_LoadUI() then
		return;
	end

	FillToggleButtonsIfNeeded();

	for _, button in pairs(toggleButtons) do
		if button:ShouldShow() then
			button:UpdateButtonState();
			button:Show();
		else
			button:Hide();
		end
	end
end

function ShowPendingPlayerChoiceResponseUI()
	PlayerChoiceFrame_TryShow();
	PlayerChoiceToggle_TryShow();
	if PlayerChoiceTimeRemaining then
		PlayerChoiceTimeRemaining:TryShow();
	end
end
