
ModelSceneMixin = {}

-- "public" functions
function ModelSceneMixin:OnLoad()
	self.cameras = {};
	self.actorTemplate = "ModelSceneActorTemplate";
	self.tagToActor = {};
	self.tagToCamera = {};

	if self.allowOverlappedModels then
		self:SetAllowOverlappedModels(true);
	end
end

function ModelSceneMixin:ClearScene()
	self.modelSceneID = nil;

	self:ReleaseAllActors();
	self:ReleaseAllCameras();

	C_ModelInfo.ClearActiveModelScene(self);
end

function ModelSceneMixin:GetModelSceneID()
	return self.modelSceneID;
end

-- Adjusts this scene to mirror a model scene from static data without transition
function ModelSceneMixin:SetFromModelSceneID(modelSceneID, forceEvenIfSame, noAutoCreateActors)
	local modelSceneType, cameraIDs, actorIDs = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
	if not modelSceneType then
		return;
	end

	if self.modelSceneID ~= modelSceneID or forceEvenIfSame then
		self.modelSceneID = modelSceneID;
		self:ReleaseAllActors();
		self:ReleaseAllCameras();

		if not noAutoCreateActors then
			for actorIndex, actorID in ipairs(actorIDs) do
				self:CreateActorFromScene(actorID);
			end
		end

		for cameraIndex, cameraID in ipairs(cameraIDs) do
			self:CreateCameraFromScene(cameraID);
		end
	end

	C_ModelInfo.AddActiveModelScene(self, self.modelSceneID);
	EventRegistry:TriggerEvent("ModelScene.SetFromModelSceneID", self, self.modelSceneID);
end

function ModelSceneMixin:SetResetCallback(callback)
	self.resetCallback = callback;
end

function ModelSceneMixin:Reset()
	if self.modelSceneID then
		self:TransitionToModelSceneID(self.modelSceneID, self.cameraTransitionType, self.cameraModificationType, self.forceEvenIfSame);
		if self.resetCallback then
			self.resetCallback(self);
		end
	end
end

-- Adjusts this scene to mirror a model scene from static data but with transition effects
-- Only actors/cameras with script tags will be transitioned
function ModelSceneMixin:TransitionToModelSceneID(modelSceneID, cameraTransitionType, cameraModificationType, forceEvenIfSame)
	local modelSceneType, cameraIDs, actorIDs = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
	if not modelSceneType or #cameraIDs == 0 or #actorIDs == 0 then
		return;
	end

	if self.modelSceneID ~= modelSceneID or forceEvenIfSame then
		self.modelSceneID = modelSceneID;
		self.cameraTransitionType = cameraTransitionType;
		self.cameraModificationType = cameraModificationType;
		self.forceEvenIfSame = forceEvenIfSame;

		local actorsToRelease = {};
		for actor in self:EnumerateActiveActors() do
			actorsToRelease[actor] = true;
		end

		local oldTagToActor = self.tagToActor;
		self.tagToActor = {};

		for actorIndex, actorID in ipairs(actorIDs) do
			local actor = self:CreateOrTransitionActorFromScene(oldTagToActor, actorID);
			if actor then
				actorsToRelease[actor] = nil;
			end
		end

		for actor in pairs(actorsToRelease) do
			self.actorPool:Release(actor);
		end

		local oldTagToCamera = self.tagToCamera;
		self.tagToCamera = {};

		self.cameras = {};

		local needsNewCamera = true;
		for cameraIndex, cameraID in ipairs(cameraIDs) do
			local camera = self:CreateOrTransitionCameraFromScene(oldTagToCamera, cameraTransitionType, cameraModificationType, cameraID);
			if camera == self.activeCamera then
				needsNewCamera = false;
			end
		end

		if needsNewCamera then
			self:SetActiveCamera(self.cameras[1]);
		end
	end

	C_ModelInfo.AddActiveModelScene(self, self.modelSceneID);
	EventRegistry:TriggerEvent("ModelScene.TransitionToModelSceneID", self, self.modelSceneID);
end

