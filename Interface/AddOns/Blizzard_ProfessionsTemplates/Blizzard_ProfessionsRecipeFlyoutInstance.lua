local flyout = CreateFrame("FRAME", nil, nil, "ProfessionsFlyoutTemplate");

function IsProfessionsItemFlyoutOpen()
	return flyout:IsShown();
end

function CloseProfessionsItemFlyout()
	flyout:ClearAllPoints();
	flyout:Hide();
end

function OpenProfessionsItemFlyout(anchorTo, owner, behavior)
	assert(anchorTo);
	behavior:SetFlyout(flyout);

	-- Avoiding parenting to a scaled item slot (recraft).
	flyout:SetParent(owner);
	flyout:SetPoint("TOPLEFT", anchorTo, "TOPRIGHT", 5, 0);
	flyout:SetFrameStrata("HIGH");
	flyout:Show();

	flyout:Init(owner, behavior);

	return flyout;
end
