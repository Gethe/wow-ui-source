
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