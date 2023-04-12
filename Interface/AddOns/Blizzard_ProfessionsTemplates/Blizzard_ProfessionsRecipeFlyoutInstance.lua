local flyout = CreateFrame("FRAME", nil, nil, "ProfessionsItemFlyoutTemplate");
flyout:Hide();

function CloseProfessionsItemFlyout()
	flyout:ClearAllPoints();
	flyout:Hide();
end

function OpenProfessionsItemFlyout(owner, parent)
	-- Avoiding parenting to a scaled item slot (recraft).
	flyout:ClearHandlers();
	flyout:SetParent(parent);
	flyout:SetPoint("TOPLEFT", owner, "TOPRIGHT", 5, 0);
	flyout:SetFrameStrata("HIGH");
	flyout:Show();
	return flyout;
end

function ToggleProfessionsItemFlyout(owner, parent)
	if flyout:IsShown() then
		CloseProfessionsItemFlyout();
		return nil;
	end

	OpenProfessionsItemFlyout(owner, parent);
	return flyout;
end