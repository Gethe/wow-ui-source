
function CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge)
	if enable and enable ~= 0 and start > 0 and duration > 0 then
		self:SetDrawEdge(forceShowDrawEdge);
		self:SetCooldown(start, duration);
	else
		CooldownFrame_Clear(self);
	end
end

function CooldownFrame_Clear(self)
	self:Clear();
end