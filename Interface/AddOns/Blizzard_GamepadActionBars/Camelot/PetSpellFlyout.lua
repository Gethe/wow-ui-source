GamepadPetSpellFlyoutMixin = {};

-- Overrides GamepadFlyoutMixin.OnLoad
function GamepadPetSpellFlyoutMixin:OnLoad()
	GamepadFlyoutMixin.OnLoad(self);

	self.buttonPool = CreateFramePool("CHECKBUTTON", self, self.buttonTemplate, Pool_HideAndClearAnchors);
	self.buttons = {};
end

-- Overrides GamepadFlyoutMixin.OnShow
function GamepadPetSpellFlyoutMixin:OnShow()
	GamepadFlyoutMixin.OnShow(self);

	self:UpdateButtons();
	self:UpdateLayout(self.flyoutButton);

	if #self.buttons > 0 then
		self.rangeTicker = C_Timer.NewTicker(0.2, GenerateClosure(self.UpdateRange, self));
	end
end

-- Overrides GamepadFlyoutMixin.OnHide
function GamepadPetSpellFlyoutMixin:OnHide()
	GamepadFlyoutMixin.OnHide(self);

	if self.rangeTicker then
		self.rangeTicker:Cancel();
		self.rangeTicker = nil;
	end
end

-- Overrides GamepadFlyoutMixin.AttachToButton
function GamepadPetSpellFlyoutMixin:AttachToButton(button)
	self:UpdateLayout(button);

	GamepadFlyoutMixin.AttachToButton(self, button);
end

function GamepadPetSpellFlyoutMixin:UpdateRange()
	for _, button in ipairs(self.buttons) do
		button:UpdateRange();
	end
end

function GamepadPetSpellFlyoutMixin:UpdateButtons()
	for _, button in ipairs(self.buttons) do
		self.buttonPool:Release(button);
	end

	self.buttons = {};

	for i=1, NUM_PET_ACTION_SLOTS do
		local _, texture, isToken, _, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i);
		if spellID then
			local button = self.buttonPool:Acquire();
			table.insert(self.buttons, button);

			button.layoutIndex = #self.buttons;
			button.icon:SetTexture(isToken and _G[texture] or texture);
			button.icon:Show();
			button.AutoCastOverlay:SetShown(autoCastAllowed);
			button.AutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled);

			button:SetPetActionID(i);
			button:Show();
		end
	end

	self:Layout();
end

---------------------------------------------------------------------------------------------------

-- Applied to the flyout button when there is only one pet spell
local SingleSpellMixin = {};

function SingleSpellMixin:SetUp()
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN");
end

function SingleSpellMixin:TearDown()
	self:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN");

	self:RefreshRange(false, false);
end

function SingleSpellMixin:SetTooltip()
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetPetAction(self.petActionID);
	GameTooltip:Show();
end

function SingleSpellMixin:UpdateCooldown()
	local start, duration, enable = GetPetActionCooldown(self.petActionID);
	CooldownFrame_Set(self.cooldown, start, duration, enable);
end

function SingleSpellMixin:UpdateRange()
	local _, _, _, _, _, _, _, checksRange, inRange = GetPetActionInfo(self.petActionID);
	self:RefreshRange(checksRange, inRange);
end

function SingleSpellMixin:UpdateUsable()
	if GetPetActionSlotUsable(self.petActionID) then
		self.icon:SetVertexColor(1, 1, 1);
	else
		self.icon:SetVertexColor(0.4, 0.4, 0.4);
	end
end

-- Overrides GamepadActionBarButtonFlyoutMixin.UpdateFlyoutPopup
function SingleSpellMixin:UpdateFlyoutPopup(_)
	self:SetPopup(nil);
end

function SingleSpellMixin:OnClick(button, down)
	if not down then
		if button == "LeftButton" then
			CastPetAction(self.petActionID);
		else
			TogglePetAutocast(self.petActionID);
		end
	end
end

---------------------------------------------------------------------------------------------------

-- Applied to the flyout button when there are multiple pet spells
local MultipleSpellsMixin = {};

function MultipleSpellsMixin:SetUp()
end

function MultipleSpellsMixin:TearDown()
end

function MultipleSpellsMixin:SetTooltip()
end

function MultipleSpellsMixin:UpdateCooldown()
	CooldownFrame_Clear(self.cooldown);
end

function MultipleSpellsMixin:UpdateRange()
end

function MultipleSpellsMixin:UpdateUsable()
	local isAnyUsable = false;

	for i=1, NUM_PET_ACTION_SLOTS do
		if GetPetActionSlotUsable(i) then
			isAnyUsable = true;
			break;
		end
	end

	if isAnyUsable then
		self.icon:SetVertexColor(1, 1, 1);
	else
		self.icon:SetVertexColor(0.4, 0.4, 0.4);
	end
