local ACTIVE_INPUT_DEVICE_ICON_SET_UPDATED_EVENT = "ACTIVE_INPUT_DEVICE_ICON_SET_UPDATED";

local INPUT_DEVICE_ICON_SET_MANAGER_EVENTS =
{
	ACTIVE_INPUT_DEVICE_ICON_SET_UPDATED_EVENT,
};

InputDeviceIconSetManager = Mixin(CreateFrame("Frame"), CallbackRegistryMixin);

function InputDeviceIconSetManager:Init()
	self:GenerateCallbackEvents(INPUT_DEVICE_ICON_SET_MANAGER_EVENTS);
	CallbackRegistryMixin.OnLoad(self);

	InputUtil.RegisterInterfaceTransitionCallback(GenerateClosure(self.UpdateActiveInputDeviceIconSet, self));
	InputUtil.RegisterGamepadDeviceConnectedCallback(GenerateClosure(self.OnGamepadDeviceConnected, self));
	CVarCallbackRegistry:RegisterCallback("GamePadSingleActiveID", self.OnGamepadDeviceConnected, self);

	local interfaceStyle = InputUtil.GetCurrentInterfaceStyle();
	self:UpdateActiveInputDeviceIconSet(interfaceStyle);
end

function InputDeviceIconSetManager:UpdateActiveInputDeviceIconSet(interfaceMode)
	if (interfaceMode == Enum.InputDeviceInterfaceType.Gamepad) then
		local newIconSet = self:GetActiveGamepadDeviceIconSet();
		if newIconSet ~= self.activeInputDeviceIconSet then
			self.activeInputDeviceIconSet = newIconSet;
			self:TriggerEvent(ACTIVE_INPUT_DEVICE_ICON_SET_UPDATED_EVENT);
		end
	else
		self.activeInputDeviceIconSet = "Generic"
	end
end

function InputDeviceIconSetManager:GetActiveGamepadDeviceIconSet()
	local activeDeviceID = C_GamePad.GetActiveDeviceID();
	local mappedDevice = C_GamePad.GetDeviceMappedState(activeDeviceID);
	if (mappedDevice) then
		return mappedDevice.labelStyle;
	end
	return "Generic";
end

function InputDeviceIconSetManager:OnGamepadDeviceConnected()
	local interfaceMode = InputUtil.GetCurrentInterfaceStyle();
	if (interfaceMode == Enum.InputDeviceInterfaceType.Gamepad) then
		local activeGamepadDeviceIconSet = self:GetActiveGamepadDeviceIconSet();
		if (activeGamepadDeviceIconSet ~= self.activeInputDeviceIconSet) then
			self.activeInputDeviceIconSet = activeGamepadDeviceIconSet;
			self:TriggerEvent(ACTIVE_INPUT_DEVICE_ICON_SET_UPDATED_EVENT);
		end
	end
end

function InputDeviceIconSetManager:RegisterActiveInputDeviceIconSetUpdatedCallback(callback, owner, ...)
	self:RegisterCallback(ACTIVE_INPUT_DEVICE_ICON_SET_UPDATED_EVENT, callback, owner, ...);
end

function InputDeviceIconSetManager:GetActiveInputDeviceIconSet()
	return self.activeInputDeviceIconSet;
end

InputDeviceIconSetManager:Init();
