
local FADETOBLACK_STATE_ALPHATOBLACK = 1;
local FADETOBLACK_STATE_BLACKTOALPHA = 2;

local function LinearEase(progress)
	return progress;
end

local function QuinticEaseIn(progress)
	return (progress - 1) ^ 5 + 1;
end

FadeToBlackMixin = {};

function FadeToBlackMixin:OnUpdate(elapsed)
	if self.state then
		local now = GetTime();
		if not self.startTime then
			self.startTime = now;
		end
			
		local percentBetween = self.lengthSec > 0 and (now - self.startTime) / self.lengthSec or 1.0;

		local reverse = self.state == FADETOBLACK_STATE_BLACKTOALPHA;

		if percentBetween >= 1.0 then
			percentBetween = 1.0;
			self.state = nil;
		end

		self:SetAlpha(self.Ease(reverse and (1.0 - percentBetween) or percentBetween));
	end
end

function FadeToBlackMixin:Start(length)
	self.lengthSec = length or 3;
	self.startTime = nil;
	self.Ease = LinearEase;

	self.state = FADETOBLACK_STATE_ALPHATOBLACK;
end

function FadeToBlackMixin:ReverseStart(length)
	self.lengthSec = length or 3;
	self.startTime = nil;
	self.Ease = QuinticEaseIn;

	self.state = FADETOBLACK_STATE_BLACKTOALPHA;
end

function FadeToBlackMixin:Stop()
	self:ReverseStart(0);
end