MAIN_MENU_BAR_MARGIN = 75;		-- number of art pixels on one side, used by UIParent_ManageFramePositions. It's not the art's full size, don't care about the gryphon's tail.

MainActionBarMixin = {};

function MainActionBarMixin:OnLoad()
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");

	self.state = "player";
	MainActionBar.ActionBarPageNumber.Text:SetText(C_ActionBar.GetActionBarPage());
end

function MainActionBarMixin:OnShow()
	MicroMenu:ResetMicroMenuPosition();
end

function MainActionBarMixin:SetYOffset(yOffset)
	self.yOffset = yOffset;
end

function MainActionBarMixin:GetYOffset()
	return self.yOffset;
end

function MainActionBarMixin:OnEvent(event, ...)
	if ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		MainActionBar.ActionBarPageNumber.Text:SetText(C_ActionBar.GetActionBarPage());
	elseif ( event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		self:UpdateEndCaps();
	end
end

function MainActionBarMixin:AttachToFrame(frame)
	self.attachedFrame = frame;
	if not self.preAttachPoints then
		self.preAttachPoints = RegionUtil.GetPointsArray(self);
		self:ClearAllPoints();
	end

	self:SetParent(frame);
end

function MainActionBarMixin:DetachFromFrame(frame)
	if self.attachedFrame == frame then
		self.attachedFrame = nil;

		self:SetParent(UIParent);
		if self.preAttachPoints then
			RegionUtil.ApplyRegionPoints(self, self.preAttachPoints);
			self.preAttachPoints = nil;
		end
	end
end

function MainActionBarMixin:IsInDefaultPosition()
	return not self.attachedFrame and EditModeSystemMixin.IsInDefaultPosition(self);
end

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

function MainActionBarMixin:SetQuickKeybindModeEffectsShown(showEffects)
	self.QuickKeybindBottomShadow:SetShown(showEffects);
	self.QuickKeybindGlowSmall:SetShown(showEffects);
	self.QuickKeybindGlowLarge:SetShown(showEffects);
	local useRightShadow = MultiBarRight:IsShown();
	self.QuickKeybindRightShadow:SetShown(useRightShadow and showEffects);
end

function MainActionBarMixin:UpdateEndCaps(overrideHideEndCaps)
	self.EndCaps:SetShown(not overrideHideEndCaps);
end

function MainActionBarMixin:EditModeSetScale(newScale)
	if (self.BorderArt) then
		self.BorderArt:SetScale(newScale);
	end

	-- For end caps and page number, only scale down, not up
	self.EndCaps:SetScale(newScale < 1 and newScale or 1);
	self.ActionBarPageNumber:SetScale(newScale < 1 and newScale or 1);
end

function MainActionBarMixin:UpdateDividers()
	if (not self.enableDividers) then
		return;
	end

	if not self.HorizontalDividersPool then
		self.HorizontalDividersPool = CreateFramePool("FRAME", self, "HorizontalDividerTemplate");
		self.VerticalDividersPool = CreateFramePool("FRAME", self, "VerticalDividerTemplate");
	end
	self.HorizontalDividersPool:ReleaseAll();
	self.VerticalDividersPool:ReleaseAll();

	if self.hideBarArt or self.numRows > 1 or self.buttonPadding > self.minButtonPadding then
		return;
	end

	local dividersPool = self.isHorizontal and self.HorizontalDividersPool or self.VerticalDividersPool;
	local wasLastButtonShown = false;
	for i, actionButton in pairs(self.actionButtons) do
		if actionButton:IsShown() then
			if wasLastButtonShown then
				local divider = dividersPool:Acquire();
				divider:ClearAllPoints();
				if self.isHorizontal then
					divider:SetPoint("TOP", actionButton, "TOP", 0, 0);
					divider:SetPoint("BOTTOM", actionButton, "BOTTOM", 0, 0);
					divider:SetPoint("RIGHT", actionButton, "LEFT", 5, 0);
				else
					divider:SetPoint("LEFT", actionButton, "LEFT", 0, 0);
					divider:SetPoint("RIGHT", actionButton, "RIGHT", 0, 0);
					divider:SetPoint("BOTTOM", actionButton, "TOP", 0, -5);
				end
				divider:Show();
			end
			wasLastButtonShown = true;
		else
			wasLastButtonShown = false;
		end
	end
end

function MainActionBarMixin:GetEndCapsFrameLevel()
	return self.EndCaps:GetFrameLevel();
end

MainActionBarUpButtonMixin = {};

function MainActionBarUpButtonMixin:OnClick()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ActionBar_PageUp();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function MainActionBarUpButtonMixin:OnLeave()
	GameTooltip:Hide();
end

MainActionBarDownButtonMixin = {};

function MainActionBarDownButtonMixin:OnClick()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ActionBar_PageDown();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function MainActionBarDownButtonMixin:OnLeave()
	GameTooltip:Hide();
end

-- For arrow buttons that need to swap their textures between two styles.
-- Currently used by Classic.
MainActionBarSwappableButtonMixin = {};

function MainActionBarSwappableButtonMixin:SwapToDefaultAtlas()
	self:SetNormalAtlas(self:GetNormalTexture().defaultAtlas);
	self:SetPushedAtlas(self:GetPushedTexture().defaultAtlas);
	self:SetDisabledAtlas(self:GetDisabledTexture().defaultAtlas);
	self:SetHighlightAtlas(self:GetHighlightTexture().defaultAtlas);
end

function MainActionBarSwappableButtonMixin:SwapToAlternateAtlas()
	self:SetNormalAtlas(self:GetNormalTexture().alternateAtlas);
	self:SetPushedAtlas(self:GetPushedTexture().alternateAtlas);
	self:SetDisabledAtlas(self:GetDisabledTexture().alternateAtlas);
	self:SetHighlightAtlas(self:GetHighlightTexture().alternateAtlas);
end