-- There may be inactive (pooled) actors maintained by this scene, these function only returns the active actors
function ModelSceneMixin:GetNumActiveActors()
	return self.actorPool and self.actorPool:GetNumActive() or 0;
end

function ModelSceneMixin:EnumerateActiveActors()
	if self.actorPool then
		return self.actorPool:EnumerateActive();
	end
	return nop;
end

function ModelSceneMixin:GetActorByTag(tag)
	return self.tagToActor[tag];
end

function ModelSceneMixin:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID, usePlayerNativeForm, optionalPlayerRiderTag)
	local playerRiderTag = optionalPlayerRiderTag or "player-rider";
	local playerActor = self:GetPlayerActor(playerRiderTag);
	if (playerActor) then
		if disablePlayerMountPreview or isSelfMount then
			playerActor:ClearModel();
		else
			local sheatheWeapons = true;
			local autoDress = true;
			local hideWeapons = true;

			if C_Glue.IsOnGlueScreen() then
				local characterIndex = nil;  -- defaults to selected character.
				playerActor:SetPlayerModelFromGlues(characterIndex, sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm);
			else
				playerActor:SetModelByUnit("player", sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm);
			end
			local calcMountScale = mountActor:CalculateMountScale(playerActor);
			local inverseScale = 1 / calcMountScale;
			playerActor:SetRequestedScale( inverseScale );
			mountActor:AttachToMount(playerActor, animID, spellVisualKitID);
		end
	end
end

function GetPlayerActorLabelTag(forceAlternateForm, overrideRaceFilename, overrideGender)
	local playerRaceName = overrideRaceFilename;
	local playerGender = overrideGender;
	local playerRaceNameActorTag = nil;
	local hasAlternateForm, inAlternateForm = false, false;
	if not overrideRaceFilename or not overrideGender then
	if C_Glue.IsOnGlueScreen() then
		local characterGuid = GetCharacterGUID(GetCharacterSelection());
		if characterGuid then
			local basicCharacterInfo = GetBasicCharacterInfo(characterGuid);
				playerRaceName = overrideRaceFilename or basicCharacterInfo.raceFilename;
				playerGender = overrideGender or basicCharacterInfo.genderEnum;
		end
	else
		hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		local _, raceFilename = UnitRace("player");
			playerRaceName = overrideRaceFilename or raceFilename;
			playerGender = overrideGender or UnitSex("player");
		end
	end
	if not playerRaceName or not playerGender then
		return playerRaceName, playerRaceNameActorTag;
	end
	playerRaceName = playerRaceName:lower();
	if hasAlternateForm and (inAlternateForm or forceAlternateForm) then
		playerRaceName = playerRaceName.."-alt";
	end
	playerGender = (playerGender == 2) and "male" or "female";
	playerRaceNameActorTag = playerRaceName.."-"..playerGender;
	return playerRaceName, playerRaceNameActorTag;
end

function ModelSceneMixin:GetPlayerActor(overrideActorName, forceAlternateForm, overrideRaceFilename, overrideGender)
	local actor;
	if overrideActorName then
		actor = self:GetActorByTag(overrideActorName);
	else
		local playerRaceName, playerRaceNameActorTag = GetPlayerActorLabelTag(forceAlternateForm, overrideRaceFilename, overrideGender);
		actor = self:GetActorByTag(playerRaceNameActorTag);
		if not actor then
			actor = self:GetActorByTag(playerRaceName);
			if not actor then
				actor = self:GetActorByTag("player");
				if not actor then
					actor = self:GetActorByTag("player-rider");
				end
			end
		end
	end
	return actor;
end

function ModelSceneMixin:ReleaseAllActors()
	if self.actorPool then
		self.actorPool:ReleaseAll();
		self:ReleaseAllDropShadows();

		self.tagToActor = {};
	end
end

local function OnReleased(actorPool, actor)
	actor:OnReleased();
	ActorPool_HideAndClearModel(actorPool, actor);
end

