MODELFRAME_DRAG_ROTATION_CONSTANT = 0.010;
MODELFRAME_MAX_ZOOM = 0.7;
MODELFRAME_MIN_ZOOM = 0.0;
MODELFRAME_ZOOM_STEP = 0.15;
MODELFRAME_DEFAULT_ROTATION = 0.61;
ROTATIONS_PER_SECOND = .5;
MODELFRAME_MAX_PLAYER_ZOOM = 0.8;


-- Generic model rotation functions
function Model_OnLoad(self, maxZoom, minZoom, defaultRotation, onMouseUp)
	-- set up data
	self.maxZoom = maxZoom or MODELFRAME_MAX_ZOOM;
	self.minZoom = minZoom or MODELFRAME_MIN_ZOOM;
	self.defaultRotation = defaultRotation or MODELFRAME_DEFAULT_ROTATION;
	self.onMouseUpFunc = onMouseUp or Model_OnMouseUp;

	self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function Model_OnEvent(self, event, ...)
	self:RefreshCamera();
end

function Model_OnMouseDown(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = true;
		model.rotationCursorStart = GetCursorPosition();
	end
end

function Model_OnMouseUp(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = false;
	end
end

function Model_OnMouseWheel(self, delta, maxZoom, minZoom)
	maxZoom = maxZoom or self.maxZoom;
	minZoom = minZoom or self.minZoom;
	local zoomLevel = self.zoomLevel or minZoom;
	zoomLevel = zoomLevel + delta * MODELFRAME_ZOOM_STEP;
	zoomLevel = min(zoomLevel, maxZoom);
	zoomLevel = max(zoomLevel, minZoom);
	self:SetPortraitZoom(zoomLevel);
	self.zoomLevel = zoomLevel;
end

function Model_UpdateRotation(self, leftButton, rightButton, elapsedTime, rotationsPerSecond)
	rotationsPerSecond = rotationsPerSecond or ROTATIONS_PER_SECOND;
	
	if ( rightButton and rightButton:GetButtonState() == "PUSHED" ) then
		self.rotation = self.rotation + (elapsedTime * 2 * PI * rotationsPerSecond);
		if ( self.rotation > (2 * PI) ) then
			self.rotation = self.rotation - (2 * PI);
		end
		self:SetRotation(self.rotation);
	elseif ( leftButton and leftButton:GetButtonState() == "PUSHED" ) then
		self.rotation = self.rotation - (elapsedTime * 2 * PI * rotationsPerSecond);
		if ( self.rotation < 0 ) then
			self.rotation = self.rotation + (2 * PI);
		end
		self:SetRotation(self.rotation);
	end
end

MODELFRAME_UI_CAMERA_POSITION = { x = 4, y = 0, z = 0, };
MODELFRAME_UI_CAMERA_TARGET = { x = 0, y = 0, z = 0, };

function Model_ApplyUICamera(self, uiCameraID)
	local posX, posY, posZ, yaw, pitch, roll, animId, animVariation, animFrame, centerModel = GetUICameraInfo(uiCameraID);
	if posX and posY and posZ and yaw and pitch and roll then
		self:MakeCurrentCameraCustom();

		self:SetPosition(posX, posY, posZ);
		self:SetFacing(yaw);
		self:SetPitch(pitch);
		self:SetRoll(roll);
		self:UseModelCenterToTransform(centerModel);

		local cameraX, cameraY, cameraZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_POSITION.x, MODELFRAME_UI_CAMERA_POSITION.y, MODELFRAME_UI_CAMERA_POSITION.z);
		local targetX, targetY, targetZ = self:TransformCameraSpaceToModelSpace(MODELFRAME_UI_CAMERA_TARGET.x, MODELFRAME_UI_CAMERA_TARGET.y, MODELFRAME_UI_CAMERA_TARGET.z);

		self:SetCameraPosition(cameraX, cameraY, cameraZ);
		self:SetCameraTarget(targetX, targetY, targetZ);
	end
	if( animId and animFrame ~= -1 and animId ~= -1 ) then
		self:FreezeAnimation(animId, animVariation, animFrame);
	else
		self:SetAnimation(0, 0);
	end
end