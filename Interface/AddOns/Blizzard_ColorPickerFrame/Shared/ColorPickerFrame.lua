function OpacityFrame_EscapePressed()
    if OpacityFrame:IsShown() then
		OpacityFrame:Hide();
		return true;
	end

	return false;
end

RegisterGameMenuEscHandler(GameMenuEscPriority.FrameworkPre, OpacityFrame_EscapePressed);
