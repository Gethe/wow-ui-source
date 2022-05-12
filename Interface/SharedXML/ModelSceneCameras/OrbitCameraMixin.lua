--[[
	OrbitCameraMixin - A simple camera that can orbit a target point at a fixed distance.

	The orbit is represented using a distance from a target point in world space and yaw, pitch and roll.
	The yaw, pitch and roll represent the camera's orientation, or inversely the direction of the camera from the target point.

	Optionally, the target, orientation and zoom can have splines that are added to the respective axes. The splines are fed the zoom percentage to calculate the point on the spline.
	This is ideal for changing view points based on zoom distance from the target. For example, target model's face on zoom in and center on the model on zoom out.
]]

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
	end

	setfenv(1, tbl);

	Import("Saturate");
	Import("PercentageBetween");
	Import("Lerp");
	Import("Vector3D_Add");
	Import("Vector3D_Normalize");
	Import("Vector3D_ScaleBy");
	Import("Vector3D_CalculateNormalFromYawPitch");
	Import("Vector3D_CalculateYawPitchFromNormal");
	Import("GetScaledCursorDelta");
	Import("DeltaLerp");
end
---------------

OrbitCameraMixin = CreateFromMixins(CameraBaseMixin);

local CAMERA_NAME = "OrbitCamera";
CameraRegistry:AddCameraFactoryFromMixin(CAMERA_NAME, OrbitCameraMixin);

-- "public" functions
function OrbitCameraMixin:GetCameraType() -- override
	return CAMERA_NAME;
end

local function TryCreateZoomSpline(x, y, z, existingSpline)
	if x and y and z and (x ~= 0 or y ~= 0 or z ~= 0) then
		local spline = existingSpline or CreateCatmullRomSpline(3);
		spline:ClearPoints();
		spline:AddPoint(0, 0, 0);
		spline:AddPoint(x, y, z);

		return spline;
	end
	return nil;
end

function OrbitCameraMixin:ApplyFromModelSceneCameraInfo(modelSceneCameraInfo, transitionType, modificationType) -- override
	self.panningXOffset = 0;
	self.panningYOffset = 0;

	local transitionalCameraInfo = self:CalculateTransitionalValues(self.modelSceneCameraInfo, modelSceneCameraInfo, modificationType);

	self.modelSceneCameraInfo = modelSceneCameraInfo;

	self:SetTarget(transitionalCameraInfo.target:GetXYZ());
	self:SetTargetSpline(TryCreateZoomSpline(transitionalCameraInfo.zoomedTargetOffset:GetXYZ()), self:GetTargetSpline());
	self:SetOrientationSpline(TryCreateZoomSpline(transitionalCameraInfo.zoomedYawOffset, transitionalCameraInfo.zoomedPitchOffset, transitionalCameraInfo.zoomedRollOffset), self:GetOrientationSpline());

	self:SetMinZoomDistance(transitionalCameraInfo.minZoomDistance);
	self:SetMaxZoomDistance(transitionalCameraInfo.maxZoomDistance);

	self:SetZoomDistance(transitionalCameraInfo.zoomDistance);

	self:SetYaw(transitionalCameraInfo.yaw);
	self:SetPitch(transitionalCameraInfo.pitch);
	self:SetRoll(transitionalCameraInfo.roll);

	if transitionType == CAMERA_TRANSITION_TYPE_IMMEDIATE then
		self:SnapAllInterpolatedValues();
	end
	self:UpdateCameraOrientationAndPosition();

	self:SaveInitialTransform(transitionalCameraInfo);
end

function OrbitCameraMixin:SaveInitialTransform(cameraInfo)
	self.initialLightYaw, self.initialLightPitch = Vector3D_CalculateYawPitchFromNormal(Vector3D_Normalize(self:GetOwningScene():GetLightDirection()));
	self.initialCameraYaw, self.initialCameraPitch = self:GetYaw(), self:GetPitch();
end

function OrbitCameraMixin:SetTarget(x, y, z)
	self.targetX, self.targetY, self.targetZ = x, y, z;
end

function OrbitCameraMixin:GetTarget(x, y, z)
	return self.targetX, self.targetY, self.targetZ;
end

function OrbitCameraMixin:SetYaw(yaw)
	self.yaw = yaw;
