GameDialogCloseButtonStateNormal = "RedButton-Exit";
GameDialogCloseButtonStatePressed = "RedButton-exit-pressed";
GameDialogCloseButtonStateCondensedNormal = "RedButton-MiniCondense";
GameDialogCloseButtonStateCondensedPressed = "RedButton-MiniCondense-pressed";
GameDialogBackgroundTop = "UI-DiamondDialogBox-Border";

local MinWidth = 320;

function GameDialogMixin:GetInitialWidth(dialogInfo)
	if (dialogInfo.showAlert or dialogInfo.showAlertGear or dialogInfo.customAlertIcon or dialogInfo.closeButton or dialogInfo.wide) then
		return 420;
	elseif ( dialogInfo.editBoxWidth and dialogInfo.editBoxWidth > 260 ) then
		-- After looking at all dialogs that use this, the actual width effectively becomes 410. This is very close to the 420 above...
		return MinWidth + (dialogInfo.editBoxWidth - 260); 
	end

	return MinWidth;
end
