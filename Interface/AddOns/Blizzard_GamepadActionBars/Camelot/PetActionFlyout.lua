GamepadPetActionFlyoutMixin = {};

-- Overrides GamepadFlyoutMixin.OnLoad
function GamepadPetActionFlyoutMixin:OnLoad()
	GamepadFlyoutMixin.OnLoad(self);

	self.buttonFromAction = {};

	for _, button in ipairs(self.buttons) do
		self.buttonFromAction[button.actionType] = button;
	end
end

-- Overrides GamepadFlyoutMixin.AttachToButton
function GamepadPetActionFlyoutMixin:AttachToButton(button)
	self:UpdateButtons();
	self:UpdateLayout(button);

	GamepadFlyoutMixin.AttachToButton(self, button);
end

function GamepadPetActionFlyoutMixin:UpdateButtons()
	for _, button in ipairs(self.buttons) do
		button:Hide();
	end

	for i=1, NUM_PET_ACTION_SLOTS do
		local name, texture, isToken = GetPetActionInfo(i);
		if isToken then
			local button = self.buttonFromAction[name];
			if button then
				button.icon:SetTexture(_G[texture]);
				button.icon:Show();
				button:SetPetActionID(i);
				button:Show();
			end
		end
	end
end

---------------------------------------------------------------------------------------------------

local PetActionFlyoutButtonMixin = {};

function PetActionFlyoutButtonMixin:Init()
	self.SpecialActionIcon:Show();

	-- Script methods are resolved when the frame is loaded. Since this is mixed in after load,
	-- simply overriding `OnEvent` won't actually replace the event handler work. Instead it has to
	-- be re-assigned.
	self:SetScript("OnEvent", self.OnEvent);
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterUnitEvent("UNIT_FLAGS", "pet");
	self:RegisterUnitEvent("UNIT_PET", "player");
	self:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "pet");

	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnHide", self.OnHide);
	self:SetScript("OnClick", self.OnClick);

	self:UpdateIcon();
	self:SetShown(self:HasAvailablePetActions());
end

function PetActionFlyoutButtonMixin:HasAvailablePetActions()
	if not UnitExists("pet") then
		return false;
	end

	for i=1, NUM_PET_ACTION_SLOTS do
		local name, _, isToken = GetPetActionInfo(i);
		if isToken and GamepadPetActionFlyout.buttonFromAction[name] then
			return true;
		end
	end

	return false;
end

function PetActionFlyoutButtonMixin:OnShow()
	GamepadClassActionButtonMixin.OnShow(self);

	self:UpdateFlash();
end

function PetActionFlyoutButtonMixin:OnHide()
	GamepadClassActionButtonMixin.OnHide(self);

	self:UpdateFlash();
end

-- Overrides GamepadActionBarStandardButtonMixin.OnEvent
function PetActionFlyoutButtonMixin:OnEvent(event, ...)
	GamepadActionBarStandardButtonMixin.OnEvent(self, event, ...);

	if event == "PET_BAR_UPDATE" then
		self:UpdateFlash();
	elseif event == "UNIT_FLAGS" then
		local unitTarget = ...;
		if unitTarget == "pet" then
			self:UpdateFlash();
		end
	elseif event == "UNIT_PET" then
		local unitTarget = ...;
		if unitTarget == "player" then
			self:UpdateIcon();
			self:SetShown(self:HasAvailablePetActions());
		end
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		local unitTarget = ...;
		if unitTarget == "pet" then
			self:UpdateIcon();
		end
	end
end

-- Overrides GamepadActionBarButtonFlyoutMixin.UpdateFlyoutPopup
function PetActionFlyoutButtonMixin:UpdateFlyoutPopup(_)
	self:SetPopup(GamepadPetActionFlyout);
end

function PetActionFlyoutButtonMixin:OnClick(button, down)
	if not down then
		self:TogglePopup();
	end
end

function PetActionFlyoutButtonMixin:UpdateIcon()
	if UnitExists("pet") then
		SetPortraitTexture(self.SpecialActionIcon, "pet");
	end
end

function PetActionFlyoutButtonMixin:UpdateFlash()
	self:SetFlashing(self:IsShown() and self:IsPetAttacking());
end

function PetActionFlyoutButtonMixin:IsPetAttacking()
	for i=1, NUM_PET_ACTION_SLOTS do
		local name, _, isToken, isActive = GetPetActionInfo(i);
		if isToken and name == "PET_ACTION_ATTACK" then
			return isActive;
		end
	end
	return false;
end

function PetActionFlyoutButtonMixin:SetFlashing(enabled)
	local function ToggleFlash(shouldShow)
		if shouldShow == nil then
			shouldShow = not self.Flash:IsShown();
		end

		-- Also update the actual attack button's flash here rather than independently, so they flash together
		self.popup.AttackButton.Flash:SetShown(shouldShow);
		self.Flash:SetShown(shouldShow);
	end

	if enabled then
		if not self.flashTicker then
			self.flashTicker = C_Timer.NewTicker(ATTACK_BUTTON_FLASH_TIME, function() ToggleFlash(); end);
			ToggleFlash(true);
		end
	elseif self.flashTicker then
		self.flashTicker:Cancel();
		self.flashTicker = nil;
		ToggleFlash(false);
	end
end

EventUtil.ContinueOnPlayerLogin(function()
	local className = UnitClassBase("player");
	if className == "HUNTER" or className == "WARLOCK" then
		local button = GamepadMainActionBarFrame.PageUnit.LeftClassAction;
		Mixin(button, PetActionFlyoutButtonMixin);
		button:Init();
	end
end);
