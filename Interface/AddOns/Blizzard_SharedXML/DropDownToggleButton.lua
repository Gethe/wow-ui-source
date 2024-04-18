DropDownToggleButtonMixin = {};

function DropDownToggleButtonMixin:OnLoad_Intrinsic()
	self:RegisterForMouse("LeftButtonDown","LeftButtonUp");
end

function DropDownToggleButtonMixin:HandlesGlobalMouseEvent(buttonID, event)
	return event == "GLOBAL_MOUSE_DOWN" and buttonID == "LeftButton";
end