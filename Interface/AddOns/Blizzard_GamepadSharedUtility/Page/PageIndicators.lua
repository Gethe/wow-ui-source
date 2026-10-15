
GamepadPageIndicatorMixin = {};

function GamepadPageIndicatorMixin:SetOnClick(func, owner)
	self:SetScript("OnClick", GenerateClosure(func, owner));
end

function GamepadPageIndicatorMixin:OnHide()
	self:SetScript("OnClick", nil);
end

function GamepadPageIndicatorMixin:SetEnabledCondition(func)
	self.enabledCondition = func;
end

function GamepadPageIndicatorMixin:SetEnabled(enabled)
	if enabled then
		self:GetNormalTexture():SetVertexColor(1, 1, 1, 1);		
	else
		self:GetNormalTexture():SetVertexColor(GAMEPAD_TAB_INDICATOR_BUTTON_INPUT_ICON_DISABLED_COLOR:GetRGBA());
	end
end

function GamepadPageIndicatorMixin:UpdateEnabledState()
	if self.enabledCondition and not self.enabledCondition() then
		self:SetEnabled(false);
		return;
	end

	self:SetEnabled(true);
end
