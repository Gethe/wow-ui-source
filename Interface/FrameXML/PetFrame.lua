PetFrameMixin = CreateFromMixins(PartyMemberAuraMixin);

function PetFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	self:UpdateMemberAuras(unitAuraUpdateInfo);
end

function PetFrameMixin:OnLoad()
	PetFrameHealthBar.LeftText = PetFrameHealthBarTextLeft;
	PetFrameHealthBar.RightText = PetFrameHealthBarTextRight;
	PetFrameManaBar.LeftText = PetFrameManaBarTextLeft;
	PetFrameManaBar.RightText = PetFrameManaBarTextRight;

	self.DebuffFramePool = CreateFramePool("BUTTON", self.DebuffFrameContainer, "PartyDebuffFrameTemplate");

	UnitFrame_Initialize(self, "pet", PetName, self.frameType, PetPortrait,
						 PetFrameHealthBar, PetFrameHealthBarText,
						 PetFrameManaBar, PetFrameManaBarText,
						 PetFrameFlash, nil, nil,
						 PetFrameMyHealPredictionBar, PetFrameOtherHealPredictionBar,
						 PetFrameTotalAbsorbBar, PetFrameTotalAbsorbBarOverlay,
						 PetFrameOverAbsorbGlow, PetFrameOverHealAbsorbGlow, PetFrameHealAbsorbBar,
						 PetFrameHealAbsorbBarLeftShadow, PetFrameHealAbsorbBarRightShadow);

	self.attackModeCounter = 0;
	self.attackModeSign = -1;

	-- Mask the various bar assets, to avoid any overflow with the frame shape.
	PetFrameHealthBar:GetStatusBarTexture():AddMaskTexture(PetFrameHealthBarMask);
	PetFrameMyHealPredictionBar:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameOtherHealPredictionBar:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameTotalAbsorbBar:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameTotalAbsorbBarOverlay:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameOverAbsorbGlow:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameOverHealAbsorbGlow:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameHealAbsorbBar:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameHealAbsorbBarLeftShadow:AddMaskTexture(PetFrameHealthBarMask);
	PetFrameHealAbsorbBarRightShadow:AddMaskTexture(PetFrameHealthBarMask);

	PetFrameManaBar:GetStatusBarTexture():AddMaskTexture(PetFrameManaBarMask);

	CombatFeedback_Initialize(self, PetHitIndicator, 30);
	self:Update();
	self:RegisterUnitEvent("UNIT_PET", "player");
	self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player");
	self:RegisterEvent("PET_ATTACK_START");
	self:RegisterEvent("PET_ATTACK_STOP");
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterUnitEvent("UNIT_COMBAT", "pet", "player");
	self:RegisterUnitEvent("UNIT_AURA", "pet", "player");
	local showmenu = function()
		ToggleDropDownMenu(1, nil, PetFrameDropDown, "PetFrame", 44, 8);
	end
	SecureUnitButton_OnLoad(self, "pet", showmenu);
end

function PetFrameMixin:Update(override)
	if (not PlayerFrame.animating) or override then
		self:UpdateShownState();

		if self:IsShown() then
			UnitFrame_Update(self);

			if UnitPowerMax(self.unit) == 0 then
				PetFrameManaBarText:Hide();
			end

			PetAttackModeTexture:Hide();

			self:UpdateAuras();
		end
	end
end

function PetFrameMixin:OnEvent(event, ...)
	UnitFrame_OnEvent(self, event, ...);
	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" ) then
		local unit
		if ( UnitInVehicle("player") ) then
			if ( UnitHasVehiclePlayerFrameUI("player") ) then
				unit = "player";
			else
				return;
			end
		else
			unit = "pet";
		end
		UnitFrame_SetUnit(self, unit, PetFrameHealthBar, PetFrameManaBar);
		self:Update();
	elseif event == "UNIT_COMBAT" then
		if arg1 == self.unit then
			CombatFeedback_OnCombatEvent(self, arg2, arg3, arg4, arg5);
		end
	elseif event == "UNIT_AURA" then
		if arg1 == self.unit then
			local unitAuraUpdateInfo = arg2;
			self:UpdateAuras(unitAuraUpdateInfo);
		end
	elseif event == "PET_ATTACK_START" then
		PetAttackModeTexture:SetVertexColor(1.0, 0, 0, 1.0);
		PetAttackModeTexture:Show();
	elseif event == "PET_ATTACK_STOP" then
		PetAttackModeTexture:Hide();
	end
end

function PetFrameMixin:OnShow()
	UnitFrame_Update(self);
	self:Update();
	TotemFrame:Update();
	UIParentManagedFrameMixin.OnShow(self);
end

function PetFrameMixin:OnHide()
	TotemFrame:Update();
	UIParentManagedFrameMixin.OnHide(self);
end

function PetFrameMixin:OnUpdate(elapsed)
	if PetAttackModeTexture:IsShown() then
		local alpha = 255;
		local counter = self.attackModeCounter + elapsed;
		local sign    = self.attackModeSign;

		if counter > 0.5 then
			sign = -sign;
			self.attackModeSign = sign;
		end
		counter = mod(counter, 0.5);
		self.attackModeCounter = counter;

		if sign == 1 then
			alpha = (55  + (counter * 400)) / 255;
		else
			alpha = (255 - (counter * 400)) / 255;
		end
		PetAttackModeTexture:SetVertexColor(1.0, 0, 0, alpha);
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

PetFrameDropDownMixin = {};

function PetFrameDropDownMixin:OnLoad()
	UIDropDownMenu_Initialize(self, self.Initialize, "MENU");
end

function PetFrameDropDownMixin:Initialize()
	if UnitExists(PetFrame.unit) then
		if PetFrame.unit == "player" then
			UnitPopup_ShowMenu(PetFrameDropDown, "SELF", "player");
		else
			if UnitIsUnit("pet", "vehicle") then
				UnitPopup_ShowMenu(PetFrameDropDown, "VEHICLE", "vehicle");
			else
				UnitPopup_ShowMenu(PetFrameDropDown, "PET", "pet");
			end
		end
	end
end

PetCastingBarMixin = CreateFromMixins(CastingBarMixin);

function PetCastingBarMixin:PetCastingBar_OnLoad()
	CastingBarMixin.OnLoad(self, "pet", false, false);

	self:RegisterEvent("UNIT_PET");

	self.showCastbar = UnitIsPossessed("pet");
end

function PetCastingBarMixin:PetCastingBar_OnEvent(event, ...)
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

PetManaBarMixin = {};

function PetManaBarMixin:OnLoad()
	TextStatusBar_Initialize(self);
	self.textLockable = 1;
	self.lockColor = true;
	self.cvar = "statusText";
	self.cvarLabel = "STATUS_TEXT_PET";
end

PetHealthBarMixin = {};

function PetHealthBarMixin:OnLoad()
	TextStatusBar_Initialize(self);
	self.textLockable = 1;
	self.lockColor = true;
	self.cvar = "statusText";
	self.cvarLabel = "STATUS_TEXT_PET";
end

function PetHealthBarMixin:OnSizeChanged()
	UnitFrameHealPredictionBars_UpdateSize(self:GetParent());
end