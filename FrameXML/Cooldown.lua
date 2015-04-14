
function CooldownFrame_SetTimer(self, start, duration, enable, forceShowDrawEdge)
	if(enable) then
		if (enable ~= 0) then
			self:SetDrawEdge(forceShowDrawEdge);
			self:SetCooldown(start, duration);
		else
			self:SetCooldown(0, 0);
		end
	end
end

