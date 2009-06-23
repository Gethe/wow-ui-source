--PET_WARNING_TIME = 55;
--PET_FLASH_ON_TIME = 0.5;
--PET_FLASH_OFF_TIME = 0.5;

function PetFrame_OnLoad (self)
	self.noTextPrefix = true;
	UnitFrame_Initialize(self, "pet", PetName, PetPortrait,
						 PetFrameHealthBar, PetFrameHealthBarText, 
						 PetFrameManaBar, PetFrameManaBarText,
						 PetFrameFlash);

	self.attackModeCounter = 0;
	self.attackModeSign = -1;
	--self.flashState = 1;
	--self.flashTimer = 0;
	CombatFeedback_Initialize(self, PetHitIndicator, 30);
	PetFrame_Update(self);
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_COMBAT");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PET_ATTACK_START");
	self:RegisterEvent("PET_ATTACK_STOP");
	self:RegisterEvent("UNIT_HAPPINESS");
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("PET_RENAMEABLE");
	local showmenu = function()
		ToggleDropDownMenu(1, nil, PetFrameDropDown, "PetFrame", 44, 8);
	end
	SecureUnitButton_OnLoad(self, "pet", showmenu);
	
	local _, class = UnitClass("player");
	if ( class == "DEATHKNIGHT"  or class == "DRUID" ) then	--Death Knights need the Pet frame moved down for their Runes and Druids need it moved down for the secondary power bar.
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -75);
	elseif ( class == "SHAMAN" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -100);
	end
end

function PetFrame_Update (self, override)
	if ( (not PlayerFrame.animating) or (override) ) then
		if ( UnitIsVisible(self.unit) ) then
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

			PetFrame_SetHappiness(self);
			RefreshDebuffs(self, self.unit);
		else
			self:Hide();
		end
	end
end

function PetFrame_OnEvent (self, event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( (event == "UNIT_PET" and arg1 == "player" ) or event == "PET_UI_UPDATE" ) then
		local unit
		if ( UnitInVehicle("player") and UnitHasVehicleUI("player") ) then
			unit = "player";
		else
			unit = "pet";
		end
		UnitFrame_SetUnit(self, unit, PetFrameHealthBar, PetFrameManaBar);
		PetFrame_Update(self);
	elseif ( event == "UNIT_COMBAT" ) then
		if ( arg1 == self.unit ) then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			RefreshDebuffs(self, self.unit);
		end
	elseif ( event == "PET_ATTACK_START" ) then
		PetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		PetAttackModeTexture:Show();
	elseif ( event == "PET_ATTACK_STOP" ) then
		PetAttackModeTexture:Hide();
	elseif ( event == "UNIT_HAPPINESS" ) then
		PetFrame_SetHappiness(self);
	elseif ( event == "PET_RENAMEABLE" ) then
		StaticPopup_Show("RENAME_PET");
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

function PetFrame_SetHappiness ()
	local happiness, damagePercentage = GetPetHappiness();
	local hasPetUI, isHunterPet = HasPetUI();
	if ( not happiness or not isHunterPet ) then
		PetFrameHappiness:Hide();
		return;	
	end
	PetFrameHappiness:Show();
	if ( happiness == 1 ) then
		PetFrameHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
	elseif ( happiness == 2 ) then
		PetFrameHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
	elseif ( happiness == 3 ) then
		PetFrameHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
	end
	PetFrameHappiness.tooltip = _G["PET_HAPPINESS"..happiness];
	PetFrameHappiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
end

function PetFrameDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, PetFrameDropDown_Initialize, "MENU");
end

function PetFrameDropDown_Initialize ()
	if ( UnitExists(PetFrame.unit) ) then
		if ( PetFrame.unit == "player" ) then
			UnitPopup_ShowMenu(PetFrameDropDown, "SELF", "player");
		else
			if ( UnitIsUnit("pet", "vehicle") ) then
				UnitPopup_ShowMenu(PetFrameDropDown, "VEHICLE", "vehicle");
			else
				UnitPopup_ShowMenu(PetFrameDropDown, "PET", "pet");
			end
		end
	end
end

function PetCastingBarFrame_OnLoad (self)
	CastingBarFrame_OnLoad(self, "pet", false, false);

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
