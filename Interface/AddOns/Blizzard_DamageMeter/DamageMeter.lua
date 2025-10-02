DamageMeterMixin = {};

function DamageMeterMixin:SetIsEditing(isEditing)
	if self.isEditing == isEditing then
		return;
	end

	self.isEditing = isEditing;

	self:UpdateShownState();
end

function DamageMeterMixin:IsEditing()
	return self.isEditing;
end

function DamageMeterMixin:ShouldBeShown()
	if self:IsEditing() then
		return true;
	end

	if self.visibility then
		if self.visibility == Enum.DamageMeterVisibility.Always then
			return true;
		elseif self.visibility == Enum.DamageMeterVisibility.InCombat then
			local isInCombat = UnitAffectingCombat("player");
			return isInCombat;
		elseif self.visibility == Enum.DamageMeterVisibility.Hidden then
			return false;
		else
			assertsafe(false, "Unknown value for visible setting: " .. self.visibleSetting);
		end
	end

	return true;
end

function DamageMeterMixin:UpdateShownState()
	local shouldBeShown = self:ShouldBeShown();
	self:SetShown(shouldBeShown);
end

function DamageMeterMixin:RefreshLayout()

end
