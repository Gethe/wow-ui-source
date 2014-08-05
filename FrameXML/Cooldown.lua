
function CooldownFrame_SetTimer(self, start, duration, enable, charges, maxCharges, forceShowDrawEdge)
	if(enable) then
		if (enable ~= 0) then
			local drawEdge = false;
			if ( duration > 2 and charges and maxCharges and charges ~= 0) then
				drawEdge = true;
			end
			self:SetDrawEdge(drawEdge or forceShowDrawEdge);
			self:SetDrawSwipe(not drawEdge);
			self:SetCooldown(start, duration);
		else
			self:SetCooldown(0, 0);
		end
	end
end

