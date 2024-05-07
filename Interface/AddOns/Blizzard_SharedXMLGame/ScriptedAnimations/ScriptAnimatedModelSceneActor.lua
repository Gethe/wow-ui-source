
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
	if self:IsActive() then
		if self.trajectory then
			local positionX, positionY, newTrajectory = self.trajectory(self.source, self.target, self.elapsedTime, self.duration);
			
			if newTrajectory then
				self.trajectory = newTrajectory;
			end

			if positionX and positionY then
				self:GetModelScene():SetActorPositionFromPixels(self, positionX + self.dynamicOffsetX, positionY + self.dynamicOffsetY, self.dynamicOffsetZ);
				self:Show();
			else
				self:Hide();
			end
		end

		if self.fadeInTime ~= nil then
			if self.elapsedTime	< self.fadeInTime then
				local progress =  self.elapsedTime / self.fadeInTime;
				self:SetAlpha(Lerp(self.startAlpha, self.targetAlpha, progress));
			else
				self.fadeInTime = nil;
				self:SetAlpha(self.targetAlpha);
			end
		elseif (self.fadeOutStart ~= nil) and (self.elapsedTime > self.fadeOutStart) then
			local progress = (self.elapsedTime - self.fadeOutStart) / self.fadeOutTime;
			self:SetAlpha(Lerp(self.targetAlpha, self.endAlpha, progress));
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

function ScriptAnimatedModelSceneActorMixin:SetEffect(effectDescription, source, target, scaleMultiplier)
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
	self:SetAnimation(effectDescription.animation or 0, 0, animationSpeed, effectDescription.animationStartOffset);

	self.elapsedTime = nil;

	self.source = source;
	self.target = target;

	self.effectDescription = effectDescription;
	self.trajectory = effectDescription.trajectory;
	self.duration = effectDescription.duration;
	self:SetScale(effectDescription.visualScale * (scaleMultiplier or 1.0));

	self:SetParticleOverrideScale(effectDescription.particleOverrideScale);

	if self.source and self.target and self.source ~= self.target and not effectDescription.useTargetAsSource then
		self:SetYaw(GetAngleForModel(self.source, self.target));
	else
		self:SetYaw(effectDescription.yawRadians);
	end

	self.targetAlpha = effectDescription.alpha or 1.0;

	self.fadeInTime = effectDescription.startAlphaFadeDuration;
	if self.fadeInTime == nil then
		self.startAlpha = nil;
	else
		self.startAlpha = effectDescription.startAlphaFade or 0;
	end

	self.fadeOutTime = effectDescription.endAlphaFadeDuration;
	if self.fadeOutTime == nil then
		self.endAlpha = nil;
		self.fadeOutStart = nil;
	else
		self.endAlpha = effectDescription.endAlphaFade or 0;
		self.fadeOutStart = effectDescription.duration - self.fadeOutTime;
	end

	self:SetAlpha(effectDescription.startAlpha or self.targetAlpha);

	self:DeltaUpdate(0);
end

function ScriptAnimatedModelSceneActorMixin:SetDynamicOffsets(pixelX, pixelY, pixelZ)
	self.dynamicOffsetX = pixelX or 0;
	self.dynamicOffsetY = pixelY or 0;
	self.dynamicOffsetZ = pixelZ or 0;
end

function ScriptAnimatedModelSceneActorMixin:SetEffectActorOffset(x, y, z)
	self:SetPosition(self.baseOffsetX + x, self.baseOffsetY + y, self.baseOffsetZ + z);
end
