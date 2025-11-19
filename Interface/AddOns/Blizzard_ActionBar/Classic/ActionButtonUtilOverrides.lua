
function ActionButtonUtil.SetAllQuickKeybindButtonHighlights(show)
	for _, actionBar in ipairs(ActionButtonUtil.ActionBarButtonNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			_G[actionBar..i]:DoModeChange(show);
		end
	end
	for i = 1, NUM_SPECIAL_BUTTONS do
		PetActionBar.actionButtons[i]:DoModeChange(show);
		StanceBar.actionButtons[i]:DoModeChange(show);
	end
	ExtraActionButton1:DoModeChange(show);
	MainActionBar.ActionBarPageNumber.UpButton:DoModeChange(show);
	MainActionBar.ActionBarPageNumber.DownButton:DoModeChange(show);
end
