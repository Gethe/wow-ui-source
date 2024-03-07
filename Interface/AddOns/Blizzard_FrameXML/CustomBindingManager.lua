CustomBindingManager = {};

--[[public]] function CustomBindingManager:RegisterHandlerAndCreateButton(handler, template, parent)
	local button = CreateFrame("BUTTON", nil, parent, template);
	button:SetCustomBindingHandler(handler);

	local customBindingType = handler:GetCustomBindingType();
	button:SetCustomBindingType(customBindingType);
	self:RegisterHandler(customBindingType, handler, button);
	return button;
end

--[[public]] function CustomBindingManager:SetHandlerRegistered(button, registered)
	if registered then
		self:RegisterHandler(button:GetCustomBindingType(), button:GetCustomBindingHandler(), button);
	else
		self:UnregisterHandler(button:GetCustomBindingType(), button:GetCustomBindingHandler());
	end
end

--[[private]] function CustomBindingManager:RegisterHandler(customBindingType, handler, button)
	if not self.handlers then
		self.handlers = {};
	end

	local customBindingType = handler:GetCustomBindingType();
	if not self.handlers[customBindingType] then
		self.handlers[customBindingType] = {};
	end

	self.handlers[customBindingType][handler] = button;
end

--[[private]] function CustomBindingManager:UnregisterHandler(customBindingType, handler)
	if self.handlers and self.handlers[customBindingType] then
		self.handlers[customBindingType][handler] = nil;
	end
end

--[[private]] function CustomBindingManager:OnBindingModeActive(frame, isActive)
	for handler in self:EnumerateHandlers(frame:GetCustomBindingType()) do
		handler:CallOnBindingModeActivatedCallback(isActive);
	end
end

--[[private]] function CustomBindingManager:OnBindingCompleted(frame, completedSuccessfully, keys)
	for handler, frame in self:EnumerateHandlers(frame:GetCustomBindingType()) do
		handler:CallOnBindingCompletedCallback(completedSuccessfully, keys);
	end
end

--[[private]] function CustomBindingManager:SetPendingBind(customBindingType, keys)
	if not self.pendingBinds then
		self.pendingBinds = {};
	end

	local text = GetBindingText(CreateKeyChordStringFromTable(keys));
	self.pendingBinds[customBindingType] = { keys = keys, text = text };

	for handler, button in self:EnumerateHandlers(customBindingType) do
		button:OnBindingTextChanged(text);
	end
end

--[[private]] function CustomBindingManager:GetPendingBind(customBindingType)
	if self.pendingBinds then
		return self.pendingBinds[customBindingType];
	end
end

--[[private]] function CustomBindingManager:ClearPendingBind(customBindingType)
	if self.pendingBinds then
		self.pendingBinds[customBindingType] = nil;
	end
end

--[[private]] function CustomBindingManager:EnumerateHandlers(customBindingType)
	return pairs(self.handlers[customBindingType]);
end

--[[private]] function CustomBindingManager:AddSystem(customBindingType, accessor, mutator)
	if not self.systems then
		self.systems = {};
	end

	self.systems[customBindingType] = { accessor = accessor, mutator = mutator };
end

--[[private]] function CustomBindingManager:QueryAccessor(customBindingType)
	return self.systems[customBindingType].accessor();
end

--[[private]] function CustomBindingManager:MutateValue(customBindingType, value)
	return self.systems[customBindingType].mutator(value);
end

local function GetConvertedBindingText(text)
	return text ~= "" and text;
end

--[[public]] function CustomBindingManager:GetBindingText(customBindingType)
	local pendingBind = self:GetPendingBind(customBindingType);
	if pendingBind then
		return GetConvertedBindingText(pendingBind.text);
	end

	local keys = self:QueryAccessor(customBindingType);
	if keys then
		return GetConvertedBindingText(GetBindingText(table.concat(keys, "-")));
	end
end

--[[public]] function CustomBindingManager:OnDismissed(customBindingType, shouldApply)
	if shouldApply then
		local pendingBind = self:GetPendingBind(customBindingType);
		if pendingBind then
			self:MutateValue(customBindingType, pendingBind.keys);
		end
	end

	self:ClearPendingBind(customBindingType);
end

--[[public]] function CustomBindingManager:Unbind(customBindingType)
	self:SetPendingBind(customBindingType, {});
end

-- Initialize all known custom binding systems...both accessors and mutators operate on tables of key names
--[[private]]
CustomBindingManager:AddSystem(Enum.CustomBindingType.VoicePushToTalk, C_VoiceChat.GetPushToTalkBinding, C_VoiceChat.SetPushToTalkBinding);