function ModelSceneMixin:AcquireActor()
	if not self.actorPool then
		self.actorPool = CreateActorPool(self, self.actorTemplate, OnReleased);
	end
	return self.actorPool:Acquire();
end

function ModelSceneMixin:ReleaseActor(actor)
	if not actor or not self.actorPool then
		return;
	end

	for tag, taggedActor in pairs(self.tagToActor) do
		if actor == taggedActor then
			self.tagToActor[tag] = nil;
			break;
		end
	end

	self:ReleaseDropShadow(actor);

	return self.actorPool:Release(actor);
end

function ModelSceneMixin:AcquireAndInitializeActor(actorInfo)
	local actor = self:AcquireActor();
	self:InitializeActor(actor, actorInfo);
	return actor;
end

function ModelSceneMixin:ReleaseAllCameras()
	self:SetActiveCamera(nil);
	for i = #self.cameras, 1, -1 do
		self.cameras[i]:SetOwningScene(nil);
		self.cameras[i] = nil;
	end
	self.tagToCamera = {};
end

function ModelSceneMixin:GetCameraByTag(tag)
	return self.tagToCamera[tag];
end

function ModelSceneMixin:AddCamera(camera)
	table.insert(self.cameras, camera);

	camera:SetOwningScene(self);

	if not self:HasActiveCamera() then
		self:SetActiveCamera(camera);
	end

	return camera;
end

function ModelSceneMixin:HasActiveCamera()
	return self.activeCamera ~= nil;
end

function ModelSceneMixin:GetActiveCamera()
	return self.activeCamera;
end

function ModelSceneMixin:SetActiveCamera(camera)
	if camera ~= self.activeCamera then
		if self.activeCamera then
			self.activeCamera:OnDeactivated();
		end

		self.activeCamera = camera;

		if self.activeCamera then
			self.activeCamera:OnActivated();
		end
	end
end

function ModelSceneMixin:IsLeftMouseButtonDown()
	return self.isLeftButtonDown;
end

function ModelSceneMixin:IsRightMouseButtonDown()
	return self.isRightButtonDown;
end

function ModelSceneMixin:Transform3DPointTo2D(x, y, z)
	self:SynchronizeActiveCamera();
	return self:Project3DPointTo2D(x, y, z);
end

-- "private" functions
function ModelSceneMixin:OnUpdate(elapsed)
	if self.activeCamera then
		local yawDirection = self.yawDirection;
		local increment = self.increment;
		if yawDirection == "left" then
			self.activeCamera:AdjustYaw(-1, -1, increment);
		elseif yawDirection == "right" then
			self.activeCamera:AdjustYaw(1, 1, increment);
		end

		self.activeCamera:OnUpdate(elapsed);
	end

	self:UpdateDropShadows();
end

function ModelSceneMixin:SynchronizeActiveCamera()
	if self.activeCamera then
		self.activeCamera:SynchronizeCamera();
	end
end

function ModelSceneMixin:OnEnter(button)
	if self.ControlFrame then
		self.ControlFrame:Show();
	end
end

function ModelSceneMixin:OnLeave(button)
	if self.ControlFrame then
		if not self.ControlFrame:IsMouseOver()then
			self.ControlFrame:Hide();
		end
	end
end

function ModelSceneMixin:OnMouseDown(button)
	if button == "LeftButton" then
		self.isLeftButtonDown = true;
	elseif button == "RightButton" then
		self.isRightButtonDown = true;
	end

	if self.activeCamera then
		self.activeCamera:OnMouseDown(button);
	end
end

function ModelSceneMixin:OnMouseUp(button)
	if button == "LeftButton" then
		self.isLeftButtonDown = false;
	elseif button == "RightButton" then
		self.isRightButtonDown = false;
	end

	if self.activeCamera then
		self.activeCamera:OnMouseUp(button);
	end
end

function ModelSceneMixin:OnMouseWheel(delta)
	if self.activeCamera then
		self.activeCamera:OnMouseWheel(delta);
	end
end

function ModelSceneMixin:AdjustCameraYaw(direction, increment)
	if self.activeCamera then
		self.yawDirection = direction;
		self.increment = increment;
	end
