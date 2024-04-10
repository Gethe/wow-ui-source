
ScriptAnimatedEffectControllerMixin = {};

function ScriptAnimatedEffectControllerMixin:Init(modelScene, effectID, source, target, onEffectFinish, onEffectResolution, scaleMultiplier)
	self.modelScene = modelScene;
	self.effectID = effectID;
	self.initialEffectID = effectID;
	self.source = source;
	self.target = target;
	self.onEffectFinish = onEffectFinish;
	self.onEffectResolution = onEffectResolution;
	self.scaleMultiplier = scaleMultiplier;

	self.activeBehaviors = {};
	self.effectCount = 0;

	self.loopingSoundEmitter = nil;
	self.soundEnabled = true;
end

function ScriptAnimatedEffectControllerMixin:GetEffect()
	return ScriptedAnimationEffectsUtil.GetEffectByID(self.effectID);
end

function ScriptAnimatedEffectControllerMixin:GetCurrentEffectID()
	return self.effectID;
end

function ScriptAnimatedEffectControllerMixin:GetInitialEffectID()
	return self.initialEffectID;
end

function ScriptAnimatedEffectControllerMixin:IsSoundEnabled()
	return self.soundEnabled;
end

function ScriptAnimatedEffectControllerMixin:SetSoundEnabled(enabled)
	self.soundEnabled = enabled;
end

function ScriptAnimatedEffectControllerMixin:StartEffect()
	if self.cancelDelayedStart then
		self.cancelDelayedStart = nil;
		return;
	end

	self.effectStarted = true;

	self.effectCount = self.effectCount + 1;

	self.actor = self.modelScene:InternalAddEffect(self.effectID, self.source, self.target, self, self.scaleMultiplier);

	local effect = self:GetEffect();
	if effect.startBehavior then
		self:BeginBehavior(effect.startBehavior);
	end

	if self:IsSoundEnabled() and effect.loopingSoundKitID then
		local startingSound = nil;
		local loopingSound = effect.loopingSoundKitID;

		local endingSound = nil;
		local loopStartDelay = 0;
		local loopEndDelay = 0;
		local loopFadeTime = 0;
		self.loopingSoundEmitter = CreateLoopingSoundEffectEmitter(startingSound, loopingSound, endingSound, loopStartDelay, loopEndDelay, loopFadeTime);
		self.loopingSoundEmitter:StartLoopingSound();
	end
	
	if self:IsSoundEnabled() and effect.startSoundKitID then
		PlaySound(effect.startSoundKitID);
	end

	self:UpdateActorDynamicOffsets()
end

function ScriptAnimatedEffectControllerMixin:DeltaUpdate(elapsedTime)
	if self.actor then
		if self.actor:IsActive() then
			self.actor:DeltaUpdate(elapsedTime);
		else
			self:FinishEffect();
		end
	end

	local behaviorFinished = false;
	local currentTime = GetTime();
	local i = 1;
	while i <= #self.activeBehaviors do
		local activeBehaviors = self.activeBehaviors[i];
		if currentTime < activeBehaviors.finishTime then
			i = i + 1;
		else
			behaviorFinished = true;
			tUnorderedRemove(self.activeBehaviors, i);
		end
	end

	if behaviorFinished then
		self:CheckResolution();
	end
end

function ScriptAnimatedEffectControllerMixin:IsActive()
	return self.actor or #self.activeBehaviors > 0;
end

function ScriptAnimatedEffectControllerMixin:CancelLoopingSound()
	if self.loopingSoundEmitter then
		self.loopingSoundEmitter:CancelLoopingSound();
	end
end

function ScriptAnimatedEffectControllerMixin:FinishLoopingSound()
	if self.loopingSoundEmitter then
		self.loopingSoundEmitter:FinishLoopingSound();
	end
end

function ScriptAnimatedEffectControllerMixin:FinishEffect()
	local effect = self:GetEffect();
	if effect.finishBehavior then
		self:BeginBehavior(effect.finishBehavior);
	end

	if self:IsSoundEnabled() and effect.finishSoundKitID then
		PlaySound(effect.finishSoundKitID);
	end

	self:RunEffectFinish();

	if self.actor then
		self.modelScene:ReleaseActor(self.actor);
		self.actor = nil;
	end

	self:FinishLoopingSound();

	if effect.finishEffectID then
		self.effectID = effect.finishEffectID;
		self:StartEffect();
		self.actor:DeltaUpdate(0);
	end

	self:CheckResolution();
end

function ScriptAnimatedEffectControllerMixin:CheckResolution()
	if not self:IsActive() then
		self:RunEffectResolution();
	end
end

function ScriptAnimatedEffectControllerMixin:RunEffectResolution(cancelled)
	if self.onEffectResolution then
		self.onEffectResolution(self.effectCount, not not cancelled);
	end
end

function ScriptAnimatedEffectControllerMixin:RunEffectFinish(cancelled)
	if self.onEffectFinish then
		if not self.onEffectFinish(self.effectCount, not not cancelled) then
			self.onEffectFinish = nil;
		end
	end
end

function ScriptAnimatedEffectControllerMixin:SetDynamicOffsets(pixelX, pixelY, pixelZ)
	self.dynamicPixelX = pixelX;
	self.dynamicPixelY = pixelY;
	self.dynamicPixelZ = pixelZ;
	self:UpdateActorDynamicOffsets();
end

function ScriptAnimatedEffectControllerMixin:UpdateActorDynamicOffsets()
	if self.actor then
		self.actor:SetDynamicOffsets(self.dynamicPixelX, self.dynamicPixelY, self.dynamicPixelZ);
	end
end

function ScriptAnimatedEffectControllerMixin:CancelEffect()
	self:InternalCancelEffect();
end

function ScriptAnimatedEffectControllerMixin:InternalCancelEffect(skipRemovingController)
	if not self.effectStarted then
		self.cancelDelayedStart = true;
		return;
	end

	if not skipRemovingController then
		self.modelScene:RemoveEffectController(self);
	end

	self.modelScene:ReleaseActor(self.actor);

	for i, activeBehavior in ipairs(self.activeBehaviors) do
		activeBehavior.cancelFunction();
	end

	self.activeBehaviors = {};

	self:CancelLoopingSound();
	local cancelled = true;
	self:RunEffectFinish(cancelled);
	self:RunEffectResolution(cancelled);
end

function ScriptAnimatedEffectControllerMixin:BeginBehavior(behavior)
	local effect = self:GetEffect();
	local cancelFunction, duration = behavior(effect, self.source, self.target, self.modelScene:GetEffectSpeed());
	local finishTime = GetTime() + duration;
	table.insert(self.activeBehaviors, { cancelFunction = cancelFunction, finishTime = finishTime });
end
