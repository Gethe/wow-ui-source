DropDownToggleButtonMixin = {};

function DropDownToggleButtonMixin:OnLoad_Intrinsic()
	self:RegisterForMouse("LeftButtonDown","LeftButtonUp");
end

function DropDownToggleButtonMixin:HandlesGlobalMouseEvent(buttonName, event)
	return event == "GLOBAL_MOUSE_DOWN" and buttonName == "LeftButton";
end