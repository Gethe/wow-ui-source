
local HalfPi = math.pi / 2;

-- Experimentally determined.
local SceneUnitDivisor = 196;


ScriptAnimatedModelSceneActorMixin = {};

function ScriptAnimatedModelSceneActorMixin:IsActive()
	return not self.elapsedTime or (self.elapsedTime < self.duration);
end

function ScriptAnimatedModelSceneActorMixin:GetModelScene()
	return self:GetParent();
end

function ScriptAnimatedModelSceneActorMixin:OnFinish()
	if self.finishBehavior then
		self.finishBehavior(self.effectDescription, self.source, self.target);
	end

	if self.finishSoundKitID then
		PlaySound(self.finishSoundKitID);
	end

	if self.finishEffectID then
		self:GetModelScene():AddEffect(self.finishEffectID, self.source, self.target);
	end

	if self.externalOnFinish then
		self.externalOnFinish();
	end
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

function ScriptAnimatedModelSceneActorMixin:SetEffect(effectDescription, source, target, externalOnFinish)
	self:SetModelByFileID(effectDescription.visual);
	self:SetAnimation(0, 0, 1);
	self.elapsedTime = nil;

	self.source = source;
	self.target = target;
	self.externalOnFinish = externalOnFinish;

	self.effectDescription = effectDescription;
	self.trajectory = effectDescription.trajectory;
	self.duration = effectDescription.duration;
	self.finishBehavior = effectDescription.finishBehavior;
	self.finishEffectID = effectDescription.finishEffectID;
	self.finishSoundKitID = effectDescription.finishSoundKitID;
	self:SetScale(effectDescription.visualScale);

	if self.source and self.target then
		self:SetYaw(GetAngleForModel(self.source, self.target));
	end

	if effectDescription.startSoundKitID then
		PlaySound(effectDescription.startSoundKitID);
	end

	self:DeltaUpdate(0);
end


ScriptAnimatedModelSceneMixin = {};

function ScriptAnimatedModelSceneMixin:OnLoad()
	ModelSceneMixin.OnLoad(self);

	self.effectActors = {};
end

function ScriptAnimatedModelSceneMixin:OnShow()
	self.centerX, self.centerY = self:GetCenter();
end

function ScriptAnimatedModelSceneMixin:OnUpdate(elapsed, ...)
	ModelSceneMixin.OnUpdate(self, elapsed, ...);

	if not self.centerX then
		self.centerX, self.centerY = self:GetCenter();
	end

	if #self.effectActors == 0 then
		return;
	end

	local remainingActors = {};
	for i, effectActor in ipairs(self.effectActors) do
		if effectActor:IsActive() then
			table.insert(remainingActors, effectActor);
		else
			effectActor:OnFinish();
			self:ReleaseActor(effectActor);
		end
	end

	self.effectActors = remainingActors;

	local modifiedElapsed = elapsed * self:GetEffectSpeed();
	for i, effectActor in ipairs(self.effectActors) do
		effectActor:DeltaUpdate(modifiedElapsed, ...);
	end
end

function ScriptAnimatedModelSceneMixin:SetActiveCamera(...)
	ModelSceneMixin.SetActiveCamera(self, ...);

	self:CalculatePixelsPerSceneUnit();
end

function ScriptAnimatedModelSceneMixin:CalculatePixelsPerSceneUnit()
	local width, height = self:GetSize();
	local sceneSize = Vector2D_GetLength(width, height);
	local activeCamera = self:GetActiveCamera();
	if not activeCamera then
		self.pixelsPerSceneUnit = nil;
		return;
	end

	local zoomDistance = activeCamera:GetZoomDistance();
	self.pixelsPerSceneUnit = (sceneSize * zoomDistance) / SceneUnitDivisor;
end

function ScriptAnimatedModelSceneMixin:AddEffect(effectID, source, target, onFinish)
	local effect = ScriptedAnimationEffectsUtil.GetEffectByID(effectID);

	if effect.startBehavior then
		effect.startBehavior(effect, source, target);
	end

	local actor = self:AcquireActor();
	Mixin(actor, ScriptAnimatedModelSceneActorMixin);
	actor:SetEffect(effect, source, target, onFinish);
	actor:Show();

	table.insert(self.effectActors, actor);
end

function ScriptAnimatedModelSceneMixin:SetEffectSpeed(speed)
	self.effectSpeed = speed;
end

function ScriptAnimatedModelSceneMixin:GetEffectSpeed()
	return self.effectSpeed or 1.0;
end

function ScriptAnimatedModelSceneMixin:ClearEffects()
	for i, effectActor in ipairs(self.effectActors) do
		effectActor:OnFinish();
		self:ReleaseActor(effectActor);
	end

	self.effectActors = {};
end

function ScriptAnimatedModelSceneMixin:SetActorPositionFromPixels(actor, x, y, z)
	local pixelsPerSceneUnit = self.pixelsPerSceneUnit;
	local dx = (x - self.centerX) / pixelsPerSceneUnit;
	local dy = (y - self.centerY) / pixelsPerSceneUnit;
	local actorScaleDivisor = actor:GetScale();
	actor:SetPosition(dx / actorScaleDivisor, dy / actorScaleDivisor, (z or 0) / actorScaleDivisor);
end
