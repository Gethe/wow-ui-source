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

	local elapsed = 0;
	local interpolate = function()
		elapsed = elapsed + GetTickTime();
		local u = Saturate(elapsed / time);
		setter(self.interpolateFunc(v1, v2, u));
		if u >= 1 then
			if finished then
				finished();
			end

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

function CreateInterpolator(interpolateFunc)
	local interpolator = CreateFromMixins(InterpolatorMixin);
	interpolator.interpolateFunc = interpolateFunc or InterpolatorUtil.InterpolateEaseOut;
	return interpolator;
end

InterpolationSequenceMixin = {};

function InterpolationSequenceMixin:Init()
	self.original = {};
	self.onFinish = GenerateClosure(self.InterpolateNext, self);
end

function InterpolationSequenceMixin:Add(v1, v2, t, interpType, func)
	table.insert(self.original, 1, {v1=v1, v2=v2, t=t, interpType=interpType, func=func});
end

function InterpolationSequenceMixin:InterpolateNext()
	local sequence = table.remove(self.sequences);
	if sequence then
		local interpolator = CreateInterpolator(sequence.interpType);
		interpolator:Interpolate(sequence.v1, sequence.v2, sequence.t, sequence.func, self.onFinish);
	end
end

function InterpolationSequenceMixin:Play()
	local shallow = true;
	self.sequences = CopyTable(self.original, shallow);
	self:InterpolateNext();
end

function CreateInterpolationSequence()
	local sequencer = CreateFromMixins(InterpolationSequenceMixin);
	sequencer:Init();
	return sequencer;
end