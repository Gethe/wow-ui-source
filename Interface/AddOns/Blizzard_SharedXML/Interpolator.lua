
InterpolatorUtil = {};

function InterpolatorUtil.InterpolateLinear(v1, v2, t)
	return (v1 * (1 - t)) + (v2 * t);
end

function InterpolatorUtil.InterpolateEaseOut(v1, v2, t)
	local y = math.sin(t * (math.pi * .5));
	return (v1 * (1 - y)) + (v2 * y);
end

InterpolatorMixin = {}

function InterpolatorMixin:Interpolate(v1, v2, time, setter, finished)
	if self.interpolateTo and ApproximatelyEqual(v1, v2) then
		return;
	end
	self.interpolateTo = v2;

	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end

	time = math.max(0, time);
	local elapsed = 0;
	local interpolate = function()
		elapsed = elapsed + GetTickTime();
		local u = (time > 0) and Saturate(elapsed / time) or 1;
		setter(self.interpolateFunc(v1, v2, u));
		if u >= 1 then
			if finished then
				finished();
			end

			self:Cancel();
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

function InterpolatorMixin:Cancel()
	self.interpolateTo = nil;
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function CreateInterpolator(interpolateFunc)
	local interpolator = CreateFromMixins(InterpolatorMixin);
	interpolator.interpolateFunc = interpolateFunc or InterpolatorUtil.InterpolateEaseOut;
	return interpolator;
end