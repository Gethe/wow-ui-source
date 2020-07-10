
local ScriptedAnimationModelSceneID = 343;

-- Experimentally determined.
local SceneUnitDivisor = 612.5;

-- These are (somewhat) arbitrary values. With these, many standard effects with look correct with a scale of 1.0.
-- To change these, we'd have to update all existing effects that play in scenes with useViewInsetNormalization.
local TargetViewWidth = 600;
local TargetViewHeight = 680;


local EffectControllerMixin = {};

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
	local pixelsPerSceneUnit = self.modelScene:GetPixelsPerSceneUnit();
	local sceneX = pixelX and (pixelX / pixelsPerSceneUnit) or 0;
	local sceneY = pixelY and (pixelY / pixelsPerSceneUnit) or 0;
	local sceneZ = pixelZ and (pixelZ / pixelsPerSceneUnit) or 0;
	self.actor:SetDynamicOffsets(sceneX, sceneY, sceneZ);
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


ScriptAnimatedModelSceneActorMixin = {};

function ScriptAnimatedModelSceneActorMixin:IsActive()
	-- A duration of 0 is used for effects that last until canceled.
	return not self.elapsedTime or (self.duration == 0) or (self.elapsedTime < self.duration);
end

function ScriptAnimatedModelSceneActorMixin:GetModelScene()
	return self:GetParent();
end

function ScriptAnimatedModelSceneActorMixin:OnFinish()
	self.effectControl:FinishEffect();
end

-- This isn't a frame so its update function is called through its parent.
function ScriptAnimatedModelSceneActorMixin:DeltaUpdate(elapsed)
	self.elapsedTime = (self.elapsedTime or 0) + elapsed;
	if self.trajectory and self:IsActive() then
		local positionX, positionY, newTrajectory = self.trajectory(self.source, self.target, self.elapsedTime, self.duration);
		
		if newTrajectory then
			self.trajectory = newTrajectory;
		end

		if positionX and positionY then
			self:GetModelScene():SetActorPositionFromPixels(self, positionX, positionY);
			self:Show();
		else
			self:Hide();
		end
	end
end

local function GetAngleForModel(source, target)
	local sourceX, sourceY = source:GetCenter();
	local targetX, targetY = target:GetCenter();
	local direction = CreateVector2D(targetX - sourceX, targetY - sourceY);

	-- Missiles face right by default, so calculate the angle between the right normal (1, 0), and the direction we'd like to face.
	local radians = Vector2D_CalculateAngleBetween(1, 0, direction:GetXY());

	return radians;
end

function ScriptAnimatedModelSceneActorMixin:SetEffect(effectDescription, source, target)
	self:SetModelByFileID(effectDescription.visual);
	
	self:SetPitch(effectDescription.pitchRadians);
	self:SetRoll(effectDescription.rollRadians);

	self.baseOffsetX = effectDescription.offsetX;
	self.baseOffsetY = effectDescription.offsetY;
	self.baseOffsetZ = effectDescription.offsetZ;
	self:SetDynamicOffsets(0, 0, 0);

	local animationSpeed = effectDescription.animationSpeed;
	if animationSpeed == 0 then
		-- TODO:: Calculate the animation speed to complete 1 full cycle in the effect's duration.
		animationSpeed = 1.0;
	end

	local animationSpeed = self:GetModelScene():GetEffectSpeed() * animationSpeed;
	self:SetAnimation(0, 0, animationSpeed);

	self.elapsedTime = nil;

	self.source = source;
	self.target = target;

	self.effectDescription = effectDescription;
	self.trajectory = effectDescription.trajectory;
	self.duration = effectDescription.duration;
	self:SetScale(effectDescription.visualScale);

	if self.source and self.target and self.source ~= self.target then
		self:SetYaw(GetAngleForModel(self.source, self.target));
	else
		self:SetYaw(effectDescription.yawRadians);
	end

	self:DeltaUpdate(0);
