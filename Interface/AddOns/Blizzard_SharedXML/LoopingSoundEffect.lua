
LoopingSoundEffectMixin = {}

function CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime)
	local emitter = CreateFromMixins(LoopingSoundEffectMixin);
	emitter:OnLoad(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
	return emitter;
end

function LoopingSoundEffectMixin:OnLoad(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime)
	self.loopStartSoundEffect = startingSound;
	self.loopingSoundEffect = loopingSound;
	self.loopFinishSoundEffect = endingSound;
	self.loopingSoundEffectStartDelay = loopStartDelay;
	self.loopingSoundEffectFinishDelay = loopEndDelay;
	self.loopingSoundEffectFadeTime = loopFadeTime;
end

function LoopingSoundEffectMixin:StartLoopingSound()
	self:CancelLoopingSound();

	if self.loopStartSoundEffect then
		PlaySound(self.loopStartSoundEffect);
	end
	
	self.loopingSoundEffectStartTicker = C_Timer.NewTicker(self.loopingSoundEffectStartDelay, function ()
		self.loopingSoundEffectHandle = select(2, PlaySound(self.loopingSoundEffect));
		self.loopingSoundEffectStartTicker = nil;
	end, 1);
end

function LoopingSoundEffectMixin:FinishLoopingSound()
	if self.loopFinishSoundEffect then
		PlaySound(self.loopFinishSoundEffect);
	end
	
	self.loopingSoundEffectEndTicker = C_Timer.NewTicker(self.loopingSoundEffectFinishDelay, function ()
		if self.loopingSoundEffectHandle then
			StopSound(self.loopingSoundEffectHandle, self.loopingSoundEffectFadeTime);
			self.loopingSoundEffectHandle = nil;
		end
		self.loopingSoundEffectEndTicker = nil;
	end, 1);
end

function LoopingSoundEffectMixin:CancelLoopingSound()
	if self.loopingSoundEffectHandle then
		StopSound(self.loopingSoundEffectHandle);
		self.loopingSoundEffectHandle = nil;
	end
	
	if self.loopingSoundEffectStartTicker then
		self.loopingSoundEffectStartTicker:Cancel();
		self.loopingSoundEffectStartTicker = nil;
	end
	
	if self.loopingSoundEffectEndTicker then
		self.loopingSoundEffectEndTicker:Cancel();
		self.loopingSoundEffectEndTicker = nil;
	end
end