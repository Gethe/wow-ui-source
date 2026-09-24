local FLYOUTS = {
	DRUID = { id = 262, button = "LeftClassAction" },
	PALADIN = { id = 270, button = "LeftClassAction" },
	WARRIOR = { id = 269, button = "RightClassAction" },
};

local ClassSpellFlyoutButtonMixin = {};

function ClassSpellFlyoutButtonMixin:Init(flyoutID)
	self.flyoutID = flyoutID;
	self.icon:Show();

	-- Script methods are resolved when the frame is loaded. Since this is mixed in after load,
	-- simply overriding `OnEvent` won't actually replace the event handler work. Instead it has to
	-- be re-assigned.
	self:SetScript("OnEvent", self.OnEvent);

	self:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE");
	self:UpdateAction(true);
	self:UpdateVisibility();
end

-- Overrides GamepadActionBarStandardButtonMixin.OnEvent
function ClassSpellFlyoutButtonMixin:OnEvent(event, ...)
	GamepadActionBarStandardButtonMixin.OnEvent(self, event, ...);

	if event == "LEARNED_SPELL_IN_SKILL_LINE" then
		self:UpdateVisibility();
	elseif event == "SPELL_FLYOUT_UPDATE" then
		local flyoutID = ...;
		if flyoutID == self.flyoutID then
			self:UpdateVisibility();
		end
	end
end

function ClassSpellFlyoutButtonMixin:UpdateVisibility()
	local onlyKnown = true;
	local shouldShow = self:EnumFlyoutSlotInfo(onlyKnown)();
	self:SetShown(shouldShow);
end

-- Overrides GamepadActionBarButtonFlyoutMixin.UpdateAction
function ClassSpellFlyoutButtonMixin:UpdateAction(force)
	if self.isUpdatingAction then
		return;
	end
	self.isUpdatingAction = true;
	self:UpdateFlyoutActionInfo(true, self.flyoutID);
	self:Update();
	self.isUpdatingAction = false;
end

-- Overrides GamepadActionBarButtonFlyoutMixin.Update
function ClassSpellFlyoutButtonMixin:Update()
	self:UpdateFlyoutActionIcon();
end

-- Overrides GamepadClassActionButtonMixin.SetActionAttributes
function ClassSpellFlyoutButtonMixin:SetActionAttributes()
	GamepadActionBarButtonFlyoutMixin.SetActionAttributes(self);
end

EventUtil.ContinueOnPlayerLogin(function()
	local class = UnitClassBase("player");
	local flyout = FLYOUTS[class];
	if flyout then
		local button = GamepadMainActionBarFrame.PageUnit[flyout.button];
		Mixin(button, ClassSpellFlyoutButtonMixin);
		button:Init(flyout.id);
	end
end);