end

function ModelSceneMixin:StopCameraYaw()
	self.yawDirection = nil;
	self.increment = nil;
end

function ModelSceneMixin:InitializeActor(actor, actorInfo)
	if actorInfo.scriptTag then
		self.tagToActor[actorInfo.scriptTag] = actor;
	end

	actor:ApplyFromModelSceneActorInfo(actorInfo);

	actor:Show();
end

function ModelSceneMixin:CreateActorFromScene(actorID)
	local actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(actorID);
	return self:AcquireAndInitializeActor(actorInfo);
end

function ModelSceneMixin:CreateOrTransitionActorFromScene(oldTagToActor, actorID)
	local actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(actorID);
	local existingActor = oldTagToActor[actorInfo.scriptTag];
	if existingActor then
		self:InitializeActor(existingActor, actorInfo);
		return existingActor;
	end

	return self:AcquireAndInitializeActor(actorInfo);
end

function ModelSceneMixin:CreateCameraFromScene(modelSceneCameraID)
	local modelSceneCameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(modelSceneCameraID);
	if modelSceneCameraInfo then
		local camera = CameraRegistry:CreateCameraByType(modelSceneCameraInfo.cameraType);
		if camera then
			if modelSceneCameraInfo.scriptTag then
				self.tagToCamera[modelSceneCameraInfo.scriptTag] = camera;
			end
			self:AddCamera(camera);
			camera:ApplyFromModelSceneCameraInfo(modelSceneCameraInfo, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD);
			return camera;
		end
	end
end

function ModelSceneMixin:CreateOrTransitionCameraFromScene(oldTagToCamera, cameraTransitionType, cameraModificationType, modelSceneCameraID)
	local modelSceneCameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(modelSceneCameraID);
	if modelSceneCameraInfo then
		local existingCamera = oldTagToCamera[modelSceneCameraInfo.scriptTag];
		if existingCamera and existingCamera:GetCameraType() == modelSceneCameraInfo.cameraType then
			self.tagToCamera[modelSceneCameraInfo.scriptTag] = existingCamera;

			self:AddCamera(existingCamera);
			existingCamera:ApplyFromModelSceneCameraInfo(modelSceneCameraInfo, cameraTransitionType, cameraModificationType);
			return existingCamera;
		end

		return self:CreateCameraFromScene(modelSceneCameraID);
	end
end

-- actorSettings = {
--	"actorTag" = { startDelay = 0, duration = 0, speed = 1 } -- duration 0 means no automatic stoppage
-- }
function ModelSceneMixin:ShowAndAnimateActors(actorSettings, onFinishedCallback)
	self:Show();
	local totalTime = 0;
	for actorTag, actorInfo in pairs(actorSettings) do
		local actor = self:GetActorByTag(actorTag);
		if actor then
			local runningTime = actorInfo.startDelay + actorInfo.duration;
			if actorInfo.startDelay > 0 then
				actor:SetAnimation(0, 0, 0, 0);
				C_Timer.After(actorInfo.startDelay,
					function()
						actor:SetAnimation(0, 0, actorInfo.speed, 0);
					end
				);
			else
				actor:SetAnimation(0, 0, actorInfo.speed, 0);
			end
			if actorInfo.duration > 0 then
				C_Timer.After(runningTime,
					function()
						actor:SetAnimation(0, 0, 0, 0);
					end
				);
			end
			if runningTime > totalTime then
				totalTime = runningTime;
			end
		end
	end

	if onFinishedCallback and totalTime > 0 then
		C_Timer.After(totalTime, onFinishedCallback);
	end
end

-- Fraction of the footprint half-extent used to probe the screen-space direction of each footprint axis.
local DROP_SHADOW_AXIS_PROBE = 0.25;

-- Some bounding boxes are loose cubes far larger than the visible model, so a shadow is also limited to this fraction of the view on each side of its center.
local DROP_SHADOW_MAX_SCREEN_HALF_EXTENT = 0.5;

