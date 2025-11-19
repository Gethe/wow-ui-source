
PetFrameMixin = CreateFromMixins(PartyMemberAuraMixin);

function PetFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	self:UpdateMemberAuras(unitAuraUpdateInfo);
end

function PetFrameMixin:OnLoad()
	self.noTextPrefix = true;

	PetFrameHealthBar.LeftText = PetFrameHealthBarTextLeft;
	PetFrameHealthBar.RightText = PetFrameHealthBarTextRight;
	PetFrameManaBar.LeftText = PetFrameManaBarTextLeft;
	PetFrameManaBar.RightText = PetFrameManaBarTextRight;

	self.AuraFramePool = CreateFramePool("BUTTON", self.AuraFrameContainer, "PartyAuraFrameTemplate");

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

	CombatFeedback_Initialize(self, PetHitIndicator, 30);
	self:Update();
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
end

function PetFrameMixin:Update(override)
	if ( (not PlayerFrame.animating) or (override) ) then
		self:UpdateShownState();

		if self:IsShown() then
			if ( UnitPowerMax(self.unit) == 0 ) then
				PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame-NoMana");
				PetFrameManaBarText:Hide();
			else
				PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame");
			end
			PetAttackModeTexture:Hide();

			self:SetHappiness();
			self:UpdateAuras();
		end
	end
end

function PetFrameMixin:OnEvent(event, ...)
	UnitFrame_OnEvent(self, event, ...);
	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" ) then
		UnitFrame_SetUnit(self, "pet", PetFrameHealthBar, PetFrameManaBar);
		self:Update(self);
	elseif ( event == "UNIT_COMBAT" ) then
		if ( arg1 == self.unit ) then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			local unitAuraUpdateInfo = arg2;
			self:UpdateAuras(unitAuraUpdateInfo);
		end
	elseif ( event == "PET_ATTACK_START" ) then
		PetAttackModeTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		PetAttackModeTexture:Show();
	elseif ( event == "PET_ATTACK_STOP" ) then
		PetAttackModeTexture:Hide();
	elseif (event == "UNIT_HAPPINESS" ) then
		self:SetHappiness();
	elseif (event == "UNIT_MAXPOWER" ) then
		self:Update(self);
	end
end

function PetFrameMixin:OnShow()
	UnitFrame_Update(self);
	self:Update();
	if (TotemFrame) then
		TotemFrame:Update();
	else
		-- If we have a TotemFrame, it should call this for us.
		PlayerFrame_AdjustAttachments();
	end
	UIParentManagedFrameMixin.OnShow(self);
end

function PetFrameMixin:OnHide()
	if (TotemFrame) then
		TotemFrame:Update();
	else
		-- If we have a TotemFrame, it should call this for us.
		PlayerFrame_AdjustAttachments();
	end
	UIParentManagedFrameMixin.OnHide(self);
end

function PetFrameMixin:OnUpdate(elapsed)
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
end

function PetFrameMixin:OnEnter()
	UnitFrame_OnEnter(self);
	PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "TOPLEFT", 60, -35);
	PartyMemberBuffTooltip:UpdateTooltip(self);
end

function PetFrameMixin:OnLeave()
	UnitFrame_OnLeave(self);
	PartyMemberBuffTooltip:Hide();
end

function PetFrameMixin:UpdateShownState()
	self:SetShown(self.isInEditMode
		or (UnitIsVisible(self.unit) and PetUsesPetFrame() and not PlayerFrame.vehicleHidesPet));
end

function PetFrameMixin:SetHappiness()
	local happiness, damagePercentage, loyaltyRate = GetPetHappiness();
	local hasPetUI, isHunterPet = HasPetUI();
	if ( not happiness or not isHunterPet ) then
		-- If Pet Happiness is disabled (e.g., Cata+), then happiness should be nil and we'll hide the frame.
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

	-- If Pet Loyalty is disabled (e.g., Wrath+), then loyaltyRate should be 0 and we'll hide the tooltip.
	if ( loyaltyRate < 0 ) then
		PetFrameHappiness.tooltipLoyalty = _G["LOSING_LOYALTY"];
	elseif ( loyaltyRate > 0 ) then
		PetFrameHappiness.tooltipLoyalty = _G["GAINING_LOYALTY"];
	else
		PetFrameHappiness.tooltipLoyalty = nil;
	end
end

PetCastingBarMixin = CreateFromMixins();

function PetCastingBarMixin:OnLoad()
	CastingBarMixin.OnLoad(self, "pet", false, false);
	self.Icon:Hide();

	self:RegisterEvent("UNIT_PET");

	self.showCastbar = UnitIsPossessed("pet");
end

function PetCastingBarMixin:OnEvent(event, ...)
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
	CastingBarMixin.OnEvent(self, event, ...);
end
