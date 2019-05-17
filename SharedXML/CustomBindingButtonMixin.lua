--[[
CustomBindingButtonMixin: Utility to mimic game action-binding functionality, while allowing metakeys to be recognized on their own.

Never executes actual bindings, just informs the CustomBindingManager about changes the user made.  The  system than manages the custom
command can choose the appropriate action via CustomBindingManager notifications.

While this mixin could be made to adjust in-game bindings, on its own it has nothing to do with that system, this allows other systems
that exist in parallel to run commands without using the keybind system.

It's currently not allowed for addons to add custom binding types, but that should only prevent this button from appearing in
the keybinds window, it's still permitted that addons can make their own systems that leverage these bindings.

The rules from Blizzard_BindingUI are (mostly) followed, including but not limited to these exceptions
- PrintScreen is bindable

Other caveats are that LMB/RMB aren't bindable, both of them will activate and cancel binding mode.
--]]

CustomBindingButtonMixin = {};

--[[private]] function CustomBindingButtonMixin:OnLoad()
	local preventBindingManagerUpdate = true;
	self:SetBindingModeActive(false, preventBindingManagerUpdate);
	self:EnableKeyboard(false);
end

--[[private]] function CustomBindingButtonMixin:OnClick(button, isDown)
	local isBindingModeButton = self:IsBindingModeButton(button);
	local isButtonRelease = not isDown;

	if isButtonRelease and isBindingModeButton and self.cancelBindingModeOnRelease then
		self.cancelBindingModeOnRelease = false;
		self:NotifyBindingCompleted(false);
		self:EnableKeyboard(false);
	else
		if self:IsBindingModeActive() then
			if isBindingModeButton then
				self.cancelBindingModeOnRelease = true;
			else
				self:OnInput(button, isDown);
			end
		elseif isButtonRelease then
			if isBindingModeButton and not self.cancelBindingModeOnRelease then
				self:SetBindingModeActive(true);
			end

			self.cancelBindingModeOnRelease = nil;
		end
	end
end

--[[private]] function CustomBindingButtonMixin:OnMouseWheel(delta)
	-- Current custom systems don't support mouse wheel events, prevent this from doing anything
	-- event handler exists to prevent event from falling through to next frame.
end

--[[private]] function CustomBindingButtonMixin:OnKeyDown(key)
	self:OnInput(key, true);
end

--[[private]] function CustomBindingButtonMixin:OnKeyUp(key)
	self:OnInput(key, false);
end

--[[private]] function CustomBindingButtonMixin:OnInput(key, isDown)
	local isButtonRelease = not isDown;

	if not self:IsBindingModeActive() then
		-- Receiving an up event after bindings are disabled should disable bind-handling
		if isButtonRelease then
			self:EnableKeyboard(false);
		end

		-- But always return if binding mode wasn't active
		return;
	end

	key = GetConvertedKeyOrButton(key);

	if isDown then
		if not IsMetaKey(key) then
			self.receivedNonMetaKeyInput = true;
		end

		table.insert(self.keys, key);
	end

	CustomBindingManager:SetPendingBind(self:GetCustomBindingType(), self.keys);

	if self.receivedNonMetaKeyInput or isButtonRelease then
		self:NotifyBindingCompleted(true, self.keys);

		if isButtonRelease then
			self:EnableKeyboard(false);
		end
	end
end

--[[private]] function CustomBindingButtonMixin:IsBindingModeButton(button)
	return IsLeftMouseButton(button) or IsRightMouseButton(button);
end

--[[private]] function CustomBindingButtonMixin:SetBindingModeActive(isActive, preventBindingManagerUpdate)
	self.isBindingModeActive = isActive;
	self.receivedNonMetaKeyInput = false;
	self.keys = {};

	BindingButtonTemplate_SetSelected(self, isActive);

	if isActive then
		self:RegisterForClicks("AnyDown", "AnyUp");
		self:EnableKeyboard(true); -- Only enable here, disable later so that this button continues to see keyboard events through the entire key press/release cycle.
	else
		self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	end

	if not preventBindingManagerUpdate then
		CustomBindingManager:OnBindingModeActive(self, isActive);
	end
end

--[[private]] function CustomBindingButtonMixin:NotifyBindingCompleted(completedSuccessfully, keys)
	CustomBindingManager:OnBindingCompleted(self, completedSuccessfully, keys);
	self:SetBindingModeActive(false);
end

--[[private]] function CustomBindingButtonMixin:SetCustomBindingType(customBindingType)
	self.customBindingType = customBindingType;
end

--[[public]] function CustomBindingButtonMixin:GetCustomBindingType()
	return self.customBindingType;
end

--[[public, virtual]] function CustomBindingButtonMixin:OnBindingTextChanged(bindingText)
	self:SetText(bindingText);
end

--[[public]] function CustomBindingButtonMixin:IsBindingModeActive()
	return self.isBindingModeActive;
end

--[[public]] function CustomBindingButtonMixin:GetKeys()
	return self.keys;
end

--[[public]] function CustomBindingButtonMixin:CancelBinding()
	self:NotifyBindingCompleted(false);
	self:EnableKeyboard(false);
end