-- Texture vertices are upper left, lower left, upper right, lower right. +X is the shadow's long axis and points right.
local DROP_SHADOW_VERTEX_SIGNS_X = { -1, -1, 1, 1 };
local DROP_SHADOW_VERTEX_SIGNS_Y = { 1, -1, 1, -1 };

local dropShadowQuadX = {};
local dropShadowQuadY = {};

-- GxuXformCreateProjection_SG narrows the vertical field of view as the aspect ratio grows.
local function CalculateProjectionHalfTan(fieldOfView, aspectRatio)
	return math.tan(fieldOfView * 0.5 / math.sqrt(aspectRatio * aspectRatio + 1));
end

-- Transform3DPointTo2D maps NDC across the whole frame at the whole-frame aspect ratio, but the renderer draws into the inset view.
-- Undo the full-frame mapping and redo it for the inset view. Its result is also in layout units, not frame units.
local function UpdateDropShadowProjection(modelScene, projection)
	if not modelScene:HasActiveCamera() then
		return false;
	end

	local frameWidth, frameHeight = modelScene:GetSize();
	local insetLeft, insetRight, insetTop, insetBottom = modelScene:GetViewInsets();
	local viewWidth = frameWidth - insetLeft - insetRight;
	local viewHeight = frameHeight - insetTop - insetBottom;
	if frameWidth <= 0 or frameHeight <= 0 or viewWidth <= 0 or viewHeight <= 0 then
		return false;
	end

	local fieldOfView = modelScene:GetCameraFieldOfView();
	local frameAspect = frameWidth / frameHeight;
	local viewAspect = viewWidth / viewHeight;
	local frameHalfTan = CalculateProjectionHalfTan(fieldOfView, frameAspect);
	local viewHalfTan = CalculateProjectionHalfTan(fieldOfView, viewAspect);

	projection.frameWidth = frameWidth;
	projection.frameHeight = frameHeight;
	projection.insetLeft = insetLeft;
	projection.insetBottom = insetBottom;
	projection.viewWidth = viewWidth;
	projection.viewHeight = viewHeight;
	projection.translateX, projection.translateY = modelScene:GetViewTranslation();
	projection.effectiveScale = modelScene:GetEffectiveScale();
	projection.ndcRemapX = (frameHalfTan * frameAspect) / (viewHalfTan * viewAspect);
	projection.ndcRemapY = frameHalfTan / viewHalfTan;
	return true;
end

-- Returns scene frame coordinates for a scene point, or nil if it can't be projected.
-- Callers must synchronize the active camera first.
local function ProjectDropShadowPoint(modelScene, projection, x, y, z)
	local rawX, rawY = modelScene:Project3DPointTo2D(x, y, z);
	if not rawX or not rawY then
		return nil;
	end

	local ndcX = ((rawX / projection.effectiveScale / projection.frameWidth) * 2 - 1) * projection.ndcRemapX;
	local ndcY = ((rawY / projection.effectiveScale / projection.frameHeight) * 2 - 1) * projection.ndcRemapY;
	return projection.insetLeft + (ndcX + 1) * 0.5 * projection.viewWidth + projection.translateX,
		projection.insetBottom + (ndcY + 1) * 0.5 * projection.viewHeight + projection.translateY;
end

-- Like Transform3DPointTo2D, but returns offsets from this frame's bottom left that account for view insets and translation.
function ModelSceneMixin:ProjectPointToFrame(x, y, z)
	self.dropShadowProjection = self.dropShadowProjection or {};
	local projection = self.dropShadowProjection;
	if not UpdateDropShadowProjection(self, projection) then
		return nil;
	end
	self:SynchronizeActiveCamera();
	return ProjectDropShadowPoint(self, projection, x, y, z);
end