end

function ScriptAnimatedModelSceneActorMixin:UpdateCombinedOffsets()
	self.combinedOffsetX = (self.dynamicOffsetX or 0) + self.baseOffsetX;
	self.combinedOffsetY = (self.dynamicOffsetY or 0) + self.baseOffsetY;
	self.combinedOffsetZ = (self.dynamicOffsetZ or 0) + self.baseOffsetZ;
end

function ScriptAnimatedModelSceneActorMixin:SetDynamicOffsets(sceneX, sceneY, sceneZ)
	self.dynamicOffsetX = sceneX;
	self.dynamicOffsetY = sceneY;
	self.dynamicOffsetZ = sceneZ;
	self:UpdateCombinedOffsets();
end

function ScriptAnimatedModelSceneActorMixin:SetEffectActorOffset(x, y, z)
	self:SetPosition(self.combinedOffsetX + x, self.combinedOffsetY + y, self.combinedOffsetZ + z);
end


ScriptAnimatedModelSceneMixin = {};

function ScriptAnimatedModelSceneMixin:OnLoad()
	ModelSceneMixin.OnLoad(self);

	self.centerX = 0;
	self.centerY = 0;
	self.effectControllers = {};
	self.pixelsPerSceneUnit = math.huge;
	self.delayedActions = {};

	self:RefreshModelScene();
end

function ScriptAnimatedModelSceneMixin:OnSizeChanged()
	self:RefreshModelScene();
end

function ScriptAnimatedModelSceneMixin:RefreshModelScene()
	if not self:IsRectValid() then
		return;
	end

	self.centerX, self.centerY = self:GetCenter();

	local sceneShouldBeSet = not self:IsModelSceneSet();
	if sceneShouldBeSet then
		self:SetFromModelSceneID(ScriptedAnimationModelSceneID);
		self.modelSceneSet = true;
	end

	if self.useViewInsetNormalization then
		local currentWidth, currentHeight = self:GetSize();
		local adjustmentX = (currentWidth - TargetViewWidth) / 2;
		local adjustmentY = (currentHeight - TargetViewHeight) / 2;
		self:SetViewInsets(adjustmentX, adjustmentX, adjustmentY, adjustmentY);
	end

	self:CalculatePixelsPerSceneUnit();

	-- Now that the scene is set, and we've calculated pixels per scene unit, we can execute the
	-- actions that were delayed until we had a proper scene set up.
	if sceneShouldBeSet then
		for i, action in ipairs(self.delayedActions) do
			action();
		end

		self.delayedActions = nil;
	end
end

function ScriptAnimatedModelSceneMixin:IsModelSceneSet()
	return self.modelSceneSet;
end

function ScriptAnimatedModelSceneMixin:ExecuteOrDelayUntilSceneSet(action)
	-- If we're still resolving sizing and anchoring and we don't have a proper model scene set up,
	-- we need to delay adding effects as they won't be initialized properly.
	if self:IsModelSceneSet() then
		action();
		return;
	end

	table.insert(self.delayedActions, action);
end

function ScriptAnimatedModelSceneMixin:OnUpdate(elapsed, ...)
	ModelSceneMixin.OnUpdate(self, elapsed, ...);

	if #self.effectControllers == 0 then
		return;
	end

	self.centerX, self.centerY = self:GetCenter();

	local modifiedElapsed = elapsed * self:GetEffectSpeed();
	for i, effectController in ipairs(self.effectControllers) do
		effectController:DeltaUpdate(modifiedElapsed, ...);
	end

	local i = 1;
	while i <= #self.effectControllers do
		local effectController = self.effectControllers[i];
		if effectController:IsActive() then
			i = i + 1;
		else
			tUnorderedRemove(self.effectControllers, i);
		end
	end
end

function ScriptAnimatedModelSceneMixin:SetActiveCamera(...)
	ModelSceneMixin.SetActiveCamera(self, ...);

	self:CalculatePixelsPerSceneUnit();
