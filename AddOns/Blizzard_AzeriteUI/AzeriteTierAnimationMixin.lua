--[[ Base Tier Animation ]]
AzeriteTierBaseAnimationMixin = {};
AzeriteTierBaseAnimationMixin.SUPPRESS_POWER_UPDATE = 1;

function AzeriteTierBaseAnimationMixin:OnLoad(owningFrame, firstAnimState, lastAnimState)
	self.owningFrame = owningFrame;
	self.shakingElapsedTime = 0;

	self.firstAnimState = firstAnimState;
	self.lastAnimState = lastAnimState;
end

function AzeriteTierBaseAnimationMixin:SetAnimType(animType)
	-- Call this in your onload with the most derived type
	self.animType = animType;
end

function AzeriteTierBaseAnimationMixin:GetAnimType()
	return self.animType;
end

function AzeriteTierBaseAnimationMixin:GetTotalProgressPercent(animState, localPercent)
	return ClampedPercentageBetween(animState + localPercent, self.firstAnimState, self.lastAnimState + 1);
end

function AzeriteTierBaseAnimationMixin:TryShaking(elapsed, magnitude, frequency)
	self.shakingElapsedTime = self.shakingElapsedTime + elapsed;
	if self.shakingElapsedTime > frequency then
		self.owningFrame:ApplyShakeOffset(CreateVector2D(RandomFloatInRange(-magnitude, magnitude), RandomFloatInRange(-magnitude, magnitude)));
		self.shakingElapsedTime = self.shakingElapsedTime - frequency;
	end
end

function AzeriteTierBaseAnimationMixin:SetAnimState(newAnimState, ...)
	if newAnimState ~= self.animState then
		self.animState = newAnimState;

		if self:OnAnimStateChanged(self.animState) ~= self.SUPPRESS_POWER_UPDATE then
			self.owningFrame:UpdatePowerStates();
		end
	end
end

function AzeriteTierBaseAnimationMixin:Play()
	self:SetAnimState(self.firstAnimState);
end

function AzeriteTierBaseAnimationMixin:IsFinished()
	-- override and return when the animation is finished
	return self.animState == nil;
end

function AzeriteTierBaseAnimationMixin:OnAnimStateChanged(animState)
	-- override to handle transitions

	-- return SUPPRESS_POWER_UPDATE to suppress power updates, otherwise return nil
end

--[[ Power Selected Animation ]]
AzeriteTierPowerSelectedAnimationMixin = CreateFromMixins(AzeriteTierBaseAnimationMixin);

AzeriteTierPowerSelectedAnimationMixin.START_HOLD = 1;
AzeriteTierPowerSelectedAnimationMixin.ROTATING = 2;
AzeriteTierPowerSelectedAnimationMixin.END_HOLD = 3;

function AzeriteTierPowerSelectedAnimationMixin:Create(...)
	local powerSelectedAnimation = CreateFromMixins(AzeriteTierPowerSelectedAnimationMixin);
	powerSelectedAnimation:OnLoad(...);

	return powerSelectedAnimation;
end

function AzeriteTierPowerSelectedAnimationMixin:OnLoad(owningFrame, azeritePowerButton, startAngle, loopingSoundEmitter)
	AzeriteTierBaseAnimationMixin.OnLoad(self, owningFrame, self.START_HOLD, self.END_HOLD);

	self.azeritePowerButton = azeritePowerButton;
	self.loopingSoundEmitter = loopingSoundEmitter;

	self:InitializeAnimStates(azeritePowerButton, startAngle);

	self:SetAnimType(AzeriteTierPowerSelectedAnimationMixin);
end

