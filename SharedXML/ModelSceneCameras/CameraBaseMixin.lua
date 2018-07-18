
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
end
---------------

CameraBaseMixin = {};

function CameraBaseMixin:SetOwningScene(owningScene)
	if self.owningScene ~= owningScene then
		if self.owningScene then
			self:OnRemoved();
		end

		self.owningScene = owningScene;

		if self.owningScene then
			self:OnAdded();
		end
	end
end

function CameraBaseMixin:GetOwningScene()
	return self.owningScene;
end

CAMERA_TRANSITION_TYPE_IMMEDIATE = 1; -- Switch to the camera view instantly
CAMERA_TRANSITION_TYPE_INTERPOLATION = 2;  -- Switch to the camera view by interpolating from the current view

CAMERA_MODIFICATION_TYPE_DISCARD = 1; -- Discard any modifications performed to the view by script
CAMERA_MODIFICATION_TYPE_MAINTAIN = 2;  -- Retain any modifications performed to the view by script

-- Override this to handle transitions to a modelSceneCamera data set
function CameraBaseMixin:ApplyFromModelSceneCameraInfo(modelSceneCameraInfo, transitionType, modificationType)

end

-- Common accessors from the owning scene
function CameraBaseMixin:IsLeftMouseButtonDown()
	return self:GetOwningScene():IsLeftMouseButtonDown();
end

function CameraBaseMixin:IsRightMouseButtonDown()
	return self:GetOwningScene():IsRightMouseButtonDown();
end

function CameraBaseMixin:SetPosition(x, y, z)
	self:GetOwningScene():SetCameraPosition(x, y, z);
end

function CameraBaseMixin:GetPosition()
	return self:GetOwningScene():GetCameraPosition();
end

function CameraBaseMixin:GetForwardVector()
	return self:GetOwningScene():GetCameraForward();
end

function CameraBaseMixin:GetRightVector()
	return self:GetOwningScene():GetCameraRight();
end

function CameraBaseMixin:GetUpVector()
	return self:GetOwningScene():GetCameraUp();
end

-- Override this with a uniquely identifying name for the camera type
function CameraBaseMixin:GetCameraType()
	return "UnknownCamera";
end

-- Override this to perform any per-frame updates
function CameraBaseMixin:OnUpdate(elapsed)
end

-- Override this with code to synchronize the camera state with the model scene API, may be called by the ModelScene to synchronize deferred camera state in case it needs to be queried
function CameraBaseMixin:SynchronizeCamera()
end

-- Override this to be notified when the mouse is down on the model scene
function CameraBaseMixin:OnMouseDown(button)
end

-- Override this to be notified when the mouse is up on the model scene
function CameraBaseMixin:OnMouseUp(button)
end

-- Override this to be notified when the mouse wheel is changed on the model scene
function CameraBaseMixin:OnMouseWheel(delta)
end

-- Override this to be notified when the camera is added to a scene
function CameraBaseMixin:OnAdded()
end

-- Override this to be notified when the camera is remove from a scene
function CameraBaseMixin:OnRemoved()
end

-- Override this to be notified when the camera becomes activated
function CameraBaseMixin:OnActivated()
end

-- Override this to be notified when the camera becomes deactivated
function CameraBaseMixin:OnDeactivated()
end