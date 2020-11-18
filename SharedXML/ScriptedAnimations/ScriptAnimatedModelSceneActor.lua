
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

		local i = 1;
		while i <= #self.futureTransformations do
			local transformation = self.futureTransformations[i];
			if self.elapsedTime >= transformation.startTime then
				table.insert(self.activeTransformations, transformation);
				self.futureTransformations[i] = self.futureTransformations[#self.futureTransformations];
				self.futureTransformations[#self.futureTransformations] = nil;
			else
				i = i + 1;
			end
		end

		local j = 1;
		while j <= #self.activeTransformations do
			local transformation = self.activeTransformations[j];
			local data = transformation.data;
			local callback = transformation.overrideCallback or data.transformationCallback;
			local transformationFinished, newTransformationCallback = callback(self, self.elapsedTime - transformation.startTime, data.duration, unpack(data.args, 1, data.args.n));
			if transformationFinished then
				self.activeTransformations[j] = self.activeTransformations[#self.activeTransformations];
				self.activeTransformations[#self.activeTransformations] = nil;
			else
				j = j + 1;

				if newTransformationCallback then
					transformation.overrideCallback = newTransformationCallback;
				end
			end
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
	self:SetAnimation(effectDescription.animation or 0, 0, animationSpeed, effectDescription.animationStartOffset);

	self.elapsedTime = nil;

	self.source = source;
	self.target = target;

	self.effectDescription = effectDescription;
	self.trajectory = effectDescription.trajectory;
	self.duration = effectDescription.duration;
	self:SetScale(effectDescription.visualScale);

	self:SetParticleOverrideScale(effectDescription.particleOverrideScale);

	if self.source and self.target and self.source ~= self.target and not effectDescription.useTargetAsSource then
		self:SetYaw(GetAngleForModel(self.source, self.target));
	else
		self:SetYaw(effectDescription.yawRadians);
	end

	self.futureTransformations = {};
	self.activeTransformations = {};
	if effectDescription.transformations then
		for i, transformation in ipairs(effectDescription.transformations) do
			if transformation.timing == Enum.ScriptedAnimationTransformationTiming.BeginWithEffect then
				table.insert(self.activeTransformations, { startTime = 0, data = transformation, });
			elseif transformation.timing == Enum.ScriptedAnimationTransformationTiming.FinishWithEffect then
				local startTime = self.duration - transformation.duration;
				table.insert(self.futureTransformations, { startTime = startTime, data = transformation, });
			end
		end
	end

	self:SetAlpha(effectDescription.startingAlpha or 1.0);

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
