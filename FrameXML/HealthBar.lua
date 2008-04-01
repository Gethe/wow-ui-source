
function HealthBar_OnValueChanged(value, smooth)
	if ( not value ) then
		return;
	end
	local r, g, b;
	local min, max = this:GetMinMaxValues();
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
		-- Stay green until less than 20% health
		--if(value > 0.2) then
		--	r = 0.0;
		--	g = 1.0;
		--else
		--	r = 1.0;
		--	g = 0.0;
		--end
		
		r = 0.0;
		g = 1.0;
	end
	b = 0.0;
	this:SetStatusBarColor(r, g, b);
end
