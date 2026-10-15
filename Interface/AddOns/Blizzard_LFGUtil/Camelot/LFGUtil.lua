function SetLookingForGroupUIAvailable(available)
	if C_LFGList.GetPremadeGroupFinderStyle() == Enum.PremadeGroupFinderStyle.Vanilla then
		if available then
			GroupFinderVanillaStyle_LoadUI();
		end
		return;
	end

	if available then
		LFDMicroButton:Show();
	else
		LFDMicroButton:Hide();
	end
end
