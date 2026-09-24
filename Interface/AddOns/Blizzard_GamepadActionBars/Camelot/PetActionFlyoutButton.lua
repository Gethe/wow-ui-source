GamepadPetActionFlyoutButtonMixin = {};

function GamepadPetActionFlyoutButtonMixin:OnLoad()
	self.HotKey:ClearAllPoints();
	self.HotKey:SetPoint("TOPRIGHT");
	self.HotKey:SetText(RANGE_INDICATOR);
	self.HotKey:Hide();

	-- Re-use the square auto-attack red flash by allowing it to over-scale and be masked, hiding the frame shape.
	self.Flash:AddMaskTexture(self.IconMask);
	self.Flash:ClearAllPoints();
	self.Flash:SetPoint("CENTER");
	self.Flash:SetScale(1.5);

	-- To match other pet action bars, make the checked textures of the attack action transparent
	if self.actionType == "PET_ACTION_ATTACK" then
		self.CheckedTexture:SetAlpha(0.5);
		self.CheckedOverlayTexture:SetAlpha(0.5);
	end

	self:RegisterForClicks("AnyUp");

	self:UpdateArrowShown();
end

function GamepadPetActionFlyoutButtonMixin:OnClick(button, down)
	if not down then
		if button == "LeftButton" then
			CastPetAction(self:GetPetActionID());
		else
			TogglePetAutocast(self:GetPetActionID());
		end
	end

	self:UpdateState();
end

function GamepadPetActionFlyoutButtonMixin:SetPetActionID(id)
	self.petActionID = id;
end

function GamepadPetActionFlyoutButtonMixin:GetPetActionID()
	return self.petActionID;
end

function GamepadPetActionFlyoutButtonMixin:SetTooltip(tooltip)
	tooltip:SetPetAction(self:GetPetActionID());
end

function GamepadPetActionFlyoutButtonMixin:OnShow()
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN");
	self:RegisterEvent("PET_BAR_UPDATE_USABLE");
	self:RegisterUnitEvent("UNIT_FLAGS", "pet");

	self:UpdateCooldown();
	self:UpdateRange();
	self:UpdateState();
	self:UpdateUsable();
end

function GamepadPetActionFlyoutButtonMixin:OnHide()
	self:UnregisterEvent("PET_BAR_UPDATE");
	self:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN");
	self:UnregisterEvent("PET_BAR_UPDATE_USABLE");
	self:UnregisterEvent("UNIT_FLAGS");
end

function GamepadPetActionFlyoutButtonMixin:OnEvent(event, ...)
	if event == "PET_BAR_UPDATE" then
		self:UpdateState();
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		self:UpdateCooldown();
	elseif event == "PET_PET_BAR_UPDATE_USABLE" then
		self:UpdateUsable();
	elseif event == "UNIT_FLAGS" then
		self:UpdateState();
	end
end

function GamepadPetActionFlyoutButtonMixin:UpdateArrowShown()
	self.Arrow:Hide();
end

function GamepadPetActionFlyoutButtonMixin:UpdateCooldown()
	local start, duration, enable = GetPetActionCooldown(self:GetPetActionID());
	CooldownFrame_Set(self.cooldown, start, duration, enable);
end

function GamepadPetActionFlyoutButtonMixin:UpdateRange()
	local _, _, _, _, _, _, _, checksRange, inRange = GetPetActionInfo(self:GetPetActionID());
	ActionButton_UpdateRangeIndicator(self, checksRange, inRange);
end

function GamepadPetActionFlyoutButtonMixin:UpdateState()
	local _, _, _, isActive, autoCastAvailable, autoCastEnabled = GetPetActionInfo(self:GetPetActionID());
	self:SetChecked(isActive);
	self.CheckedOverlayTexture:SetShown(isActive);
	self.AutoCastOverlay:SetShown(autoCastAvailable);
	self.AutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled);
end

function GamepadPetActionFlyoutButtonMixin:UpdateUsable()
	if GetPetActionSlotUsable(self:GetPetActionID()) then
		self.icon:SetVertexColor(1, 1, 1);
	else
		self.icon:SetVertexColor(0.4, 0.4, 0.4);
	end
end