end

function OrbitCameraMixin:GetYaw()
	return self.yaw;
end

function OrbitCameraMixin:SetPitch(pitch)
	self.pitch = pitch;
end

function OrbitCameraMixin:GetPitch()
	return self.pitch;
end

function OrbitCameraMixin:SetRoll(roll)
	self.roll = roll;
end

function OrbitCameraMixin:GetRoll()
	return self.roll;
end

-- where 100% is fully zoomed out
function OrbitCameraMixin:GetZoomPercent()
	return self.zoomPercent;
end

function OrbitCameraMixin:SetZoomPercent(zoomPercent)
	self.zoomPercent = Saturate(zoomPercent);
end

function OrbitCameraMixin:ZoomByPercent(percent)
	self:SetZoomPercent(self:GetZoomPercent() - percent);
end

function OrbitCameraMixin:SetMaxZoomDistance(distance)
	self.maxZoomDistance = distance;
	if self:GetZoomPercent() then
		self:SetZoomDistance(self:GetZoomDistance());
	end
end

function OrbitCameraMixin:GetMaxZoomDistance()
	return self.maxZoomDistance;
end

function OrbitCameraMixin:SetMinZoomDistance(distance)
	self.minZoomDistance = distance;
	if self:GetZoomPercent() then
		self:SetZoomDistance(self:GetZoomDistance());
	end
end

function OrbitCameraMixin:GetMinZoomDistance()
	return self.minZoomDistance;
end

function OrbitCameraMixin:SetZoomDistance(distance)
	self:SetZoomPercent(self:CalculateZoomPercentFromDistance(distance));
end

function OrbitCameraMixin:CalculateZoomPercentFromDistance(distance)
	if self:GetMinZoomDistance() and self:GetMaxZoomDistance() then
		return PercentageBetween(distance, self:GetMinZoomDistance(), self:GetMaxZoomDistance());
	end
	return 0.0;
end

function OrbitCameraMixin:CalculateZoomDistanceFromPercent(percent)
	if self:GetMinZoomDistance() and self:GetMaxZoomDistance() then
		return Lerp(self:GetMinZoomDistance(), self:GetMaxZoomDistance(), percent);
	end
	return 0.0;
end

function OrbitCameraMixin:GetZoomDistance()
	return self:CalculateZoomDistanceFromPercent(self:GetZoomPercent());
end

function OrbitCameraMixin:ZoomBy(distance)
	self:SetZoomDistance(self:GetZoomDistance() - distance);
end

-- Expects a three dimensional spline where a point of the curve represents a target position
function OrbitCameraMixin:SetTargetSpline(targetSpline)
	self.targetSpline = targetSpline;
end

function OrbitCameraMixin:GetTargetSpline()
	return self.targetSpline;
end

-- Expects a three dimensional spline where a point of the curve represents the camera yaw, pitch, roll
function OrbitCameraMixin:SetOrientationSpline(orientationSpline)
	self.orientationSpline = orientationSpline;
end

function OrbitCameraMixin:GetOrientationSpline()
	return self.orientationSpline;
end

-- Expects an one dimensional spline where a point of the curve represents the camera's distance from the target
function OrbitCameraMixin:SetZoomSpline(zoomSpline)
	self.zoomSpline = zoomSpline;
end

function OrbitCameraMixin:GetZoomSpline()
	return self.zoomSpline;
end

--[[ These return the simple + spline values ]]--
function OrbitCameraMixin:GetDerivedTarget()
	local targetX, targetY, targetZ = self:GetTarget();

	local targetSpline = self:GetTargetSpline();
	if targetSpline then
		return Vector3D_Add(targetX, targetY, targetZ, targetSpline:CalculatePointOnGlobalCurve(1.0 - self:GetZoomPercent()));
	end

	return targetX, targetY, targetZ;
end

function OrbitCameraMixin:GetDerivedOrientation()
	local yaw, pitch, roll = self:GetYaw(), self:GetPitch(), self:GetRoll();

	local orientationSpline = self:GetOrientationSpline();
	if orientationSpline then
		return Vector3D_Add(yaw, pitch, roll, orientationSpline:CalculatePointOnGlobalCurve(1.0 - self:GetZoomPercent()));
	end

	return yaw, pitch, roll;
