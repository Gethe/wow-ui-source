PETACTIONBAR_SLIDETIME = 0.09;
PETACTIONBAR_YPOS = 98;
PETACTIONBAR_XPOS = 36;
NUM_PET_ACTION_SLOTS = 10;

PET_DEFENSIVE_TEXTURE = "Interface\\Icons\\Ability_Defend";
PET_AGGRESSIVE_TEXTURE = "Interface\\Icons\\Ability_Racial_BloodRage";
PET_PASSIVE_TEXTURE = "Interface\\Icons\\Ability_Seal";
PET_ATTACK_TEXTURE = "Interface\\Icons\\Ability_GhoulFrenzy";
PET_FOLLOW_TEXTURE = "Interface\\Icons\\Ability_Tracking";
PET_WAIT_TEXTURE = "Interface\\Icons\\Spell_Nature_TimeStop";
PET_DISMISS_TEXTURE = "Interface\\Icons\\Spell_Shadow_Teleport";

function PetActionBar_OnLoad (self)
	self:RegisterEvent("PLAYER_CONTROL_LOST");
	self:RegisterEvent("PLAYER_CONTROL_GAINED");
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN");
	self:RegisterEvent("PET_BAR_SHOWGRID");
	self:RegisterEvent("PET_BAR_HIDEGRID");
	self:RegisterEvent("PET_BAR_HIDE");
	self:RegisterEvent("PET_BAR_UPDATE_USABLE");
	self.showgrid = 0;
	PetActionBar_Update(self);
	if ( PetHasActionBar() ) then
		ShowPetActionBar();
		LockPetActionBar();
	end
end

function PetActionBar_OnEvent (self, event, ...)
	local arg1 = ...;
	
	if ( event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") ) then
		PetActionBar_Update(self);
		if ( PetHasActionBar() and UnitIsVisible("pet") ) then
			ShowPetActionBar();
			LockPetActionBar();
		else
			UnlockPetActionBar();
			HidePetActionBar();
		end
	elseif ( event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or event == "PET_BAR_UPDATE_USABLE" ) then
		PetActionBar_Update(self);
	elseif ( (event == "UNIT_FLAGS") or (event == "UNIT_AURA") ) then
		if ( arg1 == "pet" ) then
			PetActionBar_Update(self);
		end
	elseif ( event =="PET_BAR_UPDATE_COOLDOWN" ) then
		PetActionBar_UpdateCooldowns();
	elseif ( event =="PET_BAR_SHOWGRID" ) then
		PetActionBar_ShowGrid();
	elseif ( event =="PET_BAR_HIDEGRID" ) then
		PetActionBar_HideGrid();
	elseif ( event =="PET_BAR_HIDE" ) then
		HidePetActionBar();
	end
end

function PetActionBarFrame_IsAboveShapeshift(ignoreShowing)
	return ( ((ShapeshiftBarFrame and GetNumShapeshiftForms() > 0) or (MultiCastActionBarFrame and HasMultiCastActionBar()) or
		(MainMenuBarVehicleLeaveButton and MainMenuBarVehicleLeaveButton:IsShown())) and
		(not MultiBarBottomLeft:IsShown() and MultiBarBottomRight:IsShown()) and
		(ignoreShowing or (PetActionBarFrame and PetActionBarFrame:IsShown())))
end

function PetActionBarFrame_OnUpdate(self, elapsed)
	local yPos;
	if ( self.slideTimer and (self.slideTimer < self.timeToSlide) ) then
		self.completed = nil;
		if ( self.mode == "show" ) then
			yPos = (self.slideTimer/self.timeToSlide) * PETACTIONBAR_YPOS;
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, yPos);
			self.state = "showing";
			self:Show();
		elseif ( self.mode == "hide" ) then
			yPos = (1 - (self.slideTimer/self.timeToSlide)) * PETACTIONBAR_YPOS;
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, yPos);
			self.state = "hiding";
		end
		self.slideTimer = self.slideTimer + elapsed;
	else
		self.completed = 1;
		if ( self.mode == "show" ) then
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, PETACTIONBAR_YPOS);
			self.state = "top";
			--Move the chat frame and edit box up a bit
		elseif ( self.mode == "hide" ) then
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, 0);
			self.state = "bottom";
			self:Hide();
			--Move the chat frame and edit box back down to original position
		end
		self.mode = "none";
	end
end