function AzeriteTierPowerSelectedAnimationMixin:InitializeAnimStates(azeritePowerButton, startAngle)
	local now = GetTime();
	local START_HOLD_TIME = .5;
	local LOCK_HOLD_TIME = .5;

	local endAngle = azeritePowerButton:GetBaseAngle();
	local angleDelta = math.atan2(math.sin(endAngle - startAngle), math.cos(endAngle - startAngle));

	local DISTANCE_PER_SEC = math.pi * .35;

	self.animStateData = 
	{
		[self.START_HOLD] = 
		{
			startTime = now,
			endTime = now + START_HOLD_TIME,
		},

		[self.ROTATING] = 
		{
			startAngle = startAngle,
			angleDelta = angleDelta,
			startTime = now + START_HOLD_TIME,
			durationSec = math.abs(angleDelta) / DISTANCE_PER_SEC,
			hasPlayedLockInEffect = false,
			hasPlayedEndingClickSound = false,
		},

		[self.END_HOLD] = 
		{
			endDuration = LOCK_HOLD_TIME,
		},
	};
end

function AzeriteTierPowerSelectedAnimationMixin:OnAnimStateChanged(animState) -- override
	if animState == self.ANIM_STATE_NONE then
		self.animStateData = nil;
		return self.SUPPRESS_POWER_UPDATE;
	elseif animState == self.ROTATING then
		return self.SUPPRESS_POWER_UPDATE;
	elseif animState == self.START_HOLD then
		if self.loopingSoundEmitter then
			self.loopingSoundEmitter:StartLoopingSound();
		end
	elseif animState == self.END_HOLD then
		local now = GetTime();
		self.animStateData[animState].startTime = now;
		self.animStateData[animState].endTime = now + self.animStateData[animState].endDuration;
	end
end

function AzeriteTierPowerSelectedAnimationMixin:PerformAnimation(elapsed)
	local animStateData = self.animStateData[self.animState];
	local now = GetTime();

	if self.animState == self.START_HOLD then
		local percent = ClampedPercentageBetween(now, animStateData.startTime, animStateData.endTime);
		self.owningFrame:OnTierAnimationProgress(self:GetTotalProgressPercent(self.animState, percent));

		self:TryShaking(elapsed, percent * .8, .05);
		if now >= animStateData.endTime then
			self:SetAnimState(self.ROTATING);
		end
	elseif self.animState == self.ROTATING then
		local startTime = animStateData.startTime;
		local durationSec = animStateData.durationSec;
		local endTime = startTime + durationSec;

		local percent = ClampedPercentageBetween(now, startTime, endTime);
		self.owningFrame:OnTierAnimationProgress(self:GetTotalProgressPercent(self.animState, percent));

		if self.azeritePowerButton == nil then
			if percent > .15 and not animStateData.hasPlayedLockInEffect then
				animStateData.hasPlayedLockInEffect = true;
				PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONENDS_FINALTRAIT);
				self.owningFrame:PlayLockedInEffect();
			end

			if percent == 1.0 then
				self:SetAnimState(self.END_HOLD);
			end
		else
			local startAngle = animStateData.startAngle;
			local angleDelta = animStateData.angleDelta;
			local targetAngle = startAngle + angleDelta;

			local newRotation = Lerp(startAngle, targetAngle, EasingUtil.InOutQuadratic(percent));

			local LERP_AMOUNT_PER_NORMALIZED_FRAME = .2;
			local smoothedRotation = FrameDeltaLerp(self.owningFrame:GetNodeRotation(), newRotation, LERP_AMOUNT_PER_NORMALIZED_FRAME);

			if percent > .85 and not animStateData.hasPlayedEndingClickSound then
				animStateData.hasPlayedEndingClickSound = true;
				self.loopingSoundEmitter:FinishLoopingSound();
			end

			if percent > .95 and not animStateData.hasPlayedLockInEffect then
				animStateData.hasPlayedLockInEffect = true;
				PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_ROTATIONENDS);
				self.owningFrame:PlayLockedInEffect();
				self.azeritePowerButton:PlaySelectedAnimation();
			end

			local CLOSE_ENOUGH_ANGLE_DIFF = math.pi * .0001;
			if percent == 1.0 and math.abs(newRotation - smoothedRotation) < CLOSE_ENOUGH_ANGLE_DIFF then
				self.owningFrame:SetNodeRotations(newRotation);
				self.owningFrame:ApplyShakeOffset(CreateVector2D(0, 0));
				self:SetAnimState(self.END_HOLD);
			else
				self.owningFrame:SetNodeRotations(smoothedRotation);
			end
		end
	elseif self.animState == self.END_HOLD then
		local percent = ClampedPercentageBetween(now, animStateData.startTime, animStateData.endTime);
		self.owningFrame:OnTierAnimationProgress(self:GetTotalProgressPercent(self.animState, percent));

		self:TryShaking(elapsed, (1.0 - percent) * .8, .05);
		if now >= animStateData.endTime then
			self:SetAnimState(self.ANIM_STATE_NONE);
		end
	end
