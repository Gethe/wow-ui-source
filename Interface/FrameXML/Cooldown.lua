
function CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge, modRate)
	if enable and enable ~= 0 and start > 0 and duration > 0 then
		self:SetDrawEdge(forceShowDrawEdge);
		self:SetCooldown(start, duration, modRate);
	else
		CooldownFrame_Clear(self);
	end
end

function CooldownFrame_Clear(self)
	self:Clear();
end

function CooldownFrame_SetDisplayAsPercentage(self, percentage)
	local seconds = 100;	-- any number, really
	self:Pause();
	self:SetCooldown(GetTime() - seconds * percentage, seconds);
end