function PetActionBar_Update (self)
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine;
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton" .. i;
		petActionButton = _G[buttonName];
		petActionIcon = _G[buttonName.."Icon"];
		petAutoCastableTexture = _G[buttonName.."AutoCastable"];
		petAutoCastShine = _G[buttonName.."Shine"];
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
		if ( not isToken ) then
			petActionIcon:SetTexture(texture);
			petActionButton.tooltipName = name;
		else
			petActionIcon:SetTexture(_G[texture]);
			petActionButton.tooltipName = _G[name];
		end
		petActionButton.isToken = isToken;
		petActionButton.tooltipSubtext = subtext;
		if ( isActive ) then
			if ( IsPetAttackAction(i) ) then
				PetActionButton_StartFlash(petActionButton);
				-- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
				petActionButton:GetCheckedTexture():SetAlpha(0.5);
			else
				petActionButton:GetCheckedTexture():SetAlpha(1.0);
			end
			petActionButton:SetChecked(1);
		else
			if ( IsPetAttackAction(i) ) then
				PetActionButton_StopFlash(petActionButton);
			end
			petActionButton:SetChecked(0);
		end
		if ( autoCastAllowed ) then
			petAutoCastableTexture:Show();
		else
			petAutoCastableTexture:Hide();
		end
		if ( autoCastEnabled ) then
			AutoCastShine_AutoCastStart(petAutoCastShine);
		else
			AutoCastShine_AutoCastStop(petAutoCastShine);
		end
		if ( name ) then
			petActionButton:Show();
		else
			if ( PetActionBarFrame.showgrid == 0 ) then
				petActionButton:Hide();
			end
		end
		if ( texture ) then
			if ( GetPetActionSlotUsable(i) ) then
				SetDesaturation(petActionIcon, nil);
			else
				SetDesaturation(petActionIcon, 1);
			end
			petActionIcon:Show();
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		else
			petActionIcon:Hide();
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		end
	end
	PetActionBar_UpdateCooldowns();
	if ( not PetHasActionBar() ) then
		--ControlReleased();
		HidePetActionBar();
	end
end

function PetActionBar_UpdateCooldowns()
	local cooldown;
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		cooldown = _G["PetActionButton"..i.."Cooldown"];
		local start, duration, enable = GetPetActionCooldown(i);
		CooldownFrame_SetTimer(cooldown, start, duration, enable);
	end
end

function PetActionBar_UpdatePositionValues()
	if ( PetActionBarFrame_IsAboveShapeshift(true) ) then
		PETACTIONBAR_XPOS = 36;
	elseif ( MainMenuBarVehicleLeaveButton and MainMenuBarVehicleLeaveButton:IsShown() ) then
		PETACTIONBAR_XPOS = MainMenuBarVehicleLeaveButton:GetRight() + 20;
	elseif ( ShapeshiftBarFrame and GetNumShapeshiftForms() > 0 ) then
		PETACTIONBAR_XPOS = _G["ShapeshiftButton"..GetNumShapeshiftForms()]:GetRight() + 20;
	elseif ( MultiCastActionBarFrame and HasMultiCastActionBar() ) then
		PETACTIONBAR_XPOS = MultiCastActionBarFrame:GetRight() + 20;
	else
		PETACTIONBAR_XPOS = 36;
	end
end

function ShowPetActionBar(doNotSlide)
	if ( PetHasActionBar() and PetActionBarFrame.showgrid == 0 and (PetActionBarFrame.mode ~= "show") and (not PetActionBarFrame.locked or doNotSlide) and not PetActionBarFrame.ctrlPressed ) then
		PetActionBar_UpdatePositionValues();
		if ( MainMenuBar.busy or UnitHasVehicleUI("player") or doNotSlide ) then
			PetActionBarFrame:SetPoint("TOPLEFT", PetActionBarFrame:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, PETACTIONBAR_YPOS);
			PetActionBarFrame.state = "top";
			PetActionBarFrame:Show();
		else
			PetActionBarFrame:Show();
			if ( PetActionBarFrame.completed ) then
				PetActionBarFrame.slideTimer = 0;
			end
			PetActionBarFrame.timeToSlide = PETACTIONBAR_SLIDETIME;
			PetActionBarFrame.mode = "show";
		end
		UIParent_ManageFramePositions();
	end
end

function HidePetActionBar()
	if ( PetActionBarFrame.showgrid == 0 and PetActionBarFrame:IsShown() and not PetActionBarFrame.locked and not PetActionBarFrame.ctrlPressed ) then
		if ( MainMenuBar.busy or UnitHasVehicleUI("player") ) then
			PetActionBarFrame:SetPoint("TOPLEFT", PetActionBarFrame:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, 0);
			PetActionBarFrame.state = "bottom";
			PetActionBarFrame:Hide();
		else
			if ( PetActionBarFrame.completed ) then
				PetActionBarFrame.slideTimer = 0;
			end
			PetActionBarFrame.timeToSlide = PETACTIONBAR_SLIDETIME;
			PetActionBarFrame.mode = "hide";
		end
	end
