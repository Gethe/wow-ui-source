
-- This is a display template so it doesn't dictate the functionality of the button.
TalentRedButtonMixin = {};

function TalentRedButtonMixin:SetAndApplySize(_width, _height)
	-- Overrides TalentDisplayMixin.

	-- Red buttons are a fixed size.
end

function TalentRedButtonMixin:ApplyVisualState(visualState)
	-- Overrides TalentDisplayMixin.

	-- For now red buttons have a static display.
end

function TalentRedButtonMixin:UpdateNonStateVisuals()
	self:SetText(self:GetName());
end
