GameDialogCloseButtonStateNormal = "Interface\\Buttons\\UI-Panel-HideButton-Up";
GameDialogCloseButtonStatePressed = "Interface\\Buttons\\UI-Panel-HideButton-Down";
GameDialogCloseButtonStateCondensedNormal = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up";
GameDialogCloseButtonStateCondensedPressed = "Interface\\Buttons\\UI-Panel-MinimizeButton-Down";
GameDialogBackgroundTop = "UI-DiamondDialogBox-ClassicBorder";

local EditBoxMaxWidth = 260;
local MinWidth = 320;

function GameDialogMixin:GetInitialWidth(dialogInfo)
	local width = MinWidth;

	if ( self.numButtons == 4 ) then
		width = 574;
	elseif ( self.numButtons == 3 ) then
		width = 440;
	elseif (dialogInfo.showAlert or dialogInfo.showAlertGear or dialogInfo.customAlertIcon or dialogInfo.closeButton or dialogInfo.wide) then
		width = 420;
	elseif ( dialogInfo.editBoxWidth and dialogInfo.editBoxWidth > EditBoxMaxWidth ) then
		width = self:GetWidth() + (dialogInfo.editBoxWidth - EditBoxMaxWidth);
	end

	return math.max(width, MinWidth);
end
