InputUtil = {};

function InputUtil.GetCurrentInterfaceStyle()
	return C_InputInterfaceStyle.GetCurrentStyle();
end

function InputUtil.IsGamepadUISupported()
	return C_CVar.GetCVar("InputDeviceInterfaceStyle") ~= nil;
end

function InputUtil.IsGamepadUIEnabled()
	return C_InputInterfaceStyle.GetCurrentStyle() == Enum.InputDeviceInterfaceType.Gamepad;
end

function InputUtil.IsMKBUIEnabled()
	return C_InputInterfaceStyle.GetCurrentStyle() == Enum.InputDeviceInterfaceType.Mkb;
end
