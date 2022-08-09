local flyout = CreateFrame("FRAME", nil, nil, "ProfessionsItemFlyoutTemplate");
flyout:Hide();

function CloseItemFlyout()
	flyout:ClearAllPoints();
	flyout:Hide();
end

function OpenItemFlyout(owner)
	-- Avoiding parenting to a scaled item slot (recraft).
	flyout:SetParent(ProfessionsFrame);
	flyout:SetPoint("TOPLEFT", owner, "TOPRIGHT", 5, 0);
	flyout:SetFrameStrata("HIGH");
	flyout:Show();
	return flyout;
end

function ToggleProfessionsItemFlyout(owner)
	if flyout:IsShown() then
		CloseItemFlyout();
		return nil;
	end

	OpenItemFlyout(owner);
	return flyout;
end