end

function PetActionBar_ShowGrid()
	ShowPetActionBar();
	PetActionBarFrame.showgrid = PetActionBarFrame.showgrid + 1;
	for i=1, NUM_PET_ACTION_SLOTS do
		_G["PetActionButton"..i]:Show();
	end
end

function PetActionBar_HideGrid()
	if ( PetActionBarFrame.showgrid > 0 ) then
		PetActionBarFrame.showgrid = PetActionBarFrame.showgrid - 1;
	end
	if ( PetActionBarFrame.showgrid == 0 ) then
		HidePetActionBar();
		local name;
		for i=1, NUM_PET_ACTION_SLOTS, 1 do
			name = GetPetActionInfo(i);
			if ( not name ) then
				_G["PetActionButton"..i]:Hide();
			end
		end
	end
end

function PetActionButtonDown(id)
	local button = _G["PetActionButton"..id];
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function PetActionButtonUp (id)
	local button = _G["PetActionButton"..id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		CastPetAction(id);
	end
end

function PetActionButton_OnLoad (self)
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	_G[self:GetName().."Cooldown"]:ClearAllPoints();
	_G[self:GetName().."Cooldown"]:SetWidth(33);
	_G[self:GetName().."Cooldown"]:SetHeight(33);
	_G[self:GetName().."Cooldown"]:SetPoint("CENTER", self, "CENTER", -2, -1);
	PetActionButton_SetHotkeys(self);
end

function PetActionButton_OnEvent (self, event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		PetActionButton_SetHotkeys(self);
		return;
	end
end

function PetActionButton_OnClick (self, button)
	if ( button == "LeftButton" ) then
		CastPetAction(self:GetID());
	else
		TogglePetAutocast(self:GetID());
	end
end

function PetActionButton_OnModifiedClick (self, button)
	if ( IsModifiedClick("PICKUPACTION") ) then
		PickupPetAction(self:GetID());
		return;
	end
end

function PetActionButton_OnDragStart (self)
	if ( LOCK_ACTIONBAR ~= "1" ) then
		self:SetChecked(0);
		PickupPetAction(self:GetID());
		PetActionBar_Update();
	end
end

function PetActionButton_OnReceiveDrag (self)
	if ( LOCK_ACTIONBAR ~= "1" ) then
		self:SetChecked(0);
		PickupPetAction(self:GetID());
		PetActionBar_Update();
	end
end

function PetActionButton_OnEnter (self)
	if ( not self.tooltipName ) then
		return;
	end
	local uber = GetCVar("UberTooltips");
	if ( self.isToken or (uber == "0") ) then
		if ( uber == "0" ) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		else
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
		end
		GameTooltip:SetText(self.tooltipName..NORMAL_FONT_COLOR_CODE.." ("..GetBindingText(GetBindingKey("BONUSACTIONBUTTON"..self:GetID()), "KEY_")..")"..FONT_COLOR_CODE_CLOSE, 1.0, 1.0, 1.0);
		if ( self.tooltipSubtext ) then
			GameTooltip:AddLine(self.tooltipSubtext, "", 0.5, 0.5, 0.5);
		end
		GameTooltip:Show();
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetPetAction(self:GetID());
	end
end

function PetActionButton_OnLeave ()
	GameTooltip:Hide();
end

function PetActionButton_OnUpdate (self, elapsed)
	if ( PetActionButton_IsFlashing(self) ) then
		local flashtime = self.flashtime;
		flashtime = flashtime - elapsed;

		if ( flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = _G[self:GetName().."Flash"];
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
		
		self.flashtime = flashtime;
	end
end

function PetActionButton_StartFlash (self)
	self.flashing = true;
	self.flashtime = 0;
end

function PetActionButton_StopFlash (self)
	self.flashing = false;
	_G[self:GetName().."Flash"]:Hide();
end

function PetActionButton_IsFlashing (self)
	return self.flashing;
end

function PetActionButton_SetHotkeys (self)
	local binding = GetBindingText(GetBindingKey("BONUSACTIONBUTTON"..self:GetID()), 1);
	local bindingSuffix = gsub(binding, ".*%-", "");
	local hotkey = _G[self:GetName().."HotKey"];
	if ( bindingSuffix == self:GetID() ) then
		hotkey:SetText(self:GetID());
	else
		hotkey:SetText("");
	end
end

function LockPetActionBar()
	PetActionBarFrame.locked = 1;
end

function UnlockPetActionBar()
	PetActionBarFrame.locked = nil;
end
