MODELFRAME_DRAG_ROTATION_CONSTANT = 0.010;
MODELFRAME_MAX_ZOOM = 0.7;
MODELFRAME_MIN_ZOOM = 0.0;
MODELFRAME_ZOOM_STEP = 0.15;
MODELFRAME_DEFAULT_ROTATION = 0.61;
ROTATIONS_PER_SECOND = .5;
MODELFRAME_MAX_PLAYER_ZOOM = 0.8;

local ModelSettings = {
	["HumanMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 38 },
	["HumanFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 1.2, panMaxBottom = -0.2, panValue = 45 },
	["OrcMale"] = { panMaxLeft = -0.7, panMaxRight = 0.8, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 30 },
	["OrcFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.3, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 37 },
	["DwarfMale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.9, panMaxBottom = -0.2, panValue = 44 },
	["DwarfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.9, panMaxBottom = -0.2, panValue = 47 },
	["NightElfMale"] = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 1.5, panMaxBottom = -0.4, panValue = 30 },
	["NightElfFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.4, panMaxBottom = -0.4, panValue = 33 },
	["ScourgeMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.1, panMaxBottom = -0.3, panValue = 35 },
	["ScourgeFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 1.1, panMaxBottom = -0.3, panValue = 36 },
	["TaurenMale"] = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 1.1, panMaxBottom = -0.5, panValue = 31 },
	["TaurenFemale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.3, panMaxBottom = -0.4, panValue = 32 },
	["GnomeMale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.5, panMaxBottom = -0.2, panValue = 52 },
	["GnomeFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.5, panMaxBottom = -0.2, panValue = 60 },
	["TrollMale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.3, panMaxBottom = -0.4, panValue = 27 },
	["TrollFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.5, panMaxBottom = -0.4, panValue = 31 },
	["GoblinMale"] = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.7, panMaxBottom = -0.2, panValue = 43 },
	["GoblinFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.7, panMaxBottom = -0.3, panValue = 43 },
	["BloodElfMale"] = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 1.3, panMaxBottom = -0.3, panValue = 36 },
	["BloodElfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 38 },
	["DraeneiMale"] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 1.4, panMaxBottom = -0.4, panValue = 28 },
	["DraeneiFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 1.4, panMaxBottom = -0.3, panValue = 31 },
	["WorgenMale"] = { panMaxLeft = -0.6, panMaxRight = 0.8, panMaxTop = 1.2, panMaxBottom = -0.4, panValue = 25 },
	["WorgenMaleAlt"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.3, panMaxBottom = -0.3, panValue = 37 },
	["WorgenFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 1.4, panMaxBottom = -0.4, panValue = 25 },
	["WorgenFemaleAlt"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 1.2, panMaxBottom = -0.2, panValue = 45 },
	["PandarenMale"] = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 1.1, panMaxBottom = -0.5, panValue = 31 },
	["PandarenFemale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.3, panMaxBottom = -0.4, panValue = 32 },	
	["NightborneMale"] = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 1.5, panMaxBottom = -0.4, panValue = 30 },
	["NightborneFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.4, panMaxBottom = -0.4, panValue = 33 },
	["HighmountainTaurenMale"] = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 1.1, panMaxBottom = -0.5, panValue = 31 },
	["HighmountainTaurenFemale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.3, panMaxBottom = -0.4, panValue = 32 },
	["VoidElfMale"] = { panMaxLeft = -0.5, panMaxRight = 0.4, panMaxTop = 1.3, panMaxBottom = -0.3, panValue = 36 },
	["VoidElfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.2, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 38 },
	["LightforgedDraeneiMale"] = { panMaxLeft = -0.6, panMaxRight = 0.6, panMaxTop = 1.4, panMaxBottom = -0.4, panValue = 28 },
	["LightforgedDraeneiFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 1.4, panMaxBottom = -0.3, panValue = 31 },
	["MagharOrcMale"] = { panMaxLeft = -0.7, panMaxRight = 0.8, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 30 },
	["MagharOrcFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.3, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 37 },
	["DarkIronDwarfMale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.9, panMaxBottom = -0.2, panValue = 44 },
	["DarkIronDwarfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.9, panMaxBottom = -0.2, panValue = 47 },
}

local playerRaceSex;
if ( not IsOnGlueScreen() ) then
	local _;
	_, playerRaceSex = UnitRace("player");
	if ( UnitSex("player") == 2 ) then
		playerRaceSex = playerRaceSex.."Male";
	else
		playerRaceSex = playerRaceSex.."Female";
	end
end

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

function Model_RotateLeft(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation + rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end

function Model_RotateRight(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation - rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
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

function Model_OnUpdate(self, elapsedTime, rotationsPerSecond)
	if ( not rotationsPerSecond ) then
		rotationsPerSecond = ROTATIONS_PER_SECOND;
	end
	
	-- Mouse drag rotation
	if (self.mouseDown) then
		if ( self.rotationCursorStart ) then
			local x = GetCursorPosition();
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT;
			self.rotationCursorStart = GetCursorPosition();
			self.rotation = self.rotation + diff;
			if ( self.rotation < 0 ) then
				self.rotation = self.rotation + (2 * PI);
			end
			if ( self.rotation > (2 * PI) ) then
				self.rotation = self.rotation - (2 * PI);
			end
			self:SetRotation(self.rotation, false);
		end
	elseif ( self.panning ) then
		local modelScale = self:GetModelScale();
		local cursorX, cursorY = GetCursorPosition();
		local scale = UIParent:GetEffectiveScale();
		ModelPanningFrame:SetPoint("BOTTOMLEFT", cursorX / scale - 16, cursorY / scale - 16);	-- half the texture size to center it on the cursor
		-- settings
		local settings = ModelSettings[playerRaceSex];
		
		local zoom = self.zoomLevel or self.minZoom;
		zoom = 1 + zoom - self.minZoom;	-- want 1 at minimum zoom

		-- Panning should require roughly the same mouse movement regardless of zoom level so the model moves at the same rate as the cursor
		-- This formula more or less works for all zoom levels, found via trial and error
		local transformationRatio = settings.panValue * 2 ^ (zoom * 2) * scale / modelScale;

		local dx = (cursorX - self.cursorX) / transformationRatio;
		local dy = (cursorY - self.cursorY) / transformationRatio;
		local cameraY = self.cameraY + dx;
		local cameraZ = self.cameraZ + dy;
		-- bounds
		scale = scale * modelScale;
		local maxCameraY = settings.panMaxRight * scale;
		cameraY = min(cameraY, maxCameraY);
		local minCameraY = settings.panMaxLeft * scale;
		cameraY = max(cameraY, minCameraY);
		local maxCameraZ = settings.panMaxTop * scale;
		cameraZ = min(cameraZ, maxCameraZ);
		local minCameraZ = settings.panMaxBottom * scale;
		cameraZ = max(cameraZ, minCameraZ);

		self:SetPosition(self.cameraX, cameraY, cameraZ);	
	end
	
	-- Rotate buttons
	local leftButton, rightButton;
	if ( self.controlFrame ) then
		leftButton = self.controlFrame.rotateLeftButton;
		rightButton = self.controlFrame.rotateRightButton;
	else
		leftButton = self.RotateLeftButton or (self:GetName() and _G[self:GetName().."RotateLeftButton"]);
		rightButton = self.RotateRightButton or (self:GetName() and _G[self:GetName().."RotateRightButton"]);
	end

	Model_UpdateRotation(self, leftButton, rightButton, elapsedTime, rotationsPerSecond);
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

function Model_SetDefaultRotation(self, rotation)
	self.defaultRotation = rotation;
	self.rotation = rotation;
	self:SetRotation(rotation);
end

function Model_Reset(self)
	self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:SetPosition(0, 0, 0);
	self.zoomLevel = self.minZoom;
	self:SetPortraitZoom(self.zoomLevel);
end

function Model_StartPanning(self, usePanningFrame)
	if ( usePanningFrame ) then
		ModelPanningFrame.model = self;
		ModelPanningFrame:Show();
	end
	self.panning = true;
	local cameraX, cameraY, cameraZ = self:GetPosition();
	self.cameraX = cameraX;
	self.cameraY = cameraY;
	self.cameraZ = cameraZ;
	local cursorX, cursorY = GetCursorPosition();
	self.cursorX = cursorX;
	self.cursorY = cursorY;
end

function Model_StopPanning(self)
	self.panning = false;
	ModelPanningFrame:Hide();
end

function ModelControlButton_OnMouseDown(self)
	self.bg:SetTexCoord(0.01562500, 0.26562500, 0.14843750, 0.27343750);
	self.icon:SetPoint("CENTER", 1, -1);
	self:GetParent().buttonDown = self;
end

function ModelControlButton_OnMouseUp(self)
	self.bg:SetTexCoord(0.29687500, 0.54687500, 0.14843750, 0.27343750);
	self.icon:SetPoint("CENTER", 0, 0);
	self:GetParent().buttonDown = nil;
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