
---------------
--NOTE - Please do not change this section without talking to Dan
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens

		Import("GetCharacterInfo");
		Import("GetCharacterSelection");
	else
		Import("UnitRace");
		Import("UnitSex");
	end

	setfenv(1, tbl);

	Import("C_ModelInfo");
	Import("C_PlayerInfo");

	function nop() end;
end
----------------

ModelSceneMixin = {}

-- "public" functions
function ModelSceneMixin:OnLoad()
	self.cameras = {};
	self.actorTemplate = "ModelSceneActorTemplate";
	self.tagToActor = {};
	self.tagToCamera = {};
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

function ModelSceneMixin:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID, usePlayerNativeForm)
	local playerActor = self:GetPlayerActor("player-rider");
	if (playerActor) then
		if disablePlayerMountPreview or isSelfMount then
			playerActor:ClearModel();
		else
			local sheathWeapons = true;
			local autoDress = true;
			local hideWeapons = false;
			if (playerActor:SetModelByUnit("player", sheathWeapons, autoDress, hideWeapons, usePlayerNativeForm)) then
				local calcMountScale = mountActor:CalculateMountScale(playerActor);
				local inverseScale = 1 / calcMountScale; 
				playerActor:SetRequestedScale( inverseScale );
				mountActor:AttachToMount(playerActor, animID, spellVisualKitID);
			else
				playerActor:ClearModel();
				mountActor:ClearModel();
			end
		end
	end
end

function GetPlayerActorLabelTag()
	local playerRaceName;
	local playerGender;
	local playerRaceNameActorTag;
	local hasAlternateForm, inAlternateForm = false, false;
	if IsOnGlueScreen() then
		local _, raceName, raceFilename, _, _, _, _, _, genderEnum = GetCharacterInfo(GetCharacterSelection());
		playerRaceName = raceFilename;
		playerGender = genderEnum;
	else
		hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		local _, raceFilename = UnitRace("player");
		playerRaceName = raceFilename;
		playerGender = UnitSex("player");
	end
	if not playerRaceName or not playerGender then
		return playerRaceName, playerRaceNameActorTag;
	end
	playerRaceName = playerRaceName:lower();
	if hasAlternateForm and inAlternateForm then
		playerRaceName = playerRaceName.."-alt";
	end
	playerGender = (playerGender == 2) and "male" or "female";
	playerRaceNameActorTag = playerRaceName.."-"..playerGender;
	return playerRaceName, playerRaceNameActorTag;
end

function ModelSceneMixin:GetPlayerActor(overrideActorName)
	local actor;
	if overrideActorName then
		actor = self:GetActorByTag(overrideActorName);
	else
		local playerRaceName, playerRaceNameActorTag = GetPlayerActorLabelTag();
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
	if not self.actorPool then
		return;
	end

	for tag, taggedActor in pairs(self.tagToActor) do
		if actor == taggedActor then
			self.tagToActor[tag] = nil;
			break;
		end
	end
	
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
