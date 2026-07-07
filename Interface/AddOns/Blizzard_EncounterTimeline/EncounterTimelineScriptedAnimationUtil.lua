EncounterTimelineScriptedAnimatableMixin = {};

function EncounterTimelineScriptedAnimatableMixin:OnLoad()
	self.scriptedAnimationType = nil;
	self.scriptedAnimationStopFunction = nil;
end

function EncounterTimelineScriptedAnimatableMixin:GetScriptedAnimation()
	return self.scriptedAnimationType;
end

function EncounterTimelineScriptedAnimatableMixin:IsPlayingScriptedAnimation(animationType)
	return self.scriptedAnimationType == animationType;
end

function EncounterTimelineScriptedAnimatableMixin:CancelScriptedAnimation()
	if self.scriptedAnimationStopFunction then
		local canceled = true;
		self.scriptedAnimationStopFunction(canceled);
	end
end

function EncounterTimelineScriptedAnimatableMixin:FinishScriptedAnimation()
	if self.scriptedAnimationStopFunction then
		local canceled = false;
		self.scriptedAnimationStopFunction(canceled);
	end
end

function EncounterTimelineScriptedAnimatableMixin:StartScriptedAnimation(animationType, animationFunction, animationDuration, finishFunction)
	local frequency = nil;
	local canceled = false;

	local function OnAnimationUpdate(region, elapsed, duration)
		if not canceled then
			animationFunction(region, elapsed, duration);
		end
	end

	local function OnAnimationFinish(region)
		region.scriptedAnimationType = nil;
		region.scriptedAnimationStopFunction = nil;

		if finishFunction then
			finishFunction(region);
		end
	end

	local stopFunction = ScriptAnimationUtil.StartScriptAnimationGeneric(self, OnAnimationUpdate, animationDuration, frequency, OnAnimationFinish);

	local function StopAnimating(isCancellation)
		canceled = isCancellation;
		stopFunction();
	end

	self.scriptedAnimationType = animationType;
	self.scriptedAnimationStopFunction = StopAnimating;
end
