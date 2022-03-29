SECONDS_PER_PULSE = 1;

function GlueButtonMaster_OnUpdate(self, elapsed)
	if ( _G[self:GetName().."Glow"]:IsShown() ) then
		local sign = self.pulseSign;
		local counter;
		
		if ( not self.pulsing ) then
			counter = 0;
			self.pulsing = 1;
			sign = 1;
		else
			counter = self.pulseCounter + (sign * elapsed);
			if ( counter > SECONDS_PER_PULSE ) then
				counter = SECONDS_PER_PULSE;
				sign = -sign;
			elseif ( counter < 0) then
				counter = 0;
				sign = -sign;
			end
		end
		
		local alpha = counter / SECONDS_PER_PULSE;
		_G[self:GetName().."Glow"]:SetVertexColor(1.0, 1.0, 1.0, alpha);

		self.pulseSign = sign;
		self.pulseCounter = counter;
	end
end
