
function CooldownFrame_SetTimer(self, start, duration, enable, charges, maxCharges)
	if ( start and start > 0 and duration > 0 and enable > 0) then
		self:SetCooldown(start, duration, charges, maxCharges);
		self:Show();
	else
		self:Hide();
	end
end
