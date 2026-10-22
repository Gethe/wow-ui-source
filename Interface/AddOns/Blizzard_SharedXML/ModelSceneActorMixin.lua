
ModelSceneActorMixin = {};

local DEFAULT_DROP_SHADOW_ALPHA = 0.8;

-- How much larger than the bounding box footprint the drop shadow is drawn.
local DROP_SHADOW_FOOTPRINT_SCALE = 2.0;

-- Long thin models (tails, wings) would otherwise get a shadow many times their height, which blows up under perspective.
local DROP_SHADOW_MAX_HALF_EXTENT_PER_HEIGHT = 1.5;

-- "public" methods
function ModelSceneActorMixin:ApplyFromModelSceneActorInfo(actorInfo)
	self:SetUseCenterForOrigin(actorInfo.useCenterForOriginX, actorInfo.useCenterForOriginY, actorInfo.useCenterForOriginZ);
	self:SetDropShadowEnabled(actorInfo.addDropShadowAtM2Feet);
	self:SetDropShadowAlpha(nil);

	self:SetPosition(actorInfo.position:GetXYZ());
	self:SetYaw(actorInfo.yaw);
	self:SetPitch(actorInfo.pitch);
	self:SetRoll(actorInfo.roll);

	self.requestedScale = nil;

	local actorDisplayInfo = actorInfo.modelActorDisplayID and C_ModelInfo.GetModelSceneActorDisplayInfoByID(actorInfo.modelActorDisplayID);
	if actorDisplayInfo then
		if actorDisplayInfo.animationKitID then
			self:PlayAnimationKit(actorDisplayInfo.animationKitID);
		else
			self:SetAnimation(actorDisplayInfo.animation, actorDisplayInfo.animationVariation, actorDisplayInfo.animSpeed);
		end

		self:SetSpellVisualKit(actorDisplayInfo.spellVisualKitID);

		self:SetAlpha(actorDisplayInfo.alpha);
		self:SetRequestedScale(actorDisplayInfo.scale);
	else
		self:StopAnimationKit();
		self:SetSpellVisualKit(nil);
		self:SetAnimation(0, 0, 1.0);
		self:SetAlpha(1.0);
		self:SetRequestedScale(1.0);
	end

	self:SetNormalizedScaleAggressiveness(actorInfo.normalizeScaleAggressiveness or 0.0);

	self:MarkScaleDirty();
	self:UpdateScale();

	C_ModelInfo.AddActiveModelSceneActor(self, actorInfo.modelActorID);
end

function ModelSceneActorMixin:OnModelCleared()
	C_ModelInfo.ClearActiveModelSceneActor(self);
end

function ModelSceneActorMixin:SetDropShadowEnabled(enabled)
	self.dropShadowEnabled = enabled and true or false;
end

function ModelSceneActorMixin:IsDropShadowEnabled()
	return self.dropShadowEnabled == true;
end

-- Pass nil to go back to the default alpha.
function ModelSceneActorMixin:SetDropShadowAlpha(alpha)
	self.dropShadowAlpha = alpha;
end

function ModelSceneActorMixin:GetDropShadowAlpha()
	return self.dropShadowAlpha or DEFAULT_DROP_SHADOW_ALPHA;
end

-- Returns the center of the ground footprint and its two half-axes in scene space, or nil if the actor has no model bounds yet.
-- Mirrors ModelSceneFrameActor_Shared::UpdateWorldTransform: the model rotates about its bounding box center,
-- then is placed at position * scale. Results are scene units, before the scene scale Transform3DPointTo2D applies.
function ModelSceneActorMixin:GetDropShadowFootprint()
	if not self:IsLoaded() then
		return nil;
	end

	local bottomX, bottomY, bottomZ, topX, topY, topZ = self:GetActiveBoundingBox();
	if not topZ then
		return nil;
	end

	local boxCenterX = (bottomX + topX) * 0.5;
	local boxCenterY = (bottomY + topY) * 0.5;
	local boxCenterZ = (bottomZ + topZ) * 0.5;
	-- Bounding boxes can extend well below the visible model, so stand on the model origin rather than the box bottom.
	local groundZ = math.max(bottomZ, 0) - boxCenterZ;
	local maxHalfExtent = math.max(topZ - math.max(bottomZ, 0), 0) * DROP_SHADOW_MAX_HALF_EXTENT_PER_HEIGHT;
	local halfX = math.min((topX - bottomX) * 0.5 * DROP_SHADOW_FOOTPRINT_SCALE, maxHalfExtent);
	local halfY = math.min((topY - bottomY) * 0.5 * DROP_SHADOW_FOOTPRINT_SCALE, maxHalfExtent);

	local scale = self:GetScale();
	local posX, posY, posZ = self:GetPosition();
	local useCenterX, useCenterY, useCenterZ = self:IsUsingCenterForOrigin();
	local offsetX = (posX + (useCenterX and 0 or boxCenterX)) * scale;
	local offsetY = (posY + (useCenterY and 0 or boxCenterY)) * scale;
	local offsetZ = (posZ + (useCenterZ and 0 or boxCenterZ)) * scale;

	local halfYaw, halfPitch, halfRoll = self:GetYaw() * 0.5, self:GetPitch() * 0.5, self:GetRoll() * 0.5;
	local sinYaw, cosYaw = math.sin(halfYaw), math.cos(halfYaw);
	local sinPitch, cosPitch = math.sin(halfPitch), math.cos(halfPitch);
	local sinRoll, cosRoll = math.sin(halfRoll), math.cos(halfRoll);
	local qw = cosRoll * cosPitch * cosYaw + sinRoll * sinPitch * sinYaw;
	local qx = sinRoll * cosPitch * cosYaw - cosRoll * sinPitch * sinYaw;
	local qy = cosRoll * sinPitch * cosYaw + sinRoll * cosPitch * sinYaw;
	local qz = cosRoll * cosPitch * sinYaw - sinRoll * sinPitch * cosYaw;

	-- Quaternion to rotation matrix, applied to row vectors like the engine does.
	local xx, xy, xz = 2 * qx * qx, 2 * qx * qy, 2 * qx * qz;
	local yy, yz, zz = 2 * qy * qy, 2 * qy * qz, 2 * qz * qz;
	local wx, wy, wz = 2 * qw * qx, 2 * qw * qy, 2 * qw * qz;
	local a0, a1, a2 = 1 - (yy + zz), xy + wz, xz - wy;
	local b0, b1, b2 = xy - wz, 1 - (xx + zz), yz + wx;
	local c0, c1, c2 = xz + wy, yz - wx, 1 - (xx + yy);

	return groundZ * c0 * scale + offsetX, groundZ * c1 * scale + offsetY, groundZ * c2 * scale + offsetZ,
		halfX * a0 * scale, halfX * a1 * scale, halfX * a2 * scale,
		halfY * b0 * scale, halfY * b1 * scale, halfY * b2 * scale;
