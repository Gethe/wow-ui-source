InterpolatorMixin = {}

local function InterpolateEaseOut(v1, v2, t)
	local y = math.sin(t * (math.pi * .5));
	return (v1 * (1 - y)) + (v2 * y);
end

function InterpolatorMixin:Interpolate(v1, v2, time, setter)
	if self.interpolateTo and ApproximatelyEqual(v1, v2) then
		return;
	end
	self.interpolateTo = v2;

	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end

	local elapsed = 0;
	local interpolate = function()
		elapsed = elapsed + GetTickTime();
		local u = Saturate(elapsed / time);
		setter(InterpolateEaseOut(v1, v2, u));
		if u >= 1 then
			self.interpolateTo = nil;
			if self.timer then
				self.timer:Cancel();
				self.timer = nil;
			end
			return false;
		end

		return true;
	end;

	local continue = interpolate();
	if continue then
		self.timer = C_Timer.NewTicker(0, interpolate);
	end
end

function InterpolatorMixin:GetInterpolateTo()
	return self.interpolateTo;
end