end

function OrbitCameraMixin:GetDerivedZoomDistance()
	local zoomDistance = self:GetZoomDistance();

	local zoomSpline = self:GetZoomSpline();
	if zoomSpline then
		return zoomDistance + zoomSpline:CalculatePointOnGlobalCurve(1.0 - self:GetZoomPercent());
	end

	return zoomDistance;
end

function OrbitCameraMixin:SetAlignLightToOrbitDelta(alignLightToOrbitDelta)
	if alignLightToOrbitDelta then
		self.modelSceneCameraInfo.flags = bit.bor(self.modelSceneCameraInfo.flags, Enum.ModelSceneSetting.AlignLightToOrbitDelta);
	else
		self.modelSceneCameraInfo.flags = bit.band(self.modelSceneCameraInfo.flags, bit.bnot(Enum.ModelSceneSetting.AlignLightToOrbitDelta));
	end
end

function OrbitCameraMixin:ShouldAlignLightToOrbitDelta()
	return bit.band(self.modelSceneCameraInfo.flags, Enum.ModelSceneSetting.AlignLightToOrbitDelta) == Enum.ModelSceneSetting.AlignLightToOrbitDelta;
end

--[[
	Interpolation API
	For each API, "amount" is the percentage to approach in an "ideal" frame (60 fps), such that setting the value to >= 1 would snap to the desired target and <= 0 would freeze the interpolation.
	Setting to nil will disable the interpolation.
]]

function OrbitCameraMixin:SetYawInterpolationAmount(yawInterpolationAmount)
	self.yawInterpolationAmount = yawInterpolationAmount;
end

function OrbitCameraMixin:GetYawInterpolationAmount()
	return self.yawInterpolationAmount;
end

function OrbitCameraMixin:SetPitchInterpolationAmount(pitchInterpolationAmount)
	self.pitchInterpolationAmount = pitchInterpolationAmount;
end

function OrbitCameraMixin:GetPitchInterpolationAmount()
	return self.pitchInterpolationAmount;
end

function OrbitCameraMixin:SetRollInterpolationAmount(rollInterpolationAmount)
	self.rollInterpolationAmount = rollInterpolationAmount;
end

function OrbitCameraMixin:GetRollInterpolationAmount()
	return self.rollInterpolationAmount;
end

function OrbitCameraMixin:SetTargetInterpolationAmount(targetInterpolationAmount)
	self.targetInterpolationAmount = targetInterpolationAmount;
end

function OrbitCameraMixin:GetTargetInterpolationAmount()
	return self.targetInterpolationAmount;
end

function OrbitCameraMixin:SetZoomInterpolationAmount(zoomInterpolationAmount)
	self.zoomInterpolationAmount = zoomInterpolationAmount;
end

function OrbitCameraMixin:GetZoomInterpolationAmount()
	return self.zoomInterpolationAmount;
end

function OrbitCameraMixin:GetInterpolatedTarget()
	if self.interpolatedTargetX then
		return self.interpolatedTargetX, self.interpolatedTargetY, self.interpolatedTargetZ;
	end
	return self:GetDerivedTarget();
end

function OrbitCameraMixin:GetInterpolatedOrientation()
	if self.interpolatedYaw then
		return self.interpolatedYaw, self.interpolatedPitch, self.interpolatedRoll;
	end
	return self:GetDerivedOrientation();
end

function OrbitCameraMixin:GetInterpolatedZoomDistance()
	if self.interpolatedZoomDistance then
		return self.interpolatedZoomDistance;
	end
	return self:GetDerivedZoomDistance();
end

function OrbitCameraMixin:SnapToTargetInterpolationYaw()
	self.interpolatedYaw = nil;
end

function OrbitCameraMixin:SnapToTargetInterpolationPitch()
	self.interpolatedPitch = nil;
end

function OrbitCameraMixin:SnapToTargetInterpolationRoll()
	self.interpolatedRoll = nil;
end

function OrbitCameraMixin:SnapToTargetInterpolationZoom()
	self.interpolatedZoomDistance = nil;
end

function OrbitCameraMixin:SnapToTargetInterpolationTarget()
	self.interpolatedTargetX = nil;
	self.interpolatedTargetY = nil;
	self.interpolatedTargetZ = nil;