end

-- Overrides GamepadActionBarButtonFlyoutMixin.UpdateFlyoutPopup
function MultipleSpellsMixin:UpdateFlyoutPopup(_)
	self:SetPopup(GamepadPetSpellFlyout);
end

function MultipleSpellsMixin:OnClick(button, down)
	if not down then
		self:TogglePopup();
	end
end

---------------------------------------------------------------------------------------------------

local PetSpellFlyoutButtonMixin = {};

function PetSpellFlyoutButtonMixin:Init()
	self.icon:Show();

	-- Default to the multiple spell mixin
	Mixin(self, MultipleSpellsMixin);
	self:SetUp();

	-- Script methods are resolved when the frame is loaded. Since this is mixed in after load,
	-- simply overriding `OnEvent` won't actually replace the event handler work. Instead it has to
	-- be re-assigned.
	self:SetScript("OnEvent", self.OnEvent);
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE_USABLE");
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	self:RegisterUnitEvent("UNIT_PET", "player");

	-- Use a wrapper function for the OnClick handler so the OnClick function can be replaced
	self:SetScript("OnClick", function(_, ...)
		self:OnClick(...);
	end);

	self:Update();
end

-- Overrides GamepadActionBarStandardButtonMixin.OnEvent
function PetSpellFlyoutButtonMixin:OnEvent(event, ...)
	local handler = self[event];
	local eatEvent = handler and handler(self, ...);
	if not eatEvent then
		GamepadActionBarStandardButtonMixin.OnEvent(self, event, ...);
	end
end

function PetSpellFlyoutButtonMixin:ACTION_RANGE_CHECK_UPDATE()
	-- Eat this event since this isn't a bound action, so the arguments are inaccurate
	return true;
end

function PetSpellFlyoutButtonMixin:PET_BAR_UPDATE()
	self:Update();
end

function PetSpellFlyoutButtonMixin:PET_BAR_UPDATE_COOLDOWN()
	self:UpdateCooldown();
end

function PetSpellFlyoutButtonMixin:PET_BAR_UPDATE_USABLE()
	self:UpdateUsable();
end

function PetSpellFlyoutButtonMixin:UPDATE_VEHICLE_ACTIONBAR()
	self:Update();
end

function PetSpellFlyoutButtonMixin:UNIT_PET()
	self:Update();
end

function PetSpellFlyoutButtonMixin:Update()
	if not UnitExists("pet") or not PetHasActionBar() then
		self:Hide();
		return;
	end

	local firstActionID;
	local firstSpellAutoCastAllowed;
	local firstSpellAutoCastEnabled;
	local firstSpellID;
	local firstSpellTexture;
	local hasMultipleSpells = false;

	for i=1, NUM_PET_ACTION_SLOTS do
		local _, texture, isToken, _, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i);
		if spellID then
			if firstSpellID then
				hasMultipleSpells = true;
				break;
			end
			firstActionID = i;
			firstSpellAutoCastAllowed = autoCastAllowed;
			firstSpellAutoCastEnabled = autoCastEnabled;
			firstSpellID = spellID;
			firstSpellTexture = isToken and _G[texture] or texture;
		end
	end

	if self.rangeTicker then
		self.rangeTicker:Cancel();
		self.rangeTicker = nil;
	end

	if firstSpellID then
		self.icon:SetTexture(firstSpellTexture);

		if hasMultipleSpells then
			if self.petActionID then
				self:TearDown();
				Mixin(self, MultipleSpellsMixin);
				self:SetUp();
			end

			self.petActionID = nil;
			self.AutoCastOverlay:SetShown(false);
			self.AutoCastOverlay:ShowAutoCastEnabled(false);
		else
			if not self.petActionID then
				self:TearDown();
				Mixin(self, SingleSpellMixin);
				self:SetUp();
			end

			self.petActionID = firstActionID;
			self.AutoCastOverlay:SetShown(firstSpellAutoCastAllowed);
			self.AutoCastOverlay:ShowAutoCastEnabled(firstSpellAutoCastEnabled);
			self.rangeTicker = C_Timer.NewTicker(0.2, GenerateClosure(self.UpdateRange, self));
		end

		self:UpdateFlyoutPopup();
		self:UpdateArrowShown();
		self:UpdateCooldown();
		self:UpdateRange();
		self:UpdateUsable();

		self:Show();
	else
		self:Hide();
	end
end

EventUtil.ContinueOnPlayerLogin(function()
	local className = UnitClassBase("player");
	if className == "HUNTER" or className == "WARLOCK" then
		local button = GamepadMainActionBarFrame.PageUnit.RightClassAction;
		Mixin(button, PetSpellFlyoutButtonMixin);
		button:Init();
	end
end);