-- Fills dropShadowQuadX/Y with the actor's footprint on screen. Returns false if the actor can't be projected.
-- Projecting the corners directly gives a perspective quad that explodes or flips when its near edge approaches the camera,
-- and a texture can only be mapped affinely. Project the center and probe each axis instead to get a parallelogram.
local function CalculateDropShadowQuad(modelScene, projection, actor)
	local footX, footY, footZ, axisXx, axisXy, axisXz, axisYx, axisYy, axisYz = actor:GetDropShadowFootprint();
	if not footX then
		return false;
	end

	axisXx, axisXy, axisXz = axisXx * DROP_SHADOW_AXIS_PROBE, axisXy * DROP_SHADOW_AXIS_PROBE, axisXz * DROP_SHADOW_AXIS_PROBE;
	axisYx, axisYy, axisYz = axisYx * DROP_SHADOW_AXIS_PROBE, axisYy * DROP_SHADOW_AXIS_PROBE, axisYz * DROP_SHADOW_AXIS_PROBE;

	local screenX, screenY = ProjectDropShadowPoint(modelScene, projection, footX, footY, footZ);
	local plusXx, plusXy = ProjectDropShadowPoint(modelScene, projection, footX + axisXx, footY + axisXy, footZ + axisXz);
	local minusXx, minusXy = ProjectDropShadowPoint(modelScene, projection, footX - axisXx, footY - axisXy, footZ - axisXz);
	local plusYx, plusYy = ProjectDropShadowPoint(modelScene, projection, footX + axisYx, footY + axisYy, footZ + axisYz);
	local minusYx, minusYy = ProjectDropShadowPoint(modelScene, projection, footX - axisYx, footY - axisYy, footZ - axisYz);
	if not (screenX and plusXx and minusXx and plusYx and minusYx) then
		return false;
	end

	local halfXx = (plusXx - minusXx) * 0.5 / DROP_SHADOW_AXIS_PROBE;
	local halfXy = (plusXy - minusXy) * 0.5 / DROP_SHADOW_AXIS_PROBE;
	local halfYx = (plusYx - minusYx) * 0.5 / DROP_SHADOW_AXIS_PROBE;
	local halfYy = (plusYy - minusYy) * 0.5 / DROP_SHADOW_AXIS_PROBE;

	local extentX = math.abs(halfXx) + math.abs(halfYx);
	local extentY = math.abs(halfXy) + math.abs(halfYy);
	local clamp = math.min(1,
		extentX > 0 and DROP_SHADOW_MAX_SCREEN_HALF_EXTENT * projection.viewWidth / extentX or 1,
		extentY > 0 and DROP_SHADOW_MAX_SCREEN_HALF_EXTENT * projection.viewHeight / extentY or 1);
	halfXx, halfXy, halfYx, halfYy = halfXx * clamp, halfXy * clamp, halfYx * clamp, halfYy * clamp;

	for i = 1, 4 do
		local signX, signY = DROP_SHADOW_VERTEX_SIGNS_X[i], DROP_SHADOW_VERTEX_SIGNS_Y[i];
		dropShadowQuadX[i] = screenX + signX * halfXx + signY * halfYx;
		dropShadowQuadY[i] = screenY + signX * halfXy + signY * halfYy;
	end
	return true;
end

-- Skews the shadow onto the quad in dropShadowQuadX/Y.
local function PlaceDropShadow(shadowFrame, shadow)
	local left, right, bottom, top = math.huge, -math.huge, math.huge, -math.huge;
	for i = 1, 4 do
		left = math.min(left, dropShadowQuadX[i]);
		right = math.max(right, dropShadowQuadX[i]);
		bottom = math.min(bottom, dropShadowQuadY[i]);
		top = math.max(top, dropShadowQuadY[i]);
	end

	-- A texture can only be anchored as an axis-aligned rectangle, so skew it by moving each vertex onto its projected corner.
	shadow:ClearAllPoints();
	shadow:SetPoint("BOTTOMLEFT", shadowFrame, "BOTTOMLEFT", left, bottom);
	shadow:SetPoint("TOPRIGHT", shadowFrame, "BOTTOMLEFT", right, top);

	for i = 1, 4 do
		local vertexX = DROP_SHADOW_VERTEX_SIGNS_X[i] < 0 and left or right;
		local vertexY = DROP_SHADOW_VERTEX_SIGNS_Y[i] > 0 and top or bottom;
		shadow:SetVertexOffset(i, dropShadowQuadX[i] - vertexX, dropShadowQuadY[i] - vertexY);
	end