end

function OrbitCameraMixin:SnapAllInterpolatedValues()
	self:SnapToTargetInterpolationYaw();
	self:SnapToTargetInterpolationPitch();
	self:SnapToTargetInterpolationRoll();

	self:SnapToTargetInterpolationZoom();

	self:SnapToTargetInterpolationTarget();
end

ORBIT_CAMERA_MOUSE_MODE_NOTHING = 0;
ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION = 1;
ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION = 2;
ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION = 3;
ORBIT_CAMERA_MOUSE_MODE_TARGET_HORIZONTAL = 4;
ORBIT_CAMERA_MOUSE_MODE_TARGET_VERTICAL = 5;
ORBIT_CAMERA_MOUSE_MODE_ZOOM = 6;
ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL = 7;
ORBIT_CAMERA_MOUSE_PAN_VERTICAL = 8;

function OrbitCameraMixin:SetLeftMouseButtonXMode(mouseMode, snap)
	self.buttonModes.leftX = mouseMode;
	self.buttonModes.leftXinterpolate = not snap;
end

function OrbitCameraMixin:GetLeftMouseButtonXMode()
	return self.buttonModes.leftX, not self.buttonModes.leftXinterpolate;
end

function OrbitCameraMixin:SetLeftMouseButtonYMode(mouseMode, snap)
	self.buttonModes.leftY = mouseMode;
	self.buttonModes.leftYinterpolate = not snap;
end

function OrbitCameraMixin:GetLeftYMouseButtonYMode()
	return self.buttonModes.leftY, not self.buttonModes.leftYinterpolate;
end

function OrbitCameraMixin:SetRightMouseButtonXMode(mouseMode, snap)
	self.buttonModes.rightX = mouseMode;
	self.buttonModes.rightXinterpolate = not snap;
end

function OrbitCameraMixin:GetRightMouseButtonXMode()
	return self.buttonModes.rightX, not self.buttonModes.rightXinterpolate;
end

function OrbitCameraMixin:SetRightMouseButtonYMode(mouseMode, snap)
	self.buttonModes.rightY = mouseMode;
	self.buttonModes.rightYinterpolate = not snap;
end

function OrbitCameraMixin:GetRightMouseButtonYMode()
	return self.buttonModes.rightY, not self.buttonModes.rightYinterpolate;
end

function OrbitCameraMixin:SetMouseWheelMode(mouseMode, snap)
	self.buttonModes.wheel = mouseMode;
	self.buttonModes.wheelInterpolate = not snap;
end

function OrbitCameraMixin:GetMouseWheelMode()
	return self.buttonModes.wheel, not self.buttonModes.wheelInterpolate;
end

function OrbitCameraMixin:HandleMouseMovement(mode, delta, snapToValue)
	if mode == ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION then
		self:SetYaw(self:GetYaw() - delta);
		if snapToValue then
			self:SnapToTargetInterpolationYaw();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION then
		self:SetPitch(self:GetPitch() - delta);
		if snapToValue then
			self:SnapToTargetInterpolationPitch();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION then
		self:SetRoll(self:GetRoll() - delta);
		if snapToValue then
			self:SnapToTargetInterpolationRoll();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_ZOOM then
		self:ZoomByPercent(delta);
		if snapToValue then
			self:SnapToTargetInterpolationZoom();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_HORIZONTAL then
		local rightX, rightY, rightZ = Vector3D_ScaleBy(delta, self:GetRightVector());
		self:SetTarget(Vector3D_Add(rightX, rightY, rightZ, self:GetTarget()));

		if snapToValue then
			self:SnapToTargetInterpolationTarget();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_VERTICAL then
		local upX, upY, upZ = Vector3D_ScaleBy(delta, self:GetUpVector());
		self:SetTarget(Vector3D_Add(upX, upY, upZ, self:GetTarget()));

		if snapToValue then
			self:SnapToTargetInterpolationTarget();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL then
		self.panningXOffset = self.panningXOffset + delta;
	elseif mode == ORBIT_CAMERA_MOUSE_PAN_VERTICAL then
		self.panningYOffset = self.panningYOffset + delta;
	end
end

