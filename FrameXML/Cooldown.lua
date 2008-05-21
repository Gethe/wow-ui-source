
function CooldownFrame_SetTimer(self, start, duration, enable)
	if ( start > 0 and duration > 0 and enable > 0) then
		self:SetCooldown(start, duration);
		self:Show();
	else
		self:Hide();
	end
end
