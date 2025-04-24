
function StaticPopup_ResizeWidth(dialog, info)
	local width = nil;

	if ( dialog.numButtons == 4 ) then
		width = 574;
	elseif ( dialog.numButtons == 3 ) then
		width = 440;
	elseif (info.showAlert or info.showAlertGear or info.customAlertIcon or info.closeButton or info.wide) then
		width = 420;
	elseif ( info.editBoxWidth and info.editBoxWidth > 260 ) then
		width = dialog:GetWidth() + (info.editBoxWidth - 260);
	elseif ( which == "GUILD_IMPEACH" ) then
		width = 375;
	end

	return width;
end

function StaticPopup_SetCloseButtonTexture(closeButton, info)
	if ( info.closeButtonIsHide ) then
		closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up");
		closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-HideButton-Down");
	else
		closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up");
		closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down");
	end
end