function OrbitCameraMixin:ResetDefaultInputModes()
	self:SetLeftMouseButtonXMode(ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION, true);
	self:SetLeftMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING);
	self:SetRightMouseButtonXMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING);
	self:SetRightMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING);
	self:SetMouseWheelMode(ORBIT_CAMERA_MOUSE_MODE_ZOOM, false);
end

-- "private" function
function OrbitCameraMixin:OnAdded() -- override
	self.buttonModes = {};

	self:SetTarget(0, 0, 0);

	local targetSpline = CreateCatmullRomSpline(3);
	targetSpline:AddPoint(0, 0, 0);
	targetSpline:AddPoint(0, 0, .5);

	self:SetTargetSpline(targetSpline);

	self:SetMinZoomDistance(6);
	self:SetMaxZoomDistance(10);

	self:SetZoomDistance(8);

	self:SetYaw(math.pi);
	self:SetPitch(0);
	self:SetRoll(0);

	self:SetZoomInterpolationAmount(.15);
	self:SetYawInterpolationAmount(.15);
	self:SetPitchInterpolationAmount(.15);
	self:SetRollInterpolationAmount(.15);
	self:SetTargetInterpolationAmount(.15);

	self:ResetDefaultInputModes();
end

function OrbitCameraMixin:GetDeltaModifierForCameraMode(mode)
	if mode == ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION then
		return .008;
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION then
		return .008;
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION then
		return .008;
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_ZOOM then
		return .1;
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_HORIZONTAL then
		return .05;
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_VERTICAL then
		return .05;
	elseif mode == ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL then
		return 0.93;
	elseif mode == ORBIT_CAMERA_MOUSE_PAN_VERTICAL then
		return 0.93;
	end
	return 0.0;
end

function OrbitCameraMixin:OnUpdate(elapsed) -- override
	if self:IsLeftMouseButtonDown() then
		local deltaX, deltaY = GetScaledCursorDelta();
		self:HandleMouseMovement(self.buttonModes.leftX, deltaX * self:GetDeltaModifierForCameraMode(self.buttonModes.leftX), not self.buttonModes.leftXinterpolate);
		self:HandleMouseMovement(self.buttonModes.leftY, -deltaY * self:GetDeltaModifierForCameraMode(self.buttonModes.leftY), not self.buttonModes.leftYinterpolate);
	end

	if self:IsRightMouseButtonDown() then
		local deltaX, deltaY = GetScaledCursorDelta();
		self:HandleMouseMovement(self.buttonModes.rightX, deltaX * self:GetDeltaModifierForCameraMode(self.buttonModes.rightX), not self.buttonModes.rightXinterpolate);
		self:HandleMouseMovement(self.buttonModes.rightY, -deltaY * self:GetDeltaModifierForCameraMode(self.buttonModes.rightY), not self.buttonModes.rightYinterpolate);
	end

	self:UpdateInterpolationTargets(elapsed);
	self:SynchronizeCamera();
end

function OrbitCameraMixin:SynchronizeCamera() -- override
	self:UpdateCameraOrientationAndPosition();
	self:UpdateLight();
end

local function InterpolateDimension(lastValue, targetValue, amount, elapsed)
	return lastValue and amount and DeltaLerp(lastValue, targetValue, amount, elapsed) or targetValue;
end

function OrbitCameraMixin:UpdateInterpolationTargets(elapsed)
	local yaw, pitch, roll = self:GetDerivedOrientation();
	local targetX, targetY, targetZ = self:GetDerivedTarget();
	local zoomDistance = self:GetDerivedZoomDistance();

	self.interpolatedYaw = InterpolateDimension(self.interpolatedYaw, yaw, self.yawInterpolationAmount, elapsed);
	self.interpolatedPitch = InterpolateDimension(self.interpolatedPitch, pitch, self.pitchInterpolationAmount, elapsed);
	self.interpolatedRoll = InterpolateDimension(self.interpolatedRoll, roll, self.rollInterpolationAmount, elapsed);

	self.interpolatedZoomDistance = InterpolateDimension(self.interpolatedZoomDistance, zoomDistance, self.zoomInterpolationAmount, elapsed);

	self.interpolatedTargetX = InterpolateDimension(self.interpolatedTargetX, targetX, self.targetInterpolationAmount, elapsed);
	self.interpolatedTargetY = InterpolateDimension(self.interpolatedTargetY, targetY, self.targetInterpolationAmount, elapsed);
	self.interpolatedTargetZ = InterpolateDimension(self.interpolatedTargetZ, targetZ, self.targetInterpolationAmount, elapsed);
