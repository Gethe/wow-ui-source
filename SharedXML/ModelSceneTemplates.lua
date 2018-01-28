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

ModifyOrbitCameraButtonMixin = {}

function ModifyOrbitCameraButtonMixin:OnMouseDown()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function ModifyOrbitCameraButtonMixin:OnMouseUp()
	self:SetScript("OnUpdate", nil);
end

function ModifyOrbitCameraButtonMixin:OnUpdate(elapsed)
	local orbitCamera = self:GetActiveOrbitCamera();
	if orbitCamera then
		orbitCamera:HandleMouseMovement(self.cameraMode, elapsed * self.amountPerSecond, not self.interpolationEnabled);
	end
end

function ModifyOrbitCameraButtonMixin:GetActiveOrbitCamera()
	local modelScene = self:GetParent();
	local camera = modelScene:GetActiveCamera();
	if camera and camera:GetCameraType() == "OrbitCamera" then
		return camera;
	end
end