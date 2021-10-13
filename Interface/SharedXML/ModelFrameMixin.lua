--------------------------------------------------
-- LOCAL CONSTANTS AND DATA
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
	["KulTiranMale"] = { panMaxLeft = -0.6, panMaxRight = 0.7, panMaxTop = 1.5, panMaxBottom = -0.6, panValue = 38 },
	["KulTiranFemale"] = { panMaxLeft = -0.6, panMaxRight = 0.7, panMaxTop = 1.5, panMaxBottom = -0.6, panValue = 38 },
	["ZandalariTrollMale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.3, panMaxBottom = -0.4, panValue = 27 },
	["ZandalariTrollFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.5, panMaxTop = 1.5, panMaxBottom = -0.4, panValue = 31 },
	["VulperaMale"] = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 0.7, panMaxBottom = -0.2, panValue = 43 },
	["VulperaFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.7, panMaxBottom = -0.3, panValue = 43 },
	["MechagnomeMale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.5, panMaxBottom = -0.2, panValue = 52 },
	["MechagnomeFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.5, panMaxBottom = -0.2, panValue = 60 },
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
--------------------------------------------------


--------------------------------------------------
-- DEFAULT MODEL FRAME MIXIN
ModelFrameMixin = {};

-- Generic model rotation functions
function ModelFrameMixin:OnLoad(maxZoom, minZoom, defaultRotation)
	-- set up data
	self.maxZoom = maxZoom or MODELFRAME_MAX_ZOOM;
	self.minZoom = minZoom or MODELFRAME_MIN_ZOOM;
	self.defaultRotation = defaultRotation or MODELFRAME_DEFAULT_ROTATION;

	self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function ModelFrameMixin:Init()
end

function ModelFrameMixin:OnEvent(event, ...)
	self:RefreshCamera();
end

function ModelFrameMixin:UpdateRotation(leftButton, rightButton, elapsedTime, rotationsPerSecond)
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

function ModelFrameMixin:ApplyRotation(rotation)
	self.rotation = rotation;
	self:SetRotation(rotation);
end

function ModelFrameMixin:OnUpdate(elapsedTime)
	local rotationsPerSecond = ROTATIONS_PER_SECOND;
	
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
		if self.panningFrame then 
			self.panningFrame:SetPoint("BOTTOMLEFT", cursorX / scale - 16, cursorY / scale - 16);	-- half the texture size to center it on the cursor
		end
		-- settings
		local settings;
		local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		if ( hasAlternateForm and inAlternateForm ) then
			settings = ModelSettings[playerRaceSex.."Alt"];
		else
			settings = ModelSettings[playerRaceSex];
		end
		
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

	self:UpdateRotation(leftButton, rightButton, elapsedTime, rotationsPerSecond);
end

function ModelFrameMixin:ResetModel()
	self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:SetPosition(0, 0, 0);
	self.zoomLevel = self.minZoom;
	self:SetPortraitZoom(self.zoomLevel);
end

function ModelFrameMixin:StartPanning(panningFrame)
	if (self.panningFrame and self.panningFrame.model) then
		self.panningFrame.model = nil;
	end

	self.panningFrame = panningFrame;
	
	if ( panningFrame ) then
		self.panningFrame.model = self;
		self.panningFrame:Show();
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

function ModelFrameMixin:StopPanning()
	self.panning = false;
	if self.panningFrame then
		self.panningFrame:Hide();
	end	
end

function ModelFrameMixin:PostMouseUp(button)
	-- override this for your mixins unique mouse up behavior
end

function ModelFrameMixin:PostMouseDown(button)
	-- override this for your mixins unique mouse down behavior
end

function ModelFrameMixin:OnMouseUp(button)

	if ( button == "RightButton" and self.panning ) then
		self:StopPanning();
	elseif ( self.mouseDown ) then
		if ( button == "LeftButton" ) then
			self.mouseDown = false;
		end
		self:PostMouseUp(button);
	end
end

function ModelFrameMixin:OnMouseDown(button)
	if ( button == "RightButton" and not self.mouseDown ) then
		self:StartPanning();
	else
		if ( button == "LeftButton" ) then
			self.mouseDown = true;
			self.rotationCursorStart = GetCursorPosition();
		end
		self:PostMouseDown(button);
	end
end

function ModelFrameMixin:OnMouseWheel(delta, maxZoom, minZoom)
	maxZoom = maxZoom or self.maxZoom;
	minZoom = minZoom or self.minZoom;
	local zoomLevel = self.zoomLevel or minZoom;
	zoomLevel = zoomLevel + delta * MODELFRAME_ZOOM_STEP;
	zoomLevel = min(zoomLevel, maxZoom);
	zoomLevel = max(zoomLevel, minZoom);
	self:SetPortraitZoom(zoomLevel);
	self.zoomLevel = zoomLevel;
end

function ModelFrameMixin:OnEnter()
	self.controlFrame:Show();
end

function ModelFrameMixin:OnLeave()
	local panningFrameIsShown = self.panningFrame and self.panningFrame:IsShown();
	if ( not self.controlFrame:IsMouseOver() and not panningFrameIsShown ) then
		self.controlFrame:Hide();
	end
end

function ModelFrameMixin:OnHide()
	if ( self.panning ) then
		self:StopPanning();
	end
	self.mouseDown = false;
	self.controlFrame:Hide();
end