end

function OrbitCameraMixin:UpdateCameraOrientationAndPosition()
	local yaw, pitch, roll = self:GetInterpolatedOrientation();
	local axisAngleX, axisAngleY, axisAngleZ = Vector3D_CalculateNormalFromYawPitch(yaw, pitch);

	local targetX, targetY, targetZ = self:GetInterpolatedTarget();

	local zoomDistance = self:GetInterpolatedZoomDistance();

	-- Panning start --
	-- We want the model to move 1-to-1 with the mouse.
	-- Panning formula: dx / hypotenuse * (zoomDistance - 1 / zoomDistance^3)
	-- It was experimentally determined that adding the additional fudge factor 1/z^3 resulted in better tracking.

	local width = self:GetOwningScene():GetWidth();
	local height = self:GetOwningScene():GetHeight();
	local scaleFactor = math.sqrt(width * width + height * height);
	local zoomFactor = 1;
	if zoomDistance > 1 then
		zoomFactor = zoomDistance - (1 / (zoomDistance * zoomDistance * zoomDistance));
		if zoomFactor < 1 then
			zoomFactor = 1;
		end
	end

	local rightX, rightY, rightZ = Vector3D_ScaleBy((self.panningXOffset / scaleFactor) * zoomFactor, self:GetRightVector());
	local upX, upY, upZ = Vector3D_ScaleBy((self.panningYOffset / scaleFactor) * zoomFactor, self:GetUpVector());

	-- Panning end --

	targetX, targetY, targetZ = Vector3D_Add(targetX, targetY, targetZ, rightX, rightY, rightZ);
	targetX, targetY, targetZ = Vector3D_Add(targetX, targetY, targetZ, upX, upY, upZ);

	self:SetPosition(self:CalculatePositionByDistanceFromTarget(targetX, targetY, targetZ, zoomDistance, axisAngleX, axisAngleY, axisAngleZ));
	self:GetOwningScene():SetCameraOrientationByYawPitchRoll(yaw, pitch, roll);
end

function OrbitCameraMixin:UpdateLight()
	if self:ShouldAlignLightToOrbitDelta() then
		local cameraDeltaYaw = self.interpolatedYaw - self.initialCameraYaw;
		local cameraDeltaPitch = self.interpolatedPitch - self.initialCameraPitch;

		local lightYaw = self.initialLightYaw + cameraDeltaYaw;
		local lightPitch = self.initialLightPitch + cameraDeltaPitch;

		self:GetOwningScene():SetLightDirection(Vector3D_CalculateNormalFromYawPitch(lightYaw, lightPitch));
	end
end

function OrbitCameraMixin:CalculatePositionByDistanceFromTarget(targetX, targetY, targetZ, zoomDistance, axisAngleX, axisAngleY, axisAngleZ)
	local towardsPosX, towardsPosY, towardsPosZ = Vector3D_ScaleBy(-zoomDistance, axisAngleX, axisAngleY, axisAngleZ);
	return Vector3D_Add(towardsPosX, towardsPosY, towardsPosZ, targetX, targetY, targetZ);
end

