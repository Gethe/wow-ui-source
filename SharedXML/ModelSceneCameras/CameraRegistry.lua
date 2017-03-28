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

CameraRegistry = { cameraTypeToFactoryFunction = {}, };

function CameraRegistry:AddCameraFactory(cameraTypeName, factoryFunction)
	self.cameraTypeToFactoryFunction[cameraTypeName] = factoryFunction;
end

function CameraRegistry:AddCameraFactoryFromMixin(cameraTypeName, mixin)
	self:AddCameraFactory(cameraTypeName, function() return CreateFromMixins(mixin); end);
end

function CameraRegistry:CreateCameraByType(cameraTypeName)
	if self.cameraTypeToFactoryFunction[cameraTypeName] then
		return self.cameraTypeToFactoryFunction[cameraTypeName]();
	end
end