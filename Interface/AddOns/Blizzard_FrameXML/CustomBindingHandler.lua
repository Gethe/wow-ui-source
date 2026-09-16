CustomBindingHandler = {};
CustomBindingHandlerMixin = {};

--[[static]] function CustomBindingHandler:CreateHandler(customBindingType)
	local handler = CreateFromMixins(CustomBindingHandlerMixin);
	handler:OnLoad(customBindingType);
	return handler;
end

--[[private]] function CustomBindingHandlerMixin:OnLoad(customBindingType)
	self.customBindingType = customBindingType;
end

--[[private]] function CustomBindingHandlerMixin:CallOnBindingModeActivatedCallback(isActive)
	if self.bindingModeActivatedCallback then
		self.bindingModeActivatedCallback(isActive);
	end
end

--[[private]] function CustomBindingHandlerMixin:CallOnBindingCompletedCallback(completedSuccessfully, keys)
	if self.bindingCompletedCallback then
		self.bindingCompletedCallback(completedSuccessfully, keys);
	end
end

--[[public]] function CustomBindingHandlerMixin:SetOnBindingModeActivatedCallback(callback)
	self.bindingModeActivatedCallback = callback;
end

--[[public]] function CustomBindingHandlerMixin:SetOnBindingCompletedCallback(callback)
	self.bindingCompletedCallback = callback;
end

--[[public]] function CustomBindingHandlerMixin:GetCustomBindingType()
	return self.customBindingType;
end