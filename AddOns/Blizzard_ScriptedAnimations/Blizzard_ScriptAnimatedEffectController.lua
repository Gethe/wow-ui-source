
EffectControllerMixin = {};

function EffectControllerMixin:Init(modelScene, effectID, source, target, onEffectFinish, onEffectResolution)
	self.modelScene = modelScene;
	self.effectID = effectID;
	self.source = source;
	self.target = target;
	self.onEffectFinish = onEffectFinish;
	self.onEffectResolution = onEffectResolution;

	self.activeBehaviors = {};
	self.effectCount = 0;
end

function EffectControllerMixin:GetEffect()
	return ScriptedAnimationEffectsUtil.GetEffectByID(self.effectID);
end

function EffectControllerMixin:StartEffect()
	self.effectCount = self.effectCount + 1;

	self.actor = self.modelScene:InternalAddEffect(self.effectID, self.source, self.target, self);

	local effect = self:GetEffect();
	if effect.startBehavior then
		self:BeginBehavior(effect.startBehavior);
	end

	if effect.startSoundKitID then
		PlaySound(effect.startSoundKitID);
	end
end

function EffectControllerMixin:DeltaUpdate(elapsedTime)
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

function EffectControllerMixin:IsActive()
	return self.actor or #self.activeBehaviors > 0;
end

function EffectControllerMixin:FinishEffect()
	local effect = self:GetEffect();
	if effect.finishBehavior then
		self:BeginBehavior(effect.finishBehavior);
	end

	if effect.finishSoundKitID then
		PlaySound(effect.finishSoundKitID);
	end

	self:RunEffectFinish();

	if self.actor then
		self.modelScene:ReleaseActor(self.actor);
		self.actor = nil;
	end

	if effect.finishEffectID then
		self.effectID = effect.finishEffectID;
		self:StartEffect();
	end

	self:CheckResolution();
end

function EffectControllerMixin:CheckResolution()
	if not self:IsActive() then
		self:RunEffectResolution();
	end
end

function EffectControllerMixin:RunEffectResolution()
	if self.onEffectResolution then
		self.onEffectResolution(self.effectCount);
	end
end

function EffectControllerMixin:RunEffectFinish()
	if self.onEffectFinish then
		if not self.onEffectFinish(self.effectCount) then
			self.onEffectFinish = nil;
		end
	end
end

function EffectControllerMixin:SetDynamicOffsets(pixelX, pixelY, pixelZ)
	self.actor:SetDynamicOffsets(pixelX, pixelY, pixelZ);
end

function EffectControllerMixin:CancelEffect()
	self:InternalCancelEffect();
end

function EffectControllerMixin:InternalCancelEffect(skipRemovingController)
	if not skipRemovingController then
		self.modelScene:RemoveEffectController(self);
	end

	self.modelScene:ReleaseActor(self.actor);

	for i, activeBehavior in ipairs(self.activeBehaviors) do
		activeBehavior.cancelFunction();
	end

	self.activeBehaviors = {};

	self:RunEffectFinish();
	self:RunEffectResolution();
end

function EffectControllerMixin:BeginBehavior(behavior)
	local effect = self:GetEffect();
	local cancelFunction, duration = behavior(effect, self.source, self.target, self.modelScene:GetEffectSpeed());
	local finishTime = GetTime() + duration;
	table.insert(self.activeBehaviors, { cancelFunction = cancelFunction, finishTime = finishTime });
end
