
InterpolatorUtil = {};

function InterpolatorUtil.InterpolateLinear(v1, v2, t)
	return (v1 * (1 - t)) + (v2 * t);
end

function InterpolatorUtil.InterpolateEaseOut(v1, v2, t)
	local y = math.sin(t * (math.pi * .5));
	return (v1 * (1 - y)) + (v2 * y);
end

function InterpolatorUtil.GetSmoothProgressChange(value, displayedValue, range, elapsed, minPerSecond, maxPerSecond)
	maxPerSecond = maxPerSecond or 0.7;
	minPerSecond = minPerSecond or 0.3;
	minPerSecond = max(minPerSecond, 1 / range);

	local diff = displayedValue - value;
	local diffRatio = diff / range;
	local change = range * ((minPerSecond / abs(diffRatio) + maxPerSecond - minPerSecond) * diffRatio) * elapsed;
	if ( abs(change) > abs(diff) or abs(diffRatio) < 0.01 ) then
		return value;
	else
		return displayedValue - change;
	end
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