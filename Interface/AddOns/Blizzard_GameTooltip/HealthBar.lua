
function HealthBar_OnValueChanged(self, value, smooth)
	if ( not value ) then
		return;
	end
	local r, g, b;
	local min, max = self:GetMinMaxValues();
	if ( (value < min) or (value > max) ) then
		return;
	end
	if ( (max - min) > 0 ) then
		value = (value - min) / (max - min);
	else
		value = 0;
	end
	if(smooth) then
		if(value > 0.5) then
			r = (1.0 - value) * 2;
			g = 1.0;
		else
			r = 1.0;
			g = value * 2;
		end
	else
		r = 0.0;
		g = 1.0;
	end
	b = 0.0;
	if ( not self.lockColor ) then
		self:SetStatusBarColor(r, g, b);
	end
end