end

function ModelSceneMixin:GetOrAcquireDropShadow(actor)
	self.actorDropShadows = self.actorDropShadows or {};

	local shadow = self.actorDropShadows[actor];
	if not shadow then
		if not self.dropShadowPool then
			-- Regions of the scene itself would draw over the 3D content, so use a frame instead. A lower level than the scene can fall under its parent's background.
			self.dropShadowFrame = CreateFrame("Frame", nil, self);
			self.dropShadowFrame:SetAllPoints(self);
			self.dropShadowFrame:SetFrameLevel(self:GetFrameLevel());
			self.dropShadowPool = CreateTexturePool(self.dropShadowFrame, "ARTWORK", 0, "ModelSceneDropShadowTemplate");
		end

		shadow = self.dropShadowPool:Acquire();
		self.actorDropShadows[actor] = shadow;
	end
	return shadow;
end

function ModelSceneMixin:ReleaseDropShadow(actor)
	local shadow = self.actorDropShadows and self.actorDropShadows[actor];
	if shadow then
		self.dropShadowPool:Release(shadow);
		self.actorDropShadows[actor] = nil;
	end
end

function ModelSceneMixin:ReleaseAllDropShadows()
	if self.dropShadowPool then
		self.dropShadowPool:ReleaseAll();
		self.actorDropShadows = {};
	end
end

-- Draws a shadow under every active actor flagged for one, and releases the shadows of actors that no longer qualify.
function ModelSceneMixin:UpdateDropShadows()
	self.dropShadowUpdateID = (self.dropShadowUpdateID or 0) + 1;

	local projection;
	for actor in self:EnumerateActiveActors() do
		if actor:IsDropShadowEnabled() and actor:IsShown() then
			if not projection then
				self.dropShadowProjection = self.dropShadowProjection or {};
				projection = self.dropShadowProjection;
				if not UpdateDropShadowProjection(self, projection) then
					break;
				end
				self:SynchronizeActiveCamera();
			end

			if CalculateDropShadowQuad(self, projection, actor) then
				local shadow = self:GetOrAcquireDropShadow(actor);
				PlaceDropShadow(self.dropShadowFrame, shadow);
				shadow:SetAlpha(actor:GetDropShadowAlpha());
				shadow:Show();
				shadow.updateID = self.dropShadowUpdateID;
			end
		end
	end

	if self.actorDropShadows then
		for actor, shadow in pairs(self.actorDropShadows) do
			if shadow.updateID ~= self.dropShadowUpdateID then
				self:ReleaseDropShadow(actor);
			end
		end
	end
end


PanningModelSceneMixin = CreateFromMixins(ModelSceneMixin);
function PanningModelSceneMixin:TransitionToModelSceneID(modelSceneID, cameraTransitionType, cameraModificationType, forceEvenIfSame)
	ModelSceneMixin.TransitionToModelSceneID(self, modelSceneID, cameraTransitionType, cameraModificationType, forceEvenIfSame);

	local camera = self:GetActiveCamera();
	if camera then
		camera:SetRightMouseButtonXMode(ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL, true);
		camera:SetRightMouseButtonYMode(ORBIT_CAMERA_MOUSE_PAN_VERTICAL, true);
	end
end


NoCameraControlModelSceneMixin = CreateFromMixins(ModelSceneMixin);
function NoCameraControlModelSceneMixin:OnMouseDown(button)
	self.isLeftButtonDown = false;
	self.isRightButtonDown = false;
end

function NoCameraControlModelSceneMixin:OnMouseUp(button)
	self.isLeftButtonDown = false;
	self.isRightButtonDown = false;
end

function NoCameraControlModelSceneMixin:OnMouseWheel(delta)
end
NoZoomModelSceneMixin = CreateFromMixins(ModelSceneMixin);
function NoZoomModelSceneMixin:OnMouseWheel(delta)
end
