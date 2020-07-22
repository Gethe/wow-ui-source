
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
			self:GetModelScene():SetActorPositionFromPixels(self, positionX + self.dynamicOffsetX, positionY + self.dynamicOffsetY, self.dynamicOffsetZ);
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

function ScriptAnimatedModelSceneActorMixin:SetDynamicOffsets(pixelX, pixelY, pixelZ)
	self.dynamicOffsetX = pixelX or 0;
	self.dynamicOffsetY = pixelY or 0;
	self.dynamicOffsetZ = pixelZ or 0;
end

function ScriptAnimatedModelSceneActorMixin:SetEffectActorOffset(x, y, z)
	self:SetPosition(self.baseOffsetX + x, self.baseOffsetY + y, self.baseOffsetZ + z);
end
