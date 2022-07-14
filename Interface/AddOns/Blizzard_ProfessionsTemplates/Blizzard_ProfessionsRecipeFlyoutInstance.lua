local flyout = CreateFrame("FRAME", nil, nil, "ProfessionsItemFlyoutTemplate");
flyout:Hide();

function CloseItemFlyout()
	flyout:SetParent(nil);
	flyout:ClearAllPoints();
	flyout:Hide();
end

function OpenItemFlyout(owner)
	flyout:SetParent(owner);
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