function OrbitCameraMixin:CalculateTransitionalValues(fromModelSceneCameraInfo, toModelSceneCameraInfo, modificationType)
	if fromModelSceneCameraInfo and modificationType == CAMERA_MODIFICATION_TYPE_MAINTAIN then
		local zoomedTargetOffsetX, zoomedTargetOffsetY, zoomedTargetOffsetZ = 0, 0, 0;

		local targetSpline = self:GetTargetSpline();
		if targetSpline and targetSpline:GetNumPoints() > 0 then
			zoomedTargetOffsetX, zoomedTargetOffsetY, zoomedTargetOffsetZ = targetSpline:GetPoint(targetSpline:GetNumPoints());
		end

		local zoomedYawOffset, zoomedPitchOffset, zoomedRollOffset = 0, 0, 0;
		local orientationSpline = self:GetOrientationSpline();
		if orientationSpline and orientationSpline:GetNumPoints() > 0 then
			zoomedYawOffset, zoomedPitchOffset, zoomedRollOffset = orientationSpline:GetPoint(orientationSpline:GetNumPoints());
		end

		local fromZoomDistancePercent = PercentageBetween(fromModelSceneCameraInfo.zoomDistance, fromModelSceneCameraInfo.minZoomDistance, fromModelSceneCameraInfo.maxZoomDistance);
		local toZoomDistancePercent = PercentageBetween(toModelSceneCameraInfo.zoomDistance, toModelSceneCameraInfo.minZoomDistance, toModelSceneCameraInfo.maxZoomDistance);
		-- Maintain any modifications made by applying the scene delta
		return {
			   target = CreateVector3D(
			   		(self.targetX - fromModelSceneCameraInfo.target.x) + toModelSceneCameraInfo.target.x,
					(self.targetY - fromModelSceneCameraInfo.target.y) + toModelSceneCameraInfo.target.y,
					(self.targetZ - fromModelSceneCameraInfo.target.z) + toModelSceneCameraInfo.target.z
			   ),

			   yaw = (self.yaw - fromModelSceneCameraInfo.yaw) + toModelSceneCameraInfo.yaw,
			   pitch = (self.pitch - fromModelSceneCameraInfo.pitch) + toModelSceneCameraInfo.pitch,
			   roll = (self.roll - fromModelSceneCameraInfo.roll) + toModelSceneCameraInfo.roll,

			   zoomDistance = Lerp(toModelSceneCameraInfo.minZoomDistance, toModelSceneCameraInfo.maxZoomDistance, (self.zoomPercent - fromZoomDistancePercent) + toZoomDistancePercent),
			   minZoomDistance = (self.minZoomDistance - fromModelSceneCameraInfo.minZoomDistance) + toModelSceneCameraInfo.minZoomDistance,
			   maxZoomDistance = (self.maxZoomDistance - fromModelSceneCameraInfo.maxZoomDistance) + toModelSceneCameraInfo.maxZoomDistance,

			   zoomedTargetOffset = CreateVector3D(
					(zoomedTargetOffsetX - fromModelSceneCameraInfo.zoomedTargetOffset.x) + toModelSceneCameraInfo.zoomedTargetOffset.x,
					(zoomedTargetOffsetY - fromModelSceneCameraInfo.zoomedTargetOffset.y) + toModelSceneCameraInfo.zoomedTargetOffset.y,
					(zoomedTargetOffsetZ - fromModelSceneCameraInfo.zoomedTargetOffset.z) + toModelSceneCameraInfo.zoomedTargetOffset.z
			   ),

			   zoomedYawOffset = (zoomedYawOffset - fromModelSceneCameraInfo.zoomedYawOffset) + toModelSceneCameraInfo.zoomedYawOffset,
			   zoomedPitchOffset = (zoomedPitchOffset - fromModelSceneCameraInfo.zoomedPitchOffset) + toModelSceneCameraInfo.zoomedPitchOffset,
			   zoomedRollOffset = (zoomedRollOffset - fromModelSceneCameraInfo.zoomedRollOffset) + toModelSceneCameraInfo.zoomedRollOffset;
		};
	end

	-- Nothing to transition from, just go directly to the values
	return toModelSceneCameraInfo;
end

function OrbitCameraMixin:OnMouseWheel(delta) -- override
	self:HandleMouseMovement(self.buttonModes.wheel, delta * self:GetDeltaModifierForCameraMode(self.buttonModes.wheel), not self.buttonModes.wheelInterpolate);
end

function OrbitCameraMixin:AdjustYaw(deltaX, deltaY, rotationScalar)
	local xRotation = rotationScalar or self:GetDeltaModifierForCameraMode(self.buttonModes.leftX);
	self:HandleMouseMovement(self.buttonModes.leftX, deltaX * xRotation, not self.buttonModes.leftXinterpolate);

	local yRotatation  = rotationScalar or self:GetDeltaModifierForCameraMode(self.buttonModes.leftY);
	self:HandleMouseMovement(self.buttonModes.leftY, -deltaY * yRotatation, not self.buttonModes.leftYinterpolate);
end