--------------------------------------------------------------------------------
-- GamepadSpellFlyoutPopupButtonMixin
--------------------------------------------------------------------------------

GamepadSpellFlyoutPopupButtonMixin = CreateFromMixins(SpellFlyoutPopupButtonMixin, GamepadFlyoutPopupButtonMixin);

function GamepadSpellFlyoutPopupButtonMixin:OnShow()
	self:RegisterUnitEvent("UNIT_AURA", "player");
end

function GamepadSpellFlyoutPopupButtonMixin:OnHide()
	self:UnregisterEvent("UNIT_AURA");
end

function GamepadSpellFlyoutPopupButtonMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		self:UpdateState();
	end
end

-- Overrides SpellFlyoutPopupButtonMixin:OnClick
function GamepadSpellFlyoutPopupButtonMixin:OnClick()
	if not self:HandleClick() then
		SpellFlyoutPopupButtonMixin.OnClick(self);
	end
end

--------------------------------------------------------------------------------
-- GamepadSpellFlyoutMixin
--------------------------------------------------------------------------------

GamepadSpellFlyoutMixin = CreateFromMixins(SpellFlyoutMixin, GamepadFlyoutMixin);

-- Overrides GamepadFlyoutMixin:OnLoad
function GamepadSpellFlyoutMixin:OnLoad()
	SpellFlyoutMixin.OnLoad(self);
	GamepadFlyoutMixin.OnLoad(self);
end

-- Overrides GamepadFlyoutMixin:OnShow
function GamepadSpellFlyoutMixin:OnShow()
	SpellFlyoutMixin.OnShow(self);
	GamepadFlyoutMixin.OnShow(self);
end

-- Overrides GamepadFlyoutMixin:OnHide
function GamepadSpellFlyoutMixin:OnHide()
	SpellFlyoutMixin.OnHide(self);
	GamepadFlyoutMixin.OnHide(self);
end

-- Overrides SpellFlyoutMixin:ShowAllRanks
function GamepadSpellFlyoutMixin:ShowAllRanks()
	return false;
end
