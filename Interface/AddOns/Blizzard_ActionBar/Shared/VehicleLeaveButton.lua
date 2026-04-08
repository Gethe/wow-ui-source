
MainMenuBarVehicleLeaveButtonMixin = {};

function MainMenuBarVehicleLeaveButtonMixin:OnLoad()
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("VEHICLE_UPDATE");
end

function MainMenuBarVehicleLeaveButtonMixin:OnEnter()
	if UnitOnTaxi("player") then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, TAXI_CANCEL);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, LEAVE_VEHICLE);
		GameTooltip:Show();
	end
end

function MainMenuBarVehicleLeaveButtonMixin:OnEvent(event, ...)
	self:Update();
end

function MainMenuBarVehicleLeaveButtonMixin:CanExitVehicle()
	return CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN;
end

function MainMenuBarVehicleLeaveButtonMixin:UpdateShownState()
	self:SetShown(self.isInEditMode or self:CanExitVehicle());
end

function MainMenuBarVehicleLeaveButtonMixin:Update()
	self:UpdateShownState();

	if self:CanExitVehicle() then
		self:Enable();
		if (PetHasActionBar() and PetActionBar ~= nil) then
			PetActionBar:Show();
		end
	else
		self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD");
		self:UnlockHighlight();
		if (PetHasActionBar() and PetActionBar ~= nil) then
			PetActionBar:Show();
		end
	end
end

function MainMenuBarVehicleLeaveButtonMixin:OnClicked()
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding();

		-- Show that the request for landing has been received.
		self:Disable();
		self:SetHighlightTexture([[Interface\Buttons\CheckButtonHilight]], "ADD");
		self:LockHighlight();
	else
		VehicleExit();
	end
end
