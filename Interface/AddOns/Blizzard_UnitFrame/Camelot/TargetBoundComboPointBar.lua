-- Combo points are stored on the target, so the bar follows target changes rather than raw player power.
TargetBoundComboPointBarMixin = {};

function TargetBoundComboPointBarMixin:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	-- Moving points to a new target keeps the same count, so no power event fires.
	self:RegisterEvent("COMBO_TARGET_CHANGED");
end

function TargetBoundComboPointBarMixin:OnEvent(event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		local suppressTransitions = true;
		self:UpdatePower(suppressTransitions);
	elseif event == "COMBO_TARGET_CHANGED" then
		self:UpdatePower();
	else
		ClassResourceBarMixin.OnEvent(self, event, ...);
	end
end

function TargetBoundComboPointBarMixin:UpdatePower(suppressTransitions)
	local unit = self:GetUnit();
	local comboPoints = GetComboPoints(unit, "target");

	for i, comboPoint in ipairs(self.classResourceButtonTable) do
		local isActive = i <= comboPoints;
		if suppressTransitions then
			comboPoint:SetActiveNoAnimation(isActive);
		else
			comboPoint:SetActive(isActive);
		end
	end
end