end

function ScriptAnimatedModelSceneMixin:GetSceneSize()
	local left, right, top, bottom = self:GetViewInsets();
	local width, height = self:GetSize();
	return (width - left) - right, (height - bottom) - top;
end

function ScriptAnimatedModelSceneMixin:CalculatePixelsPerSceneUnit()
	local width, height = self:GetSceneSize();
	local sceneSize = Vector2D_GetLength(width, height);
	local activeCamera = self:GetActiveCamera();
	if not activeCamera then
		return;
	end

	local zoomDistance = activeCamera:GetZoomDistance();
	self.pixelsPerSceneUnit = (sceneSize * zoomDistance) / SceneUnitDivisor;
end

function ScriptAnimatedModelSceneMixin:GetPixelsPerSceneUnit()
	return self.pixelsPerSceneUnit;
end

function ScriptAnimatedModelSceneMixin:AddEffect(effectID, source, target, onEffectFinish, onEffectResolution)
	local effectController = CreateAndInitFromMixin(EffectControllerMixin, self, effectID, source, target, onEffectFinish, onEffectResolution);

	local function StartEffectController()
		effectController:StartEffect();
	end

	self:ExecuteOrDelayUntilSceneSet(StartEffectController);
	
	return effectController; 
end

function ScriptAnimatedModelSceneMixin:AddDynamicEffect(dynamicEffectDescription, source, target, onEffectFinish, onEffectResolution)
	local effectController = CreateAndInitFromMixin(EffectControllerMixin, self, dynamicEffectDescription.effectID, source, target, onEffectFinish, onEffectResolution);

	local function StartEffectController()
		effectController:StartEffect();
		effectController:SetDynamicOffsets(dynamicEffectDescription.offsetX, dynamicEffectDescription.offsetY, dynamicEffectDescription.offsetZ);
	end

	self:ExecuteOrDelayUntilSceneSet(StartEffectController);
	
	return effectController; 
end

function ScriptAnimatedModelSceneMixin:InternalAddEffect(effectID, source, target, effectController)
	local effect = ScriptedAnimationEffectsUtil.GetEffectByID(effectID);

	local actor = self:AcquireActor();
	
	if not actor.SetEffect then
		Mixin(actor, ScriptAnimatedModelSceneActorMixin);
	end

	actor:SetEffect(effect, source, target);
	actor:Show();

	if not tContains(self.effectControllers, effectController) then
		table.insert(self.effectControllers, effectController);
	end

	return actor;
end

function ScriptAnimatedModelSceneMixin:SetEffectSpeed(speed)
	self.effectSpeed = speed;
end

function ScriptAnimatedModelSceneMixin:GetEffectSpeed()
	return self.effectSpeed or 1.0;
end

function ScriptAnimatedModelSceneMixin:ClearEffects()
	local skipRemovingController = true;
	for i, effectController in ipairs(self.effectControllers) do
		effectController:InternalCancelEffect(skipRemovingController);
	end

	self.effectControllers = {};
end

function ScriptAnimatedModelSceneMixin:RemoveEffectController(effectControllerToRemove)
	for i, effectController in ipairs(self.effectControllers) do
		if effectController == effectControllerToRemove then
			tUnorderedRemove(self.effectControllers, i);
			break;
		end
	end
end

function ScriptAnimatedModelSceneMixin:SetActorPositionFromPixels(actor, x, y, z)
	local pixelsPerSceneUnit = self.pixelsPerSceneUnit;
	local dx = (x - self.centerX) / pixelsPerSceneUnit;
	local dy = (y - self.centerY) / pixelsPerSceneUnit;
	local actorScaleDivisor = actor:GetScale();
	actor:SetEffectActorOffset(dx / actorScaleDivisor, dy / actorScaleDivisor, (z or 0) / actorScaleDivisor);
end
