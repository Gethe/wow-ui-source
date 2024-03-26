function GameMenuFrame_OnShow(self)
	UpdateMicroButtons();
	if (CanAutoSetGamePadCursorControl(true)) then
		SetGamePadCursorControl(true);
	end

	GameMenuFrame_UpdateVisibleButtons(self);
	C_AddOns.LoadAddOn("Blizzard_PlunderstormBasics");
	PlunderstormBasicsContainerFrame:SetParent(self);
	PlunderstormBasicsContainerFrame:SetBottomFrame(MainMenuMicroButton);
end

function GameMenuFrame_UpdateVisibleButtons(self)
	local height = 170;

	local previousButton = GameMenuButtonSettings;
	if ( IsTestBuild() and (C_AddOns.GetNumAddOns() > 0) ) then
		height = height + 20;
		GameMenuButtonAddons:Show();
		previousButton = GameMenuButtonAddons;
	else
		GameMenuButtonAddons:Hide();
	end

	if ( GameMenuButtonRatings:IsShown() ) then
		height = height + 20;
		GameMenuButtonRatings:SetPoint("TOP", previousButton, "BOTTOM", 0, -1);
		previousButton = GameMenuButtonRatings;
	end

	GameMenuButtonLogout:SetPoint("TOP", previousButton, "BOTTOM", 0, -16);

	self:SetHeight(height);
end

function GameMenuFrame_LeaveMatch()
	LeaveMatchUtil_LeaveMatchPopup();
end