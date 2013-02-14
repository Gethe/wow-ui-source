
function CooldownFrame_SetTimer(self, start, duration, enable, charges, maxCharges)
	if(enable and enable ~= 0) then
		self:SetCooldown(start, duration, charges, maxCharges);
	else
		self:SetCooldown(0, 0, charges, maxCharges);
	end
end