end

function ModelSceneActorMixin:SetOnSizeChangedCallback(onSizeChangedCallback)
	self.onSizeChangedCallback = onSizeChangedCallback;
end

function ModelSceneActorMixin:GetOnSizeChangedCallback()
	return self.onSizeChangedCallback;
end

function ModelSceneActorMixin:SetOnModelLoadedCallback(onModelLoadedCallback)
	self.onModelLoadedCallback = onModelLoadedCallback;
end

function ModelSceneActorMixin:GetOnModelLoadedCallback()
	return self.onModelLoadedCallback;
end

function ModelSceneActorMixin:SetNormalizedScaleAggressiveness(normalizedScaleAggressiveness)
	if self.normalizedScaleAggressiveness ~= normalizedScaleAggressiveness then
		self.normalizedScaleAggressiveness = normalizedScaleAggressiveness;
		self:MarkScaleDirty();
	end
end

function ModelSceneActorMixin:GetNormalizedScaleAggressiveness()
	return self.normalizedScaleAggressiveness or 0;
end

function ModelSceneActorMixin:SetRequestedScale(requestedScale)
	if self.requestedScale ~= requestedScale then
		self.requestedScale = requestedScale;
		self:MarkScaleDirty();
	end
end

function ModelSceneActorMixin:GetRequestedScale()
	return self.requestedScale or self:GetScale();
end

MODEL_SCENE_ACTOR_DIMENSIONS_FOR_NORMALIZATION = { width = .9984, depth = 1.121, height = 2.118 }; -- Roughly the dimensions of a human male model (but why male models?)
function ModelSceneActorMixin:CalculateNormalizedScale(normalizedScaleAggressiveness)
	if self:IsLoaded() and normalizedScaleAggressiveness > 0.0 then
		local bottomX, bottomY, bottomZ, topX, topY, topZ = self:GetActiveBoundingBox(); -- Could be nil for invisible models
		if bottomX and bottomY and bottomZ and topX and topY and topZ then
			local width = topX - bottomX;
			local depth = topY - bottomY;
			local height = topZ - bottomZ;

			local widthScale = width / MODEL_SCENE_ACTOR_DIMENSIONS_FOR_NORMALIZATION.width;
			local depthScale = depth / MODEL_SCENE_ACTOR_DIMENSIONS_FOR_NORMALIZATION.depth;
			local heightScale = height / MODEL_SCENE_ACTOR_DIMENSIONS_FOR_NORMALIZATION.height;

			local maxScale = math.max(widthScale, math.max(depthScale, heightScale));
			if maxScale == 0 then
				return 1.0;
			end

			return 1 / Lerp(1.0, maxScale, normalizedScaleAggressiveness);
		end
	end

	return 1.0;
end

-- "private" methods
function ModelSceneActorMixin:OnReleased()
	self:SetOnSizeChangedCallback(nil);
	self:SetOnModelLoadedCallback(nil);
	self:SetDropShadowEnabled(false);
	self:SetDropShadowAlpha(nil);
end

function ModelSceneActorMixin:OnUpdate()
	self:UpdateScale();
end

function ModelSceneActorMixin:OnModelLoaded()
	self:MarkScaleDirty();

	if self.onModelLoadedCallback then
		self.onModelLoadedCallback(self);
	end
end

function ModelSceneActorMixin:UpdateScale()
	if self.scaleDirty and self:IsLoaded() then
		self.scaleDirty = nil;
		local effectiveScale = self:GetRequestedScale() * self:CalculateNormalizedScale(self:GetNormalizedScaleAggressiveness());
		self:SetScale(effectiveScale);

		if self.onSizeChangedCallback then
			self.onSizeChangedCallback(self);
		end
	end
end

function ModelSceneActorMixin:MarkScaleDirty()
	self.scaleDirty = true;
end
