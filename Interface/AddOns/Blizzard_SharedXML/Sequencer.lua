SequencerMixin = {};

function SequencerMixin:Init()
	self.original = {};
	self.onFinish = GenerateClosure(self.ExecuteNext, self);
end

function SequencerMixin:AddInterpolated(v1, v2, time, interpType, func)
	local interpolation = {v1 = v1, v2 = v2, time = time, interpType = interpType};
	table.insert(self.original, 1, {interpolation = interpolation, func = func});
end

function SequencerMixin:Add(func)
	table.insert(self.original, 1, {func = func});
end

function SequencerMixin:ExecuteNext()
	local sequence = table.remove(self.sequences);
	if sequence then
		local interpolation = sequence.interpolation;
		if interpolation then
			self.interpolator = CreateInterpolator(sequence.interpType);
			self.interpolator:Interpolate(interpolation.v1, interpolation.v2, interpolation.time, sequence.func, self.onFinish);
		else
			sequence.func();
			self:ExecuteNext();
		end
	end
end

function SequencerMixin:Cancel()
	if self.interpolator then
		self.interpolator:Cancel();
	end
	self.sequences = {};
end

function SequencerMixin:Play()
	local shallow = true;
	self.sequences = CopyTable(self.original, shallow);
	self:ExecuteNext();
end

function CreateSequencer()
	local sequencer = CreateFromMixins(SequencerMixin);
	sequencer:Init();
	return sequencer;
end