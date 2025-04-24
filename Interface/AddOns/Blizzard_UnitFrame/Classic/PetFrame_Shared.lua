--PET_WARNING_TIME = 55;
--PET_FLASH_ON_TIME = 0.5;
--PET_FLASH_OFF_TIME = 0.5;

--Note: PetFrame_SetHappiness() is defined in expansion-specific lua files

function PetFrame_OnLoad (self)
	self.noTextPrefix = true;

	PetFrameHealthBar.LeftText = PetFrameHealthBarTextLeft;
	PetFrameHealthBar.RightText = PetFrameHealthBarTextRight;
	PetFrameManaBar.LeftText = PetFrameManaBarTextLeft;
	PetFrameManaBar.RightText = PetFrameManaBarTextRight;

	UnitFrame_Initialize(self, "pet", PetName, PetPortrait,
						 PetFrameHealthBar, PetFrameHealthBarText, 
						 PetFrameManaBar, PetFrameManaBarText,
						 PetFrameFlash, nil, nil,
						 PetFrameMyHealPredictionBar, PetFrameOtherHealPredictionBar,
						 PetFrameTotalAbsorbBar, PetFrameTotalAbsorbBarOverlay, 
						 PetFrameOverAbsorbGlow, PetFrameOverHealAbsorbGlow, PetFrameHealAbsorbBar,
						 PetFrameHealAbsorbBarLeftShadow, PetFrameHealAbsorbBarRightShadow);
	self.attackModeCounter = 0;
	self.attackModeSign = -1;
	--self.flashState = 1;
	--self.flashTimer = 0;
	CombatFeedback_Initialize(self, PetHitIndicator, 30);
	PetFrame_Update(self);
	self:RegisterUnitEvent("UNIT_PET", "player");
	self:RegisterEvent("PET_ATTACK_START");
	self:RegisterEvent("PET_ATTACK_STOP");
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("UNIT_HAPPINESS");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterUnitEvent("UNIT_COMBAT", "pet", "player");
	self:RegisterUnitEvent("UNIT_AURA", "pet", "player");

	local function OpenContextMenu(frame, unit, button, isKeyPress)
		if UnitExists(self.unit) then
			local which = nil;
			local contextData = {};
			if self.unit == "player" then
				which = "SELF";
				contextData.unit = "player";
			elseif UnitIsUnit("pet", "vehicle") then
				which = "VEHICLE";
				contextData.unit = "vehicle";
			else
				which = "PET";
				contextData.unit = "pet";
			end
			UnitPopup_OpenMenu(which, contextData);
		end
	end

	SecureUnitButton_OnLoad(self, "pet", OpenContextMenu);

	if( PetFrame_AdjustPoint ) then
		PetFrame_AdjustPoint(self);
	end
end

function PetFrame_Update (self, override)
	if ( (not PlayerFrame.animating) or (override) ) then
		if ( UnitIsVisible(self.unit) and PetUsesPetFrame() and not PlayerFrame.vehicleHidesPet ) then
			if ( self:IsShown() ) then
				UnitFrame_Update(self);
			else
				self:Show();
			end
			--self.flashState = 1;
			--self.flashTimer = PET_FLASH_ON_TIME;
			if ( UnitPowerMax(self.unit) == 0 ) then
				PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame-NoMana");
				PetFrameManaBarText:Hide();
			else
				PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame");
			end
			PetAttackModeTexture:Hide();

			PetFrame_SetHappiness();
			RefreshBuffsOrDebuffs(self, self.unit, nil, nil, true);
		else
			self:Hide();
		end
	end
end

function PetFrame_OnEvent (self, event, ...)
	UnitFrame_OnEvent(self, event, ...);
	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" ) then
		UnitFrame_SetUnit(self, "pet", PetFrameHealthBar, PetFrameManaBar);
		PetFrame_Update(self);
	elseif ( event == "UNIT_COMBAT" ) then
		if ( arg1 == self.unit ) then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			RefreshBuffsOrDebuffs(self, self.unit, nil, nil, true);
		end
	elseif ( event == "PET_ATTACK_START" ) then
		PetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		PetAttackModeTexture:Show();
	elseif ( event == "PET_ATTACK_STOP" ) then
		PetAttackModeTexture:Hide();
	elseif (event == "UNIT_HAPPINESS" ) then
		PetFrame_SetHappiness();
	elseif (event == "UNIT_MAXPOWER" ) then
		PetFrame_Update(self);
	end
end

function PetFrame_OnUpdate (self, elapsed)
	if ( PetAttackModeTexture:IsShown() ) then
		local alpha = 255;
		local counter = self.attackModeCounter + elapsed;
		local sign    = self.attackModeSign;

		if ( counter > 0.5 ) then
			sign = -sign;
			self.attackModeSign = sign;
		end
		counter = mod(counter, 0.5);
		self.attackModeCounter = counter;

		if ( sign == 1 ) then
			alpha = (55  + (counter * 400)) / 255;
		else
			alpha = (255 - (counter * 400)) / 255;
		end
		PetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, alpha);
	end
	CombatFeedback_OnUpdate(self, elapsed);
	-- Expiration flash stuff
	--local petTimeRemaining = nil;
	--if ( GetPetTimeRemaining() ) then
	---	if ( self.flashState == 1 ) then
	--		self:SetAlpha(this.flashTimer/PET_FLASH_ON_TIME);
	--	else
	--		self:SetAlpha((PET_FLASH_OFF_TIME - this.flashTimer)/PET_FLASH_OFF_TIME);
	--	end
	--	petTimeRemaining = GetPetTimeRemaining() / 1000;
	--end
	--if ( petTimeRemaining and (petTimeRemaining < PET_WARNING_TIME) ) then
	--	PetFrame.flashTimer = PetFrame.flashTimer - elapsed;
	--	if ( PetFrame.flashTimer <= 0 ) then
	--		if ( PetFrame.flashState == 1 ) then
	--			PetFrame.flashState = 0;
	--			PetFrame.flashTimer = PET_FLASH_OFF_TIME;
	--		else
	--			PetFrame.flashState = 1;
	--			PetFrame.flashTimer = PET_FLASH_ON_TIME;
	--		end
	--	end
	--end
	
end

function PetCastingBarFrame_OnLoad (self)
	CastingBarFrame_OnLoad(self, "pet", false, false);
	self.Icon:Hide();

	self:RegisterEvent("UNIT_PET");

	self.showCastbar = UnitIsPossessed("pet");
end

function PetCastingBarFrame_OnEvent (self, event, ...)
	local arg1 = ...;
	if ( event == "UNIT_PET" ) then
		if ( arg1 == "player" ) then
			self.showCastbar = UnitIsPossessed("pet");

			if ( not self.showCastbar ) then
				self:Hide();
			elseif ( self.casting or self.channeling ) then
				self:Show();
			end
		end
		return;
	end
	CastingBarFrame_OnEvent(self, event, ...);
end
