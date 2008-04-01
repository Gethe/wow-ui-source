
function CooldownFrame_SetTimer(this, start, duration, enable)
	if ( start > 0 and duration > 0 and enable > 0) then
		this:SetCooldown(start, duration);
		this:Show();
	else
		this:Hide();
	end
end
