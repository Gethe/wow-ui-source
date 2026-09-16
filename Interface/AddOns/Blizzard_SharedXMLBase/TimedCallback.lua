TimedCallbackMixin = {};

function TimedCallbackMixin:SetCheckDelaySeconds(delay)
	self.delay = delay;
end

function TimedCallbackMixin:Cancel()
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function TimedCallbackMixin:ClearTimer()
	self:Cancel();
end

function TimedCallbackMixin:RunCallbackAsync(callback)
	self:Cancel();
	self.timer = C_Timer.NewTimer(self.delay or 1, callback);
end