end


--[[ Final Power Selected Animation ]]
AzeriteTierFinalPowerSelectedAnimationMixin = CreateFromMixins(AzeriteTierPowerSelectedAnimationMixin);

function AzeriteTierFinalPowerSelectedAnimationMixin:Create(owningFrame)
	local finalPowerSelectedAnimation = CreateFromMixins(AzeriteTierFinalPowerSelectedAnimationMixin);
	finalPowerSelectedAnimation:OnLoad(owningFrame, nil, nil, nil);

	return finalPowerSelectedAnimation;
end

function AzeriteTierFinalPowerSelectedAnimationMixin:OnLoad(...) -- override
	AzeriteTierPowerSelectedAnimationMixin.OnLoad(self, ...);

	self:SetAnimType(AzeriteTierFinalPowerSelectedAnimationMixin);
end

function AzeriteTierFinalPowerSelectedAnimationMixin:TryShaking() -- override
	-- no shaking on the final tier
end

function AzeriteTierFinalPowerSelectedAnimationMixin:InitializeAnimStates() -- override
	local now = GetTime();
	local START_HOLD_TIME = .35;
	local LOCK_HOLD_TIME = .35;

	self.animStateData = 
	{
		[self.START_HOLD] = 
		{
			startTime = now,
			endTime = now + START_HOLD_TIME,
		},

		[self.ROTATING] = 
		{
			startTime = now + START_HOLD_TIME,
			durationSec = 1.5,
			hasPlayedLockInEffect = false,
			hasPlayedEndingClickSound = false,
		},

		[self.END_HOLD] = 
		{
			endDuration = LOCK_HOLD_TIME,
		},
	};
end

--[[ Reveal Animation ]]

AzeriteTierRevealAnimationMixin = CreateFromMixins(AzeriteTierBaseAnimationMixin);

AzeriteTierRevealAnimationMixin.START_HOLD = 1;
AzeriteTierRevealAnimationMixin.ROTATING = 2;
AzeriteTierRevealAnimationMixin.END_HOLD = 4;

function AzeriteTierRevealAnimationMixin:Create(...)
	local powerSelectedAnimation = CreateFromMixins(AzeriteTierRevealAnimationMixin);
	powerSelectedAnimation:OnLoad(...);

	return powerSelectedAnimation;
end

function AzeriteTierRevealAnimationMixin:OnLoad(owningFrame)
	AzeriteTierBaseAnimationMixin.OnLoad(self, owningFrame, self.START_HOLD, self.END_HOLD);
	self:SetAnimType(AzeriteTierRevealAnimationMixin);

	self:InitializeAnimStates();
end

function AzeriteTierRevealAnimationMixin:InitializeAnimStates()
	local now = GetTime();
	local START_HOLD_TIME = .15 + .15 * (self.owningFrame:GetTierIndex() - 1);
	local LOCK_HOLD_TIME = .05;

	local sign = math.floor(now + self.owningFrame:GetTierIndex()) % 2 == 1 and 1 or -1;
	local startAngle = math.pi * 1.25 * sign;
	local endAngle = 0.0;

	local ROTATING_DISTANCE_PER_SEC = math.pi * .35;

	self.animStateData = 
	{
		[self.START_HOLD] = 
		{
			startTime = now,
			animDelay = (self.owningFrame:GetTierIndex() - 1) * .45,
			endTime = now + START_HOLD_TIME,
		},

		[self.ROTATING] = {
			startAngle = startAngle,
			endAngle = endAngle,
			startTime = now + START_HOLD_TIME,
			durationSec = math.min(math.max(.01, math.abs(startAngle - endAngle)) / ROTATING_DISTANCE_PER_SEC, 4.0),
		},

		[self.END_HOLD] = 
		{
			endDuration = LOCK_HOLD_TIME,
		},
	};

	self.owningFrame:SetNodeRotations(startAngle);
end

function AzeriteTierRevealAnimationMixin:PerformRotation(now, animStateData)
	local startTime = animStateData.startTime;
	local durationSec = animStateData.durationSec;
	local endTime = startTime + durationSec;

	local percent = ClampedPercentageBetween(now, startTime, endTime);
	self.owningFrame:OnTierAnimationProgress(self:GetTotalProgressPercent(self.animState, percent));

	local startAngle = animStateData.startAngle;
	local angleDelta = animStateData.angleDelta;
	local targetAngle = animStateData.endAngle;

	local newRotation = Lerp(startAngle, targetAngle, EasingUtil.InOutCubic(percent));

	local LERP_AMOUNT_PER_NORMALIZED_FRAME = .2;
	local smoothedRotation = FrameDeltaLerp(self.owningFrame:GetNodeRotation(), newRotation, LERP_AMOUNT_PER_NORMALIZED_FRAME);

	local CLOSE_ENOUGH_ANGLE_DIFF = math.pi * .0001;
	local isCloseEnough = math.abs(newRotation - smoothedRotation) < CLOSE_ENOUGH_ANGLE_DIFF;
	if percent == 1.0 and isCloseEnough then
		self.owningFrame:SetNodeRotations(newRotation);
		self.owningFrame:ApplyShakeOffset(CreateVector2D(0, 0));
		self:SetAnimState(self.END_HOLD);
	else
		self.owningFrame:SetNodeRotations(smoothedRotation);
	end

	return percent;
end

function AzeriteTierRevealAnimationMixin:PerformAnimation(elapsed)
	local animStateData = self.animStateData[self.animState];
	local now = GetTime();

	if self.animState == self.START_HOLD then
		local percent = ClampedPercentageBetween(now, animStateData.startTime, animStateData.endTime);
		self.owningFrame:OnTierAnimationProgress(self:GetTotalProgressPercent(self.animState, percent));

		if (percent == 1.0 or now >= animStateData.startTime + animStateData.animDelay) and not animStateData.hasPlayedRevealGow then
			animStateData.hasPlayedRevealGow = true;
			self.owningFrame:PlayRevealGlows();
		end

		self:TryShaking(elapsed, percent * .8, .05);
		if now >= animStateData.endTime then
			self:SetAnimState(self.ROTATING);
		end
	elseif self.animState == self.ROTATING then
		local percent = self:PerformRotation(now, animStateData);

		if percent > .7 and not animStateData.hasPlayedPowerReveal then
			animStateData.hasPlayedPowerReveal = true;
			self.owningFrame:PlayPowerReveal();
		end

		if percent > .95 and not animStateData.hasSignaledRevealStopped then
			animStateData.hasSignaledRevealStopped = true;
			self.owningFrame:OnTierRevealRotationStopped();
		end

	elseif self.animState == self.END_HOLD then
		local percent = ClampedPercentageBetween(now, animStateData.startTime, animStateData.endTime);
		self.owningFrame:OnTierAnimationProgress(self:GetTotalProgressPercent(self.animState, percent));

		if now >= animStateData.endTime then
			self:SetAnimState(self.ANIM_STATE_NONE);
		end
	end
end

function AzeriteTierRevealAnimationMixin:OnAnimStateChanged(animState) -- override
	if animState == self.ANIM_STATE_NONE then
		self.animStateData = nil;
		return self.SUPPRESS_POWER_UPDATE;
	elseif animState == self.START_HOLD then
		-- nothing
	elseif animState == self.ROTATING then
		self.owningFrame:OnTierRevealRotationStarted();
		return self.SUPPRESS_POWER_UPDATE;
	elseif animState == self.END_HOLD then
		local now = GetTime();
		self.animStateData[animState].startTime = now;
		self.animStateData[animState].endTime = now + self.animStateData[animState].endDuration